# Project 2: Dockerized Application + CI/CD Pipeline

A containerized Flask web application with automated CI/CD deployment to AWS EC2.

## Current Status
Flask application created - COMPLETED
Dockerfile
Docker Compose
CI/CD Pipeline
AWS Deployment

## Local Development

### Prerequisites
- Python 3.9+

### Running Locally
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
- Python 3.9
- Flask 3.0
- Gunicorn (production server)