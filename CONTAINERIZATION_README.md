# 🐳 Car Dealership Application - Containerized Version

This branch (`containerize-k8s`) contains the containerized version of the car dealership application using Docker and Kubernetes.

## 🚀 Quick Start

### Prerequisites
- Docker installed
- Git installed
- (Optional) Kubernetes cluster access for K8s deployment

### 1. Clone and Setup
```bash
# Clone the repository
git clone https://github.com/emiflair/fullstack_developer_capstone.git
cd fullstack_developer_capstone

# Switch to containerization branch
git checkout containerize-k8s

# Navigate to server directory
cd server
```

### 2. Build Docker Image
```bash
docker build -t us.icr.io/sn-labs-emifeaustin0/dealership:latest .
```

### 3. Run the Application

#### Option A: Complete Setup (Database + Django)
```bash
# Run everything with one command
./start-complete.sh

# This will:
# - Start the database API on port 3030
# - Build and run the Django container on port 8000
# - Configure proper networking between services
```

#### Option B: Docker Only (Manual Database Setup)
```bash
# First, start the database API manually
cd database
npm install
node app.js &
cd ..

# Then run the Django container
./start-container.sh
```

#### Option C: Kubernetes Deployment
```bash
# Deploy to Kubernetes (requires database service)
kubectl apply -f dealership-api.yaml  # Database API service
kubectl apply -f deployment.yaml      # Django app

# Check deployment
kubectl get deployments
kubectl get pods

# Port forward to access
kubectl port-forward deployment/dealership 8000:8000
```

### 4. Access Application
- **URL**: http://localhost:8000
- **Health Check**: `curl -I http://localhost:8000`

## 📁 Container Files

- **Dockerfile**: Multi-stage build with Python 3.12
- **entrypoint.sh**: Handles migrations and static files
- **deployment.yaml**: Kubernetes deployment configuration
- **dealership-svc.yaml**: Kubernetes service configuration

## 🔧 Container Specifications

- **Base Image**: python:3.12.0-slim-bookworm
- **Port**: 8000
- **Memory**: 128Mi-256Mi
- **CPU**: 100m-500m
- **Workers**: 3 Gunicorn workers

## 🛠️ Management Commands

```bash
# Stop container
docker stop dealership-app

# Start container
docker start dealership-app

# Remove container
docker rm dealership-app

# View container stats
docker stats dealership-app

# Execute into container
docker exec -it dealership-app /bin/bash
```

## 🌐 Environment Variables

- `DJANGO_SETTINGS_MODULE`: djangoproj.settings
- `backend_url`: http://dealership-api:3030
- `sentiment_analyzer_url`: https://sentianalyzer.1zsxdruquzxr.us-south.codeengine.appdomain.cloud/

## 📝 Development Notes

- This branch is separate from `main` for isolated development
- Container includes automatic database migrations
- Static files are collected automatically
- Ready for production deployment

## 🔄 Branch Management

```bash
# Switch back to main
git checkout main

# Switch to containerization branch
git checkout containerize-k8s

# View differences from main
git diff main
```

## 🆘 Troubleshooting

1. **Container won't start**: Check `docker logs dealership-app`
2. **Port already in use**: Use different port `-p 8001:8000`
3. **Build fails**: Ensure Docker daemon is running
4. **404 errors**: Verify static files with `docker exec -it dealership-app ls /app/static`

---
**Namespace**: sn-labs-emifeaustin0  
**Image**: us.icr.io/sn-labs-emifeaustin0/dealership:latest
