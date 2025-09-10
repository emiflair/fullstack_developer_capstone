#!/bin/bash

# Docker Image Management Script
# This script helps you manage Docker images for the dealership application

# Configuration
REGISTRY="us.icr.io/sn-labs-emifeaustin0"
TAG="${1:-latest}"

echo "🐳 Docker Image Management for Dealership Application"
echo "Registry: $REGISTRY"
echo "Tag: $TAG"
echo ""

# Function to show current images
show_images() {
    echo "📦 Current Docker images:"
    docker images | grep -E "(dealership|REPOSITORY)"
    echo ""
}

# Function to push images to registry
push_images() {
    echo "🚀 Pushing images to registry..."
    
    echo "Pushing Django image..."
    docker push ${REGISTRY}/dealership:${TAG}
    
    echo "Pushing API image..."
    docker push ${REGISTRY}/dealership-api:${TAG}
    
    echo "✅ All images pushed successfully!"
}

# Function to pull images from registry
pull_images() {
    echo "⬇️  Pulling images from registry..."
    
    docker pull ${REGISTRY}/dealership:${TAG}
    docker pull ${REGISTRY}/dealership-api:${TAG}
    
    echo "✅ All images pulled successfully!"
}

# Function to test images locally
test_local() {
    echo "🧪 Testing images locally..."
    
    # Test Django image
    echo "Testing Django image..."
    docker run --rm -p 8000:8000 -e DJANGO_SETTINGS_MODULE=djangoproj.settings ${REGISTRY}/dealership:${TAG} &
    DJANGO_PID=$!
    
    sleep 5
    
    if curl -f http://localhost:8000/admin/ > /dev/null 2>&1; then
        echo "✅ Django image working correctly"
    else
        echo "❌ Django image test failed"
    fi
    
    kill $DJANGO_PID 2>/dev/null
    
    echo "✅ Local testing completed!"
}

# Main menu
case "${2:-menu}" in
    "show")
        show_images
        ;;
    "push")
        push_images
        ;;
    "pull")
        pull_images
        ;;
    "test")
        test_local
        ;;
    "menu"|*)
        echo "Available commands:"
        echo "  $0 [TAG] show  - Show current Docker images"
        echo "  $0 [TAG] push  - Push images to registry"
        echo "  $0 [TAG] pull  - Pull images from registry"
        echo "  $0 [TAG] test  - Test images locally"
        echo ""
        echo "Examples:"
        echo "  $0 latest show"
        echo "  $0 v1.0 push"
        echo ""
        show_images
        ;;
esac
