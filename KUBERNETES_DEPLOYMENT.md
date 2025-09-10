# Kubernetes Deployment Guide for Dealership Application

This guide helps you deploy the dealership application to Kubernetes with the admin credentials properly configured.

## Prerequisites

1. **Docker images built** ✅ (Already completed)
2. **Kubernetes cluster** - Configure your cluster
3. **kubectl configured** - Point to your cluster
4. **Container registry access** - Push/pull permissions

## Step 1: Configure Kubernetes Cluster

Before deploying, make sure your Kubernetes cluster is configured:

```bash
# Check cluster connection
kubectl cluster-info

# Check nodes
kubectl get nodes

# Check current context
kubectl config current-context
```

## Step 2: Push Docker Images

```bash
# Show current images
./docker-manage.sh latest show

# Push to registry (when ready)
./docker-manage.sh latest push
```

## Step 3: Deploy to Kubernetes

### Option A: Deploy with Updated Configuration (Recommended)

```bash
# Deploy MongoDB
kubectl apply -f server/mongo.yaml

# Deploy API
kubectl apply -f server/dealership-api.yaml

# Deploy Django with admin credentials
kubectl apply -f server/deployment-updated.yaml

# Deploy service
kubectl apply -f server/dealership-svc.yaml
```

### Option B: Use Deployment Script

```bash
# Full deployment (when cluster is ready)
./deploy.sh latest all deploy
```

## Step 4: Verify Deployment

```bash
# Check pods
kubectl get pods -o wide

# Check services
kubectl get services

# Check deployments
kubectl get deployments

# View logs
kubectl logs -l run=dealership
kubectl logs -l app=dealership-api
```

## Step 5: Access the Application

### Port Forwarding (for testing)

```bash
# Django Admin
kubectl port-forward svc/dealership-svc 8000:8000
# Then visit: http://localhost:8000/admin/

# API
kubectl port-forward svc/dealership-api 3030:3030
# Then visit: http://localhost:3030/
```

### Load Balancer (production)

```bash
# Check external IP
kubectl get svc dealership-svc

# If using cloud provider, external IP will be assigned
```

## Admin Credentials

The deployment automatically creates a Django superuser with these credentials:

- **Username:** `emifeaustin`
- **Email:** `emifeaustin0909@gmail.com`
- **Password:** `dealership123`

These are configured via Kubernetes secrets in `deployment-updated.yaml`.

## Troubleshooting

### Pod not starting
```bash
kubectl describe pod <pod-name>
kubectl logs <pod-name>
```

### Image pull issues
```bash
# Check if images exist in registry
docker images | grep dealership

# Push images if needed
./docker-manage.sh latest push
```

### Database connection issues
```bash
# Check MongoDB pod
kubectl get pods -l app=mongo-db
kubectl logs -l app=mongo-db
```

### Admin login issues
```bash
# Check Django pod logs
kubectl logs -l run=dealership

# Create superuser manually if needed
kubectl exec -it <django-pod> -- python manage.py createsuperuser
```

## Environment Variables

The deployment includes these important environment variables:

- `DJANGO_SETTINGS_MODULE`: Django configuration
- `backend_url`: API endpoint
- `sentiment_analyzer_url`: External sentiment analysis service
- `DJANGO_SUPERUSER_*`: Admin credentials (from secret)

## Scaling

```bash
# Scale Django pods
kubectl scale deployment dealership --replicas=3

# Scale API pods
kubectl scale deployment dealership-api --replicas=2
```

## Updates

To update the application:

1. Build new Docker images
2. Push to registry
3. Update Kubernetes deployment:

```bash
kubectl set image deployment/dealership dealership=us.icr.io/sn-labs-emifeaustin0/dealership:v2.0
kubectl rollout status deployment/dealership
```

## Cleanup

```bash
# Delete all resources
kubectl delete -f server/
```

## Files Overview

- `server/deployment-updated.yaml` - Main Django deployment with secrets
- `server/dealership-api.yaml` - Node.js API deployment
- `server/dealership-svc.yaml` - Service configuration
- `server/mongo.yaml` - MongoDB deployment
- `deploy.sh` - Comprehensive deployment script
- `docker-manage.sh` - Docker image management
- `quick-deploy.sh` - Simple deployment script
