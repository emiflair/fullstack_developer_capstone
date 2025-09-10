#!/bin/bash

# Deployment script for Fullstack Developer Capstone
# This script builds Docker images, pushes them to registry, and updates Kubernetes deployments

set -e  # Exit on any error

# Configuration
REGISTRY="us.icr.io/sn-labs-emifeaustin0"
DJANGO_IMAGE="${REGISTRY}/dealership"
API_IMAGE="${REGISTRY}/dealership-api"
FRONTEND_IMAGE="${REGISTRY}/dealership-frontend"
TAG="${1:-latest}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

echo_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

echo_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

echo_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Function to build and push Django backend
build_django() {
    echo_info "Building Django backend..."
    cd server
    
    # Update the entrypoint to include our superuser creation
    echo_info "Building Docker image: ${DJANGO_IMAGE}:${TAG}"
    docker build -t ${DJANGO_IMAGE}:${TAG} .
    
    echo_info "Pushing Django image to registry..."
    docker push ${DJANGO_IMAGE}:${TAG}
    
    echo_success "Django backend built and pushed successfully!"
    cd ..
}

# Function to build and push Node.js API
build_api() {
    echo_info "Building Node.js API..."
    cd server/database
    
    echo_info "Building Docker image: ${API_IMAGE}:${TAG}"
    docker build -t ${API_IMAGE}:${TAG} .
    
    echo_info "Pushing API image to registry..."
    docker push ${API_IMAGE}:${TAG}
    
    echo_success "Node.js API built and pushed successfully!"
    cd ../..
}

# Function to build and push React frontend
build_frontend() {
    echo_info "Building React frontend..."
    cd server/frontend
    
    echo_info "Building Docker image: ${FRONTEND_IMAGE}:${TAG}"
    docker build -f Dockerfile.frontend -t ${FRONTEND_IMAGE}:${TAG} .
    
    echo_info "Pushing frontend image to registry..."
    docker push ${FRONTEND_IMAGE}:${TAG}
    
    echo_success "React frontend built and pushed successfully!"
    cd ../..
}

# Function to update Kubernetes deployments
update_kubernetes() {
    echo_info "Updating Kubernetes deployments..."
    
    cd server
    
    # Update MongoDB
    echo_info "Applying MongoDB deployment..."
    kubectl apply -f mongo.yaml
    
    # Update API deployment
    echo_info "Applying API deployment..."
    kubectl apply -f dealership-api.yaml
    
    # Update Django deployment with updated image
    echo_info "Updating Django deployment with new image..."
    kubectl set image deployment/dealership dealership=${DJANGO_IMAGE}:${TAG}
    kubectl apply -f dealership-svc.yaml
    kubectl apply -f deployment.yaml
    
    # Wait for rollout to complete
    echo_info "Waiting for deployment rollout to complete..."
    kubectl rollout status deployment/dealership
    kubectl rollout status deployment/dealership-api
    kubectl rollout status deployment/mongo-db
    
    cd ..
    echo_success "Kubernetes deployments updated successfully!"
}

# Function to show deployment status
show_status() {
    echo_info "Checking deployment status..."
    
    echo_info "Pods:"
    kubectl get pods -o wide
    
    echo_info "Services:"
    kubectl get services
    
    echo_info "Deployments:"
    kubectl get deployments
    
    # Get external URL if available
    echo_info "Getting service URLs..."
    kubectl get svc dealership-svc -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || echo "No external IP available"
}

# Function to create a superuser in the running pod
create_superuser() {
    echo_info "Creating superuser in the running Django pod..."
    
    POD_NAME=$(kubectl get pods -l run=dealership -o jsonpath='{.items[0].metadata.name}')
    
    if [ -z "$POD_NAME" ]; then
        echo_error "No dealership pod found!"
        return 1
    fi
    
    echo_info "Found pod: $POD_NAME"
    
    # Create superuser using environment variables
    kubectl exec -it $POD_NAME -- python manage.py shell -c "
from django.contrib.auth.models import User
import os

username = 'admin'
email = 'admin@dealership.com'
password = 'adminpass123'

if not User.objects.filter(username=username).exists():
    user = User.objects.create_superuser(username=username, email=email, password=password)
    print(f'Superuser {username} created successfully!')
else:
    print(f'Superuser {username} already exists.')
"
    
    echo_success "Superuser setup completed!"
}

# Function to clean up old images
cleanup_images() {
    echo_info "Cleaning up old Docker images..."
    docker image prune -f
    echo_success "Docker cleanup completed!"
}

# Main execution
main() {
    echo_info "Starting deployment process..."
    echo_info "Registry: $REGISTRY"
    echo_info "Tag: $TAG"
    echo ""
    
    # Check if docker is running
    if ! docker info > /dev/null 2>&1; then
        echo_error "Docker is not running. Please start Docker and try again."
        exit 1
    fi
    
    # Check if kubectl is configured
    if ! kubectl cluster-info > /dev/null 2>&1; then
        echo_error "kubectl is not configured or cluster is not reachable."
        exit 1
    fi
    
    # Build and push images
    case "${2:-all}" in
        "django")
            build_django
            ;;
        "api")
            build_api
            ;;
        "frontend")
            build_frontend
            ;;
        "all")
            build_django
            build_api
            # build_frontend  # Uncomment if you want to build frontend too
            ;;
        *)
            echo_error "Invalid component. Use: django, api, frontend, or all"
            exit 1
            ;;
    esac
    
    # Update Kubernetes if requested
    if [[ "${3}" == "deploy" || "${2}" == "deploy" ]]; then
        update_kubernetes
        sleep 10  # Wait for pods to start
        show_status
        
        # Optionally create superuser
        read -p "Do you want to create a superuser in the Django pod? (y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            create_superuser
        fi
    fi
    
    # Cleanup if requested
    if [[ "${4}" == "cleanup" || "${3}" == "cleanup" ]]; then
        cleanup_images
    fi
    
    echo_success "Deployment process completed successfully! 🚀"
    echo_info "You can access your application using the service URLs shown above."
}

# Help function
show_help() {
    echo "Usage: $0 [TAG] [COMPONENT] [ACTION] [CLEANUP]"
    echo ""
    echo "Arguments:"
    echo "  TAG        Docker image tag (default: latest)"
    echo "  COMPONENT  Which component to build: django, api, frontend, all (default: all)"
    echo "  ACTION     deploy - also update Kubernetes deployments"
    echo "  CLEANUP    cleanup - remove old Docker images"
    echo ""
    echo "Examples:"
    echo "  $0                           # Build all with latest tag"
    echo "  $0 v1.0                      # Build all with v1.0 tag"
    echo "  $0 latest django deploy      # Build Django, deploy to k8s"
    echo "  $0 latest all deploy cleanup # Build all, deploy, and cleanup"
    echo ""
    echo "Other useful commands:"
    echo "  kubectl get pods             # Check running pods"
    echo "  kubectl logs <pod-name>      # View pod logs"
    echo "  kubectl describe pod <name>  # Debug pod issues"
}

# Check if help is requested
if [[ "${1}" == "-h" || "${1}" == "--help" ]]; then
    show_help
    exit 0
fi

# Run main function
main "$@"
