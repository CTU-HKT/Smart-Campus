FROM python:3.12-slim-bookworm

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    SOFTHSM2_CONF=/app/softhsm2.conf

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    softhsm2 \
    opensc \
    openssl \
    ca-certificates && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

COPY app/ ./app/
COPY scripts/ ./scripts/
COPY softhsm2.conf .

RUN mkdir -p /var/lib/softhsm/tokens /app/certs /app/output

EXPOSE 8000

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]