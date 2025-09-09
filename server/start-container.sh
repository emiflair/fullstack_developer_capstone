#!/bin/bash

# 🐳 Car Dealership Containerized Startup Script
# Run this script after cloning the repo and switching to containerize-k8s branch

echo "🐳 Starting Car Dealership Containerized Application"
echo "=================================================="

# Check if we're in the right directory
if [ ! -f "Dockerfile" ]; then
    echo "❌ Error: Dockerfile not found. Please run this script from the server directory."
    echo "   Expected path: fullstack_developer_capstone/server/"
    exit 1
fi

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Error: Docker is not running. Please start Docker first."
    exit 1
fi

# Check if container already exists
if [ "$(docker ps -q -f name=dealership-app)" ]; then
    echo "🟡 Container 'dealership-app' is already running"
    echo "   Stopping existing container..."
    docker stop dealership-app
    docker rm dealership-app
fi

echo "🔨 Building Docker image..."
docker build -t us.icr.io/sn-labs-emifeaustin0/dealership:latest .

if [ $? -eq 0 ]; then
    echo "✅ Docker image built successfully"
else
    echo "❌ Failed to build Docker image"
    exit 1
fi

echo "🚀 Starting container..."
docker run -d --name dealership-app \
  -p 8000:8000 \
  -e DJANGO_SETTINGS_MODULE=djangoproj.settings \
  -e backend_url=http://localhost:3030 \
  -e sentiment_analyzer_url=https://sentianalyzer.1zsxdruquzxr.us-south.codeengine.appdomain.cloud/ \
  us.icr.io/sn-labs-emifeaustin0/dealership:latest

if [ $? -eq 0 ]; then
    echo "✅ Container started successfully"
    echo ""
    echo "🌐 Application is starting up..."
    echo "   Please wait 10-15 seconds for the application to fully initialize"
    echo ""
    sleep 5
    
    # Check if container is still running
    if [ "$(docker ps -q -f name=dealership-app)" ]; then
        echo "📊 Container Status:"
        docker ps --filter name=dealership-app --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
        echo ""
        echo "🎉 Success! Your application is running at:"
        echo "   📱 http://localhost:8000"
        echo ""
        echo "🔧 Useful commands:"
        echo "   View logs:    docker logs dealership-app"
        echo "   Stop app:     docker stop dealership-app"
        echo "   Remove app:   docker rm dealership-app"
        echo "   Container stats: docker stats dealership-app"
    else
        echo "❌ Container failed to start. Check logs:"
        docker logs dealership-app
    fi
else
    echo "❌ Failed to start container"
    exit 1
fi
