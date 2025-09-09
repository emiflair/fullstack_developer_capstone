#!/bin/bash

# 🚀 Complete Car Dealership Application Startup Script
# Starts both the database API and the containerized Django application

echo "🚀 Starting Complete Car Dealership Application"
echo "=============================================="

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

# Check if Node.js is available for the database API
if ! command -v node &> /dev/null; then
    echo "❌ Error: Node.js is not installed. Please install Node.js first."
    exit 1
fi

echo "🗃️ Starting Database API Service..."
# Kill any existing processes on port 3030
lsof -ti:3030 | xargs kill -9 2>/dev/null || true

# Start database API in the background
cd database
npm install > /dev/null 2>&1
nohup node app.js > ../database-api.log 2>&1 &
DATABASE_PID=$!
cd ..

# Wait for database API to start
sleep 3

# Test if database API is running
if curl -s --fail http://localhost:3030/fetchDealers > /dev/null; then
    echo "✅ Database API started successfully on port 3030"
    echo "   📊 PID: $DATABASE_PID"
else
    echo "❌ Failed to start Database API"
    kill $DATABASE_PID 2>/dev/null || true
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
    kill $DATABASE_PID 2>/dev/null || true
    exit 1
fi

echo "🚀 Starting Django container..."
docker run -d --name dealership-app \
  -p 8000:8000 \
  --add-host=host.docker.internal:host-gateway \
  -e DJANGO_SETTINGS_MODULE=djangoproj.settings \
  -e backend_url=http://host.docker.internal:3030 \
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
        echo "📊 Services Status:"
        echo "   🗃️  Database API: Running on port 3030 (PID: $DATABASE_PID)"
        echo "   🐳 Django App:   Running in container"
        docker ps --filter name=dealership-app --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
        echo ""
        echo "🎉 Success! Your complete application is running:"
        echo "   📱 Frontend: http://localhost:8000"
        echo "   🗃️ API:      http://localhost:3030"
        echo ""
        echo "🔧 Management commands:"
        echo "   Django logs:      docker logs dealership-app"
        echo "   Database logs:    tail -f database-api.log"
        echo "   Stop Django:      docker stop dealership-app"
        echo "   Stop Database:    kill $DATABASE_PID"
        echo "   Stop all:         ./stop-all.sh"
        
        # Create stop script
        cat > stop-all.sh << 'EOF'
#!/bin/bash
echo "🛑 Stopping all services..."
docker stop dealership-app 2>/dev/null || true
docker rm dealership-app 2>/dev/null || true
lsof -ti:3030 | xargs kill -9 2>/dev/null || true
echo "✅ All services stopped"
EOF
        chmod +x stop-all.sh
        echo "   📜 Created stop-all.sh script for easy cleanup"
        
    else
        echo "❌ Container failed to start. Check logs:"
        docker logs dealership-app
        kill $DATABASE_PID 2>/dev/null || true
    fi
else
    echo "❌ Failed to start container"
    kill $DATABASE_PID 2>/dev/null || true
    exit 1
fi
