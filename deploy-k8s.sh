#!/bin/bash

# 🚢 Kubernetes Deployment Script for Car Dealership Application
# This script builds, pushes to IBM Cloud Registry, and deploys to Kubernetes

echo "🚢 Starting Kubernetes Deployment for Car Dealership Application"
echo "================================================================"

# Set your namespace
NAMESPACE="sn-labs-emifeaustin0"
echo "📍 Using namespace: $NAMESPACE"

# Step 1: Export and verify namespace
echo "🔧 Setting up IBM Cloud namespace..."
MY_NAMESPACE=$(ibmcloud cr namespaces | grep sn-labs-)
if [ -z "$MY_NAMESPACE" ]; then
    echo "❌ Error: No IBM Cloud Registry namespace found"
    echo "   Please ensure you have access to IBM Cloud Registry"
    exit 1
fi

export MY_NAMESPACE=$MY_NAMESPACE
echo "✅ Namespace set: $MY_NAMESPACE"

# Step 2: Build Docker image
echo "🔨 Building Docker image..."
docker build -t us.icr.io/$NAMESPACE/dealership .

if [ $? -eq 0 ]; then
    echo "✅ Docker image built successfully"
else
    echo "❌ Failed to build Docker image"
    exit 1
fi

# Step 3: Push to IBM Cloud Registry
echo "📤 Pushing image to IBM Cloud Registry..."
docker push us.icr.io/$NAMESPACE/dealership

if [ $? -eq 0 ]; then
    echo "✅ Image pushed successfully to us.icr.io/$NAMESPACE/dealership"
else
    echo "❌ Failed to push image to registry"
    exit 1
fi

# Step 4: Update deployment.yaml with correct namespace
echo "📝 Updating deployment configuration..."
if [ ! -f "server/deployment.yaml" ]; then
    echo "❌ Error: deployment.yaml not found in server directory"
    exit 1
fi

# Create updated deployment file with correct image
sed "s/us.icr.io\/sn-labs-emifeaustin0\/dealership:latest/us.icr.io\/$NAMESPACE\/dealership:latest/g" server/deployment.yaml > deployment-updated.yaml

echo "✅ Deployment configuration updated"

# Step 5: Deploy to Kubernetes
echo "🚀 Deploying to Kubernetes..."
kubectl apply -f deployment-updated.yaml

if [ $? -eq 0 ]; then
    echo "✅ Deployment created successfully"
else
    echo "❌ Failed to deploy to Kubernetes"
    exit 1
fi

# Step 6: Wait for deployment to be ready
echo "⏳ Waiting for deployment to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/dealership

if [ $? -eq 0 ]; then
    echo "✅ Deployment is ready"
else
    echo "⚠️  Deployment may still be starting up"
fi

# Step 7: Check deployment status
echo "📊 Checking deployment status..."
kubectl get deployment dealership
kubectl get pods -l run=dealership

# Step 8: Set up port forwarding
echo "🌐 Setting up port forwarding..."
echo "   Running: kubectl port-forward deployment.apps/dealership 8000:8000"
echo ""
echo "🎉 Deployment completed! To access your application:"
echo ""
echo "1. Port forwarding will start automatically"
echo "2. Open your browser and go to: http://localhost:8000"
echo "3. Or use the Skills Network Toolbox:"
echo "   - Click 'Skills Network' button"
echo "   - Click 'OTHER'"
echo "   - Click 'Launch Application'"
echo "   - Enter port: 8000"
echo ""
echo "🔧 Useful Kubernetes commands:"
echo "   View pods:              kubectl get pods"
echo "   View deployment:        kubectl get deployment dealership"
echo "   View logs:              kubectl logs -l run=dealership"
echo "   Delete deployment:      kubectl delete deployment dealership"
echo "   Describe deployment:    kubectl describe deployment dealership"
echo ""
echo "🛑 To stop port forwarding, press Ctrl+C"
echo ""

# Start port forwarding (this will run in foreground)
kubectl port-forward deployment.apps/dealership 8000:8000
