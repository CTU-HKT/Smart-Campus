#!/bin/sh
set -eu

TOKEN_LABEL="${SOFTHSM_TOKEN_LABEL:-smartcampus-demo}"
KEY_LABEL="${SOFTHSM_KEY_LABEL:-smartcampus-signer}"

: "${SOFTHSM_USER_PIN:?Missing SOFTHSM_USER_PIN}"
: "${SOFTHSM_SO_PIN:?Missing SOFTHSM_SO_PIN}"

MODULE="/usr/lib/x86_64-linux-gnu/softhsm/libsofthsm2.so"

mkdir -p /var/lib/softhsm/tokens /app/certs

# Không khởi tạo lại token đã tồn tại.
if softhsm2-util --show-slots | grep -q "Label: *${TOKEN_LABEL}"; then
    echo "Token already exists: ${TOKEN_LABEL}"
    exit 0
fi

softhsm2-util \
    --init-token \
    --free \
    --label "$TOKEN_LABEL" \
    --pin "$SOFTHSM_USER_PIN" \
    --so-pin "$SOFTHSM_SO_PIN"

# Tạo khóa tạm trong thư mục không được mount ra máy host.
TMPDIR="$(mktemp -d)"
trap 'rm -rf "$TMPDIR"' EXIT

openssl req \
    -x509 \
    -newkey rsa:3072 \
    -sha256 \
    -nodes \
    -days 365 \
    -subj "/C=VN/O=Smart Campus Demo/CN=Smart Campus Demo Signer" \
    -keyout "$TMPDIR/signing.key" \
    -out /app/certs/signer.crt

# Nhập khóa riêng tư vào token.
softhsm2-util \
    --import "$TMPDIR/signing.key" \
    --token "$TOKEN_LABEL" \
    --label "$KEY_LABEL" \
    --id A1B2 \
    --pin "$SOFTHSM_USER_PIN"

# Nhập chứng thư công khai vào cùng token.
openssl x509 \
    -in /app/certs/signer.crt \
    -outform DER \
    -out "$TMPDIR/signer.der"

pkcs11-tool \
    --module "$MODULE" \
    --token-label "$TOKEN_LABEL" \
    --login \
    --pin "$SOFTHSM_USER_PIN" \
    --write-object "$TMPDIR/signer.der" \
    --type cert \
    --id A1B2 \
    --label "$KEY_LABEL"

echo "SoftHSM token and demo certificate initialized."