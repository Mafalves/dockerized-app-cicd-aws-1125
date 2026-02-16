# Project 2: Dockerized Application + CI/CD Pipeline

A containerized Flask web application with automated CI/CD deployment to AWS EC2.

## Features Implemented
- Flask application
- Dockerfile (multi-stage build)
- Docker Compose
- CI/CD pipeline
- AWS deployment

## CI/CD Pipeline

```mermaid
graph LR
    A[Developer<br/>Push to main] --> B[GitHub Actions CI]
    B --> C{Lint & Test}
    C -->|Pass| D[Docker Build Test]
    C -->|Fail| E[CI Fails]
    D -->|Pass| F[GitHub Actions CD]
    D -->|Fail| E
    F --> G[Docker Hub<br/>Login]
    G --> H[Build & Push Image<br/>latest + SHA tags]
    H --> I[Image on Docker Hub]
    
    subgraph Manual["Manual (when demoing)"]
        J[Actions → Deploy to EC2] --> K[AWS SSM Command]
        K --> L[EC2 Instance<br/>Tag: Application=flask-app]
        L --> M[Docker Pull]
        M --> N[Stop Old Container]
        N --> O[Run New Container]
        O --> P[App Deployed]
    end
```

### Pipeline Flow

1. **CI Workflow** (runs on push/PR):
   - Code linting with flake8
   - Test execution (optional)
   - Dockerfile linting with hadolint
   - Docker build validation

2. **CD Workflow** (runs on push to main):
   - Authenticate with Docker Hub
   - Build and push image with `latest` and `${{ github.sha }}` tags
   - Image is available on Docker Hub for K8s (Project 3) or EC2

3. **Deploy to EC2** (manual, `workflow_dispatch`):
   - Run from GitHub Actions → "Deploy Dockerized Flask App to AWS EC2" → Run workflow
   - Authenticate with AWS
   - Send SSM command to EC2 instance(s) tagged `Application=flask-app`
   - Instance pulls `latest`, stops old container, runs new container
   - Use when you need to demo the app on EC2 (EC2 is not always running)

## Local Development

### Prerequisites
- Docker and Docker Compose
- (Optional) Python 3.11+ for local development without Docker

### Running with Docker Compose
```bash
# Create .env file (optional - defaults to PORT=5000)
echo "PORT=5000" > .env
echo "ENVIRONMENT=development" >> .env
echo "APP_VERSION=1.0.0" >> .env

# Build and run
docker-compose up --build
```

Visit `http://localhost:5000` (or the port specified in `.env`)

### Running Locally (without Docker)
```bash
cd app
pip install -r requirements.txt
python main.py
```

Visit `http://localhost:5000`

## Endpoints
- `/` - Homepage
- `/health` - Health check endpoint
- `/api/info` - System information API

## Tech Stack
- Python 3.11
- Flask 3.0
- Gunicorn (production server)
- Docker (multi-stage builds)
- Docker Compose

The image is built and pushed by CD as `matalve/flask-app:latest` and `matalve/flask-app:$SHA`. For the full naming and tagging convention (local vs registry, K8s), see **k8s-app-deployment-0126** README.

## Building the Docker Image
```bash
docker build -t flask-app:local .
docker run -p 5000:5000 flask-app:local
```