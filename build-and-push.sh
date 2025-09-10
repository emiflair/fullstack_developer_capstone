#!/bin/bash

# 🔨 Build and Push Script for IBM Cloud Registry
# This script builds the Docker image and pushes it to IBM Cloud Registry

echo "🔨 Building and Pushing Car Dealership Image to IBM Cloud Registry"
echo "=================================================================="

# Set your namespace
NAMESPACE="sn-labs-emifeaustin0"
echo "📍 Using namespace: $NAMESPACE"

# Step 1: Export namespace
echo "🔧 Setting up IBM Cloud namespace..."
MY_NAMESPACE=$(ibmcloud cr namespaces | grep sn-labs-)
export MY_NAMESPACE=$MY_NAMESPACE
echo "✅ Namespace: $MY_NAMESPACE"

# Step 2: Build Docker image
echo "🔨 Building Docker image..."
echo "   Command: docker build -t us.icr.io/$NAMESPACE/dealership ."
docker build -t us.icr.io/$NAMESPACE/dealership .

if [ $? -eq 0 ]; then
    echo "✅ Docker image built successfully"
else
    echo "❌ Failed to build Docker image"
    exit 1
fi

# Step 3: Push to IBM Cloud Registry  
echo "📤 Pushing image to IBM Cloud Registry..."
echo "   Command: docker push us.icr.io/$NAMESPACE/dealership"
docker push us.icr.io/$NAMESPACE/dealership

if [ $? -eq 0 ]; then
    echo "✅ Image pushed successfully!"
    echo "📍 Image location: us.icr.io/$NAMESPACE/dealership"
    echo ""
    echo "🚀 Next steps:"
    echo "   1. Update your deployment.yaml to reference: us.icr.io/$NAMESPACE/dealership"
    echo "   2. Deploy with: kubectl apply -f deployment.yaml"
    echo "   3. Set up port forwarding: kubectl port-forward deployment.apps/dealership 8000:8000"
else
    echo "❌ Failed to push image to registry"
    exit 1
fi
