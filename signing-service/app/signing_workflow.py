"""DX-OS signing workflow. Integrates existing /sign and /ledger/register APIs with Flyway V10.
Internal service only; do not expose without gateway authentication.
"""
import hashlib
import io
import json
import os
import re
import subprocess
import tempfile
from datetime import datetime, timezone
from pathlib import Path
from uuid import UUID, uuid4

import httpx
from cryptography import x509
from cryptography.hazmat.primitives import hashes
from fastapi import APIRouter, File, Header, HTTPException, UploadFile
from fastapi.responses import Response
from psycopg.types.json import Jsonb

from .database import get_db

router = APIRouter(prefix="/internal/documents", tags=["Internal digital signing"])
BASE = Path(os.getenv("SIGNED_PDF_DIR", "/app/storage"))
INTERNAL_BASE = os.getenv("SIGNING_INTERNAL_URL", "http://127.0.0.1:8000").rstrip("/")
MAX_PDF_BYTES = int(os.getenv("SIGNING_MAX_PDF_BYTES", str(10 * 1024 * 1024)))
CERT_PATH = os.getenv("SIGNING_CERT_PATH", "/app/certs/signer.crt")
FIELD = os.getenv("SIGNATURE_FIELD", "Signature1")
KEY_REFERENCE = os.getenv("SIGNING_KEY_REFERENCE", "softhsm-demo")


def _digest(blob: bytes) -> str:
    return hashlib.sha256(blob).hexdigest()


def _authorize(token: str | None):
    expected = os.getenv("SIGNING_INTERNAL_API_KEY", "")
    if not expected or not token:
        raise HTTPException(503 if not expected else 401, "Internal API key not configured or missing")
    import hmac
    if not hmac.compare_digest(token, expected):
        raise HTTPException(403, "Invalid internal API key")


def _event(cur, doc_id, old, new, reason):
    cur.execute("""INSERT INTO app.lich_su_trang_thai_tai_lieu
      (tai_lieu_id,trang_thai_cu,trang_thai_moi,actor_type,actor_subject,ly_do)
      VALUES (%s,%s,%s,'SERVICE','signing-service',%s)""", (doc_id, old, new, reason))


def _claim_document(ho_so_id: int, doc_id: UUID):
    """One document per application/type/version; reuses only an existing PENDING document."""
    with get_db() as conn:
        with conn.cursor() as cur:
            cur.execute("SELECT id FROM app.ho_so WHERE id=%s AND trang_thai='Đã duyệt'", (ho_so_id,))
            if not cur.fetchone():
                raise HTTPException(409, "Application does not exist or is not approved")
            cur.execute("""SELECT id,trang_thai FROM app.tai_lieu_so
                WHERE ho_so_id=%s AND loai_tai_lieu='GIAY_XAC_NHAN' AND phien_ban=1 FOR UPDATE""", (ho_so_id,))
            row = cur.fetchone()
            if row:
                if row["trang_thai"] != "PENDING":
                    raise HTTPException(409, f"Existing document {row['id']} is {row['trang_thai']}; no duplicate signing")
                doc_id = row["id"]
            else:
                cur.execute("""INSERT INTO app.tai_lieu_so
                    (id,ho_so_id,ma_tai_lieu,loai_tai_lieu,ten_tai_lieu,phien_ban,trang_thai)
                    VALUES (%s,%s,%s,'GIAY_XAC_NHAN','Giay xac nhan sinh vien',1,'PENDING')""",
                    (doc_id,ho_so_id,'SC-'+doc_id.hex.upper()))
                _event(cur, doc_id, None, 'PENDING', 'Created for signing')
            cur.execute("""UPDATE app.tai_lieu_so SET trang_thai='SIGNING',ngay_cap_nhat=now()
              WHERE id=%s AND trang_thai='PENDING'""", (doc_id,))
            if cur.rowcount != 1:
                raise HTTPException(409, "Document cannot be claimed")
            _event(cur, doc_id, 'PENDING', 'SIGNING', 'Signing started')
    return doc_id


def _mark_failed(doc_id: UUID, error: str):
    try:
        with get_db() as conn:
            with conn.cursor() as cur:
                cur.execute("""UPDATE app.tai_lieu_so SET trang_thai='FAILED',ngay_cap_nhat=now()
                  WHERE id=%s AND trang_thai='SIGNING'""", (doc_id,))
                if cur.rowcount:
                    _event(cur, doc_id, 'SIGNING', 'FAILED', error[:1000])
    except Exception:
        import logging
        logging.exception("Could not mark signing failure for %s", doc_id)


def _certificate():
    raw = Path(CERT_PATH).read_bytes()
    try:
        cert = x509.load_pem_x509_certificate(raw)
    except ValueError:
        cert = x509.load_der_x509_certificate(raw)
    return cert


def _validate_signature(blob: bytes):
    """Fail closed: pyHanko CLI must confirm signature VALID under supplied demo trust root."""
    with tempfile.NamedTemporaryFile(suffix='.pdf') as tmp:
        tmp.write(blob)
        tmp.flush()
        command = ['pyhanko', 'sign', 'validate', '--pretty-print', '--trust', CERT_PATH, tmp.name]
        proc = subprocess.run(command, capture_output=True, text=True, timeout=60)
        output = (proc.stdout + '\n' + proc.stderr)
        if proc.returncode != 0 or not re.search(r'signature is judged VALID', output, re.I):
            raise RuntimeError('PDF signature validation failed: '+output[-1500:])
    return {'validation': 'VALID', 'validator': 'pyhanko-cli', 'trust': 'local-demo-certificate'}


async def _sign_using_existing_api(blob: bytes):
    # Adapter 1: existing POST /sign must accept multipart field "file" and return raw signed PDF.
    async with httpx.AsyncClient(timeout=120.0) as client:
        r = await client.post(INTERNAL_BASE+'/sign', files={'file': ('input.pdf', blob, 'application/pdf')})
        r.raise_for_status()
        signed = r.content
    if not signed.startswith(b'%PDF-'):
        raise RuntimeError('Existing /sign endpoint did not return PDF bytes; adjust adapter')
    return signed


async def _register_ledger_using_existing_api(blob: bytes, document_id: UUID):
    # Adapter 2: existing POST /ledger/register must accept multipart field "file".
    # Verified proof is independently checked by the existing SDK endpoint's returned boolean.
    async with httpx.AsyncClient(timeout=120.0) as client:
        r = await client.post(INTERNAL_BASE+'/ledger/register', files={'file': ('signed.pdf', blob, 'application/pdf')})
        r.raise_for_status()
        payload = r.json()
    if not isinstance(payload, dict):
        raise RuntimeError('Unexpected ledger response')
    # Do NOT treat registration success or hash equality as Merkle verification.
    if payload.get('ledger_proof_verified') is not True:
        raise RuntimeError('Ledger did not report verifiedSet/verifiedGet proof; adapt ledger integration')
    key = payload.get('immudb_key') or payload.get('key') or payload.get('document_id')
    if not isinstance(key, str) or not key:
        raise RuntimeError('Ledger response missing immutable key')
    ledger_hash = payload.get('sha256') or payload.get('document_sha256')
    if ledger_hash is not None and ledger_hash != _digest(blob):
        raise RuntimeError('Ledger hash mismatch')
    return key, payload


def _persist_success(doc_id, signed, ledger_key, ledger_payload, validation):
    digest = _digest(signed)
    cert = _certificate()
    now = datetime.now(timezone.utc)
    key = f'{doc_id}.pdf'
    # Atomic rename into private volume; never expose path as a URL.
    BASE.mkdir(parents=True, exist_ok=True)
    destination = BASE / key
    if destination.exists():
        raise RuntimeError('Storage object already exists; manual reconciliation required')
    tmp = BASE / f'.{doc_id}.{uuid4().hex}.tmp'
    try:
        with tmp.open('xb') as out:
            out.write(signed)
            out.flush()
            os.fsync(out.fileno())
        tmp.rename(destination)
        with get_db() as conn:
            with conn.cursor() as cur:
                cur.execute("""SELECT trang_thai FROM app.tai_lieu_so WHERE id=%s FOR UPDATE""", (doc_id,))
                row = cur.fetchone()
                if not row or row['trang_thai'] != 'SIGNING':
                    raise RuntimeError('Document no longer SIGNING')
                cur.execute("""INSERT INTO app.chu_ky_so
                   (tai_lieu_id,signature_field,signer_subject,signer_issuer,signer_certificate_sha256,
                    certificate_serial_number,signature_algorithm,digest_algorithm,signed_at,
                    certificate_not_before,certificate_not_after,signing_key_reference,
                    signature_validation_status,signature_validation_checked_at,validation_details)
                    VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,'VALID',%s,%s)
                    RETURNING id""", (doc_id,FIELD,cert.subject.rfc4514_string(),cert.issuer.rfc4514_string(),
                      cert.fingerprint(hashes.SHA256()).hex(),str(cert.serial_number),'RSA','SHA384',now,
                      cert.not_valid_before_utc,cert.not_valid_after_utc,KEY_REFERENCE,now,Jsonb(validation)))
                signature_id = cur.fetchone()['id']
                cur.execute("""INSERT INTO app.bang_chung_immudb
                    (tai_lieu_id,immudb_database,immudb_key,document_sha256,proof_status,proof_verified_at,proof_metadata)
                    VALUES (%s,%s,%s,%s,'VERIFIED',%s,%s)""",
                    (doc_id,os.getenv('IMMUDB_DATABASE','defaultdb'),ledger_key,digest,now,Jsonb(ledger_payload)))
                cur.execute("""UPDATE app.tai_lieu_so SET
                    storage_provider='LOCAL_VOLUME',storage_object_key=%s,kich_thuoc_bytes=%s,
                    sha256=%s,ngay_ky=%s,trang_thai='SIGNED',ngay_cap_nhat=now()
                    WHERE id=%s AND trang_thai='SIGNING'""", (key,len(signed),digest,now,doc_id))
                if cur.rowcount != 1:
                    raise RuntimeError('Document status changed concurrently')
                _event(cur,doc_id,'SIGNING','SIGNED','PDF, signature and immudb proof persisted')
                cur.execute("""INSERT INTO app.nhat_ky_xac_thuc
                  (tai_lieu_id,chu_ky_id,ket_qua_hash,ket_qua_chu_ky,ket_qua_ledger,ket_luan,
                   verification_source,details)
                  VALUES (%s,%s,'MATCH','VALID','VERIFIED','VALID','WORKFLOW',%s)""",
                  (doc_id,signature_id,Jsonb({'verification_scope':'local demo trust + SDK proof'})))
    finally:
        tmp.unlink(missing_ok=True)
    return {'document_id':str(doc_id),'ho_so_id':None,'status':'SIGNED','sha256':digest,
            'storage_object_key':key,'ledger_key':ledger_key}


@router.post('/{ho_so_id}/sign')
async def sign_application(ho_so_id: int, file: UploadFile = File(...), x_internal_api_key: str | None = Header(default=None)):
    _authorize(x_internal_api_key)
    if ho_so_id <= 0:
        raise HTTPException(400, 'Invalid application id')
    data = await file.read(MAX_PDF_BYTES + 1)
    if len(data) > MAX_PDF_BYTES or not data.startswith(b'%PDF-'):
        raise HTTPException(400, 'Invalid PDF or PDF too large')
    doc_id = _claim_document(ho_so_id, uuid4())
    try:
        signed = await _sign_using_existing_api(data)
        validation = _validate_signature(signed)
        ledger_key, ledger_payload = await _register_ledger_using_existing_api(signed, doc_id)
        result = _persist_success(doc_id, signed, ledger_key, ledger_payload, validation)
        result['ho_so_id'] = ho_so_id
        return result
    except Exception as exc:
        _mark_failed(doc_id, str(exc))
        import logging
        logging.exception('Signing workflow failed: %s', doc_id)
        raise HTTPException(502, f'Signing failed; document {doc_id} marked FAILED; check service logs')


@router.get('/{document_id}/download')
def download_signed(document_id: UUID, x_internal_api_key: str | None = Header(default=None)):
    _authorize(x_internal_api_key)
    with get_db() as conn:
        with conn.cursor() as cur:
            cur.execute("""SELECT storage_object_key,sha256,trang_thai FROM app.tai_lieu_so WHERE id=%s""", (document_id,))
            row = cur.fetchone()
    if not row or row['trang_thai'] != 'SIGNED':
        raise HTTPException(404, 'Signed document not found')
    key = row['storage_object_key']
    if key != f'{document_id}.pdf':
        raise HTTPException(500, 'Unexpected storage key')
    data = (BASE / key).read_bytes()
    if _digest(data) != row['sha256']:
        raise HTTPException(409, 'Stored PDF integrity check failed')
    return Response(data, media_type='application/pdf', headers={'Content-Disposition':f'attachment; filename="{key}"'})
