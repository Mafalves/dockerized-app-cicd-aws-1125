# Stage 1: Builder
FROM python:3.11-slim AS builder
WORKDIR /app

COPY app/requirements.txt .
RUN pip install --no-cache-dir --target /opt/packages -r requirements.txt

# Stage 2: Production
FROM python:3.11-slim

# Create non-root user
RUN useradd -m -u 1000 appuser
WORKDIR /app

# Install curl for healthcheck
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

# Copy dependencies and app code
COPY --from=builder /opt/packages /opt/packages
COPY app/ .

# Fix permissions
RUN chown -R appuser:appuser /app /opt/packages

USER appuser

# Ensure Python can find installed packages and executables
ENV PATH="/opt/packages/bin:${PATH}"
ENV PYTHONPATH="/opt/packages:${PYTHONPATH}"
ENV PYTHONUNBUFFERED=1

EXPOSE 5000

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:5000/health || exit 1

CMD ["gunicorn", "--bind", "0.0.0.0:5000", "--workers", "2", "--threads", "2", "--timeout", "60", "--access-logfile", "-", "--error-logfile", "-", "main:app"]
