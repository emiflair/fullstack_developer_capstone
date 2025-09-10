#!/bin/bash

# Quick deployment script for updating Docker containers and Kubernetes

echo "🚀 Starting Docker and Kubernetes update process..."

# Check if we're in the right directory
if [ ! -f "deploy.sh" ]; then
    echo "❌ Error: deploy.sh not found. Make sure you're in the project root directory."
    exit 1
fi

# Make sure Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker Desktop and try again."
    exit 1
fi

# Make sure kubectl is configured
if ! kubectl cluster-info > /dev/null 2>&1; then
    echo "❌ kubectl is not configured or cluster is not reachable."
    echo "Please configure your Kubernetes cluster and try again."
    exit 1
fi

echo "✅ Prerequisites check passed!"
echo ""

# Build and deploy
echo "🔨 Building Docker images and deploying to Kubernetes..."
./deploy.sh latest all deploy

echo ""
echo "🎉 Deployment completed!"
echo ""
echo "📊 Current cluster status:"
kubectl get pods -o wide
echo ""
kubectl get services
echo ""

echo "🔗 To access your application:"
echo "1. Django Admin: Use kubectl port-forward to access the admin panel"
echo "2. API: Available through the dealership-api service"
echo "3. Database: MongoDB running in the cluster"
echo ""

echo "💡 Useful commands:"
echo "kubectl get pods                    # Check pod status"
echo "kubectl logs <pod-name>             # View logs"
echo "kubectl port-forward svc/dealership-svc 8000:8000  # Access Django locally"
echo "kubectl port-forward svc/dealership-api 3030:3030  # Access API locally"
