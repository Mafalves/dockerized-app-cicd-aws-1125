# Multi-stage build for optimized image size
# Stage 1: Builder - Install dependencies

FROM python:3.9-slim as builder 

WORKDIR /app

# Copy requirements first for better layer caching
COPY app/requirements.txt .

# Creates a virtual environment. This is the isolation layer that will be copied to the final image.
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

#d Instructs pip to install Python packages without utilizing or creating a local cache directory for downloaded packages (minimizing the size of this layer).
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Stage 2: Production - Minimal runtime image
FROM python:3.9-slim

# Create non-root user for security
RUN useradd -m -u 1000 appuser

WORKDIR /app

# Copy virtual environment from builder stage
COPY --from=builder /opt/venv /opt/venv

# Copy application code
COPY app/ .

# Set ownership to non-root user
RUN chown -R appuser:appuser /app

# Switch to non-root user
USER appuser

# Set environment variables
ENV PATH="/opt/venv/bin:$PATH" \
    PORT=5000 \
    ENVIRONMENT=production \
    APP_VERSION=1.0.0 \
    PYTHONUNBUFFERED=1 

# Documentation for the port the application listens on.
EXPOSE 5000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \ 
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:5000/health')" || exit 1

# Run with gunicorn for production
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "--workers", "2", "--threads", "2", "--timeout", "60", "--access-logfile", "-", "--error-logfile", "-", "main:app"]