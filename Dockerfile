FROM python:3.11-alpine AS builder

RUN apk add --no-cache build-base gcc musl-dev

WORKDIR /wheels
COPY requirements.txt .
RUN pip wheel --no-cache-dir --wheel-dir /wheels -r requirements.txt

FROM python:3.11-alpine

RUN adduser -D -s /bin/sh appuser

WORKDIR /app

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

COPY --from=builder /wheels /wheels
COPY requirements.txt .
RUN pip install --no-cache-dir --no-index --find-links /wheels -r requirements.txt && \
    rm -rf /wheels /root/.cache

COPY app.py .

USER appuser
EXPOSE 81
CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "81"]
