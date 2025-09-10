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

# Check if database API is running and stop it if needed
if [ "$(ps aux | grep 'node app.js' | grep -v grep)" ]; then
    echo "🟡 Stopping existing Database API..."
    pkill -f "node app.js"
    sleep 2
fi

# Start Database API
echo "🔧 Starting Database API..."
cd database
if [ ! -f "app.js" ]; then
    echo "❌ Error: Database API files not found in database directory"
    exit 1
fi

# Install database dependencies if needed
if [ ! -d "node_modules" ]; then
    echo "📦 Installing Database API dependencies..."
    npm install
fi

# Start database API in background
echo "   Starting Node.js Database API on port 3030..."
nohup node app.js > ../database-api.log 2>&1 &
DATABASE_PID=$!
echo "   Database API started with PID $DATABASE_PID"
cd ..

# Wait for API to be ready
echo "   Waiting for Database API to start..."
for i in {1..15}; do
    if curl -s http://localhost:3030/fetchDealers > /dev/null 2>&1; then
        echo "   ✅ Database API is ready"
        break
    fi
    sleep 1
done

if [ $i -eq 15 ]; then
    echo "   ❌ Database API failed to start after 15 seconds"
    echo "   Check database-api.log for errors"
    exit 1
fi

echo "🔨 Building Docker image..."
docker build -t us.icr.io/sn-labs-emifeaustin0/dealership:latest .

if [ $? -eq 0 ]; then
    echo "✅ Docker image built successfully"
else
    echo "❌ Failed to build Docker image"
    exit 1
fi

echo "🚀 Starting Django container..."

# Detect environment and set appropriate backend URL
if [ -n "$CLOUD_IDE" ] || [ -f "/home/theia" ] || [ -n "$THEIA_WORKSPACE_ROOT" ]; then
    # Cloud IDE environment - use the proxy URL pattern
    # Extract username from environment or use default
    USERNAME=$(whoami 2>/dev/null || echo "emifeaustin0")
    BACKEND_URL="https://${USERNAME}-3030.theiadockernext-0-labs-prod-theiak8s-4-tor01.proxy.cognitiveclass.ai"
    echo "   🌐 Cloud environment detected, using BACKEND_URL=${BACKEND_URL}"
    
    # Test if the backend URL is reachable from host
    if ! curl -s "${BACKEND_URL}/fetchDealers" > /dev/null 2>&1; then
        echo "   ⚠️  ${BACKEND_URL} not reachable, trying alternative approaches..."
        # Try with different username patterns
        BACKEND_URL="https://emifeaustin0-3030.theiadockernext-0-labs-prod-theiak8s-4-tor01.proxy.cognitiveclass.ai"
        if ! curl -s "${BACKEND_URL}/fetchDealers" > /dev/null 2>&1; then
            # Fallback to host IP approach
            HOST_IP=$(hostname -I 2>/dev/null | awk '{print $1}' || ip route get 1 2>/dev/null | awk '{print $7}' || ifconfig 2>/dev/null | grep "inet " | grep -v 127.0.0.1 | awk '{print $2}' | head -1 || echo "127.0.0.1")
            BACKEND_URL="http://${HOST_IP}:3030"
            echo "   ⚠️  Trying host IP: ${BACKEND_URL}"
            if ! curl -s "${BACKEND_URL}/fetchDealers" > /dev/null 2>&1; then
                GATEWAY_IP=$(ip route | grep default | awk '{print $3}' 2>/dev/null || echo "172.17.0.1")
                BACKEND_URL="http://${GATEWAY_IP}:3030"
                echo "   ⚠️  Trying gateway IP: ${BACKEND_URL}"
            fi
        fi
    fi
else
    # Local environment - use host.docker.internal
    BACKEND_URL="http://host.docker.internal:3030"
    echo "   💻 Local environment detected, using BACKEND_URL=${BACKEND_URL}"
fi

docker run -d --name dealership-app \
  -p 0.0.0.0:8000:8000 \
  --add-host=host.docker.internal:host-gateway \
  -e DJANGO_SETTINGS_MODULE=djangoproj.settings \
  -e BACKEND_URL="${BACKEND_URL}" \
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
        
        # Test the application
        echo "🧪 Testing application..."
        if curl -s http://localhost:8000/djangoapp/get_dealers/ | grep -q '"status": 200'; then
            echo "✅ Dealers endpoint working"
        else
            echo "⚠️  Dealers endpoint may need a moment to initialize"
        fi
        
        echo ""
        echo "🎉 Success! Your application is running at:"
        echo "   �️  Local: http://localhost:8000"
        echo "   📱 Mobile: http://$(ifconfig | grep "inet " | grep -v 127.0.0.1 | awk '{print $2}' | head -1):8000"
        echo "   🔧 Database API: http://localhost:3030"
        echo ""
        echo "✨ Features available:"
        echo "   ✅ User Registration & Login"
        echo "   ✅ View Dealerships"
        echo "   ✅ Add & View Reviews"
        echo "   ✅ Sentiment Analysis"
        echo ""
        echo "🔧 Useful commands:"
        echo "   View Django logs:    docker logs dealership-app"
        echo "   View Database logs:  tail -f database-api.log"
        echo "   Stop Django:         docker stop dealership-app"
        echo "   Stop Database:       pkill -f 'node app.js'"
        echo "   Stop all:            docker stop dealership-app && pkill -f 'node app.js'"
        echo "   Container stats:     docker stats dealership-app"
    else
        echo "❌ Container failed to start. Check logs:"
        docker logs dealership-app
    fi
else
    echo "❌ Failed to start container"
    exit 1
fi
