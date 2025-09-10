#!/bin/bash

# 🐳 Car Dealership Containerized Application (Root Level)
# This script containerizes the working start-direct.sh approach

echo "🐳 Starting Car Dealership Containerized Application (Version 2)"
echo "================================================================="

# Check if we're in the right directory
if [ ! -f "Dockerfile" ]; then
    echo "❌ Error: Dockerfile not found. Please run this script from the project root directory."
    echo "   Expected path: fullstack_developer_capstone/"
    exit 1
fi

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Error: Docker is not running. Please start Docker first."
    exit 1
fi

# Stop and remove existing container if it exists
CONTAINER_NAME="dealership-fullstack"
if [ "$(docker ps -q -f name=$CONTAINER_NAME)" ]; then
    echo "🟡 Stopping existing container '$CONTAINER_NAME'..."
    docker stop $CONTAINER_NAME
fi

if [ "$(docker ps -aq -f name=$CONTAINER_NAME)" ]; then
    echo "🗑️ Removing existing container '$CONTAINER_NAME'..."
    docker rm $CONTAINER_NAME
fi

echo "🔨 Building Docker image..."
docker build -t dealership-fullstack:latest .

if [ $? -eq 0 ]; then
    echo "✅ Docker image built successfully"
else
    echo "❌ Failed to build Docker image"
    exit 1
fi

echo "🚀 Starting containerized application..."

# Detect environment and set appropriate networking
if [ -d "/home/theia" ] || [ -n "$THEIA_WORKSPACE_ROOT" ] || [ "$USER" = "theia" ]; then
    # Cloud IDE environment - use host networking for direct localhost access
    echo "   🌐 Cloud environment detected, using host networking"
    
    docker run -d --name $CONTAINER_NAME \
      --network host \
      -e DJANGO_SETTINGS_MODULE=djangoproj.settings \
      -e BACKEND_URL=http://localhost:3030 \
      dealership-fullstack:latest
else
    # Local environment - use port mapping
    echo "   💻 Local environment detected, using port mapping"
    
    docker run -d --name $CONTAINER_NAME \
      -p 8000:8000 \
      -p 3030:3030 \
      -e DJANGO_SETTINGS_MODULE=djangoproj.settings \
      -e BACKEND_URL=http://localhost:3030 \
      dealership-fullstack:latest
fi

if [ $? -eq 0 ]; then
    echo "✅ Container started successfully"
    echo ""
    echo "🌐 Application is starting up..."
    echo "   Please wait 15-20 seconds for the application to fully initialize"
    echo ""
    
    # Wait a moment for startup
    sleep 10
    
    # Check if container is still running
    if [ "$(docker ps -q -f name=$CONTAINER_NAME)" ]; then
        echo "📊 Container Status:"
        docker ps --filter name=$CONTAINER_NAME --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
        echo ""
        
        # Test the application
        echo "🧪 Testing application..."
        sleep 5
        
        if curl -s http://localhost:8000/djangoapp/get_dealers/ | grep -q '"status": 200' 2>/dev/null; then
            echo "✅ Dealers endpoint working"
        else
            echo "⚠️  Dealers endpoint may need a moment to initialize"
        fi
        
        echo ""
        echo "🎉 Success! Your application is running at:"
        
        if [ -d "/home/theia" ] || [ -n "$THEIA_WORKSPACE_ROOT" ]; then
            # Cloud IDE
            echo "   🌐 Cloud: https://$(whoami)-8000.theiadockernext-0-labs-prod-theiak8s-4-tor01.proxy.cognitiveclass.ai"
        else
            # Local
            echo "   💻 Local: http://localhost:8000"
            echo "   📱 Mobile: http://$(ifconfig | grep "inet " | grep -v 127.0.0.1 | awk '{print $2}' | head -1 2>/dev/null || echo "localhost"):8000"
        fi
        
        echo "   🔧 Database API: http://localhost:3030"
        echo ""
        echo "✨ Features available:"
        echo "   ✅ User Registration & Login"
        echo "   ✅ View Dealerships (with full data!)"
        echo "   ✅ Add & View Reviews"
        echo "   ✅ Sentiment Analysis"
        echo ""
        echo "🔧 Useful commands:"
        echo "   View application logs:  docker logs $CONTAINER_NAME"
        echo "   Follow logs:           docker logs -f $CONTAINER_NAME"
        echo "   Stop container:        docker stop $CONTAINER_NAME"
        echo "   Remove container:      docker rm $CONTAINER_NAME"
        echo "   Container stats:       docker stats $CONTAINER_NAME"
        echo "   Execute into container: docker exec -it $CONTAINER_NAME bash"
    else
        echo "❌ Container failed to start. Check logs:"
        docker logs $CONTAINER_NAME
    fi
else
    echo "❌ Failed to start container"
    exit 1
fi
