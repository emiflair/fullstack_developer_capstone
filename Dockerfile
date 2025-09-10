# Multi-stage Dockerfile for Full-Stack Car Dealership Application
# This containerizes the working start-direct.sh approach

# Stage 1: Frontend Build
FROM node:18-bullseye-slim AS frontend-build
WORKDIR /opt/frontend
COPY server/frontend/package*.json ./
RUN npm ci --silent || npm install --silent
COPY server/frontend ./
RUN GENERATE_SOURCEMAP=false npm run build

# Stage 2: Database API Build  
FROM node:18-bullseye-slim AS database-build
WORKDIR /opt/database
COPY server/database/package*.json ./
RUN npm ci --silent || npm install --silent
COPY server/database ./

# Stage 3: Main Python Application
FROM python:3.12.0-slim-bookworm

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js for running the database API
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs

# Set working directory
WORKDIR /app

# Copy Python requirements and install
COPY server/requirements.txt ./
RUN pip3 install --no-cache-dir -r requirements.txt

# Copy the entire application
COPY . /app/

# Copy built frontend from frontend-build stage
COPY --from=frontend-build /opt/frontend/build /app/server/frontend/build

# Copy database API with dependencies from database-build stage
COPY --from=database-build /opt/database /app/server/database

# Create the startup script based on start-direct.sh logic
RUN echo '#!/bin/bash\n\
echo "🐳 Containerized Car Dealership Application"\n\
echo "============================================"\n\
\n\
# Set Python path\n\
export PYTHONPATH="/usr/local/lib/python3.12/site-packages:$PYTHONPATH"\n\
\n\
# Go to server directory\n\
cd /app/server\n\
\n\
echo "🗃️ Running Django migrations..."\n\
python3 manage.py migrate --noinput\n\
\n\
# Start database API in background\n\
echo "🚀 Starting Database API..."\n\
cd database\n\
node app.js &\n\
DATABASE_PID=$!\n\
cd ..\n\
\n\
# Wait for database to be ready\n\
echo "⏳ Waiting for Database API to start..."\n\
sleep 5\n\
\n\
# Test database connection\n\
for i in {1..10}; do\n\
    if curl -s http://localhost:3030/fetchDealers > /dev/null 2>&1; then\n\
        echo "✅ Database API is ready"\n\
        break\n\
    fi\n\
    echo "   Waiting for database... ($i/10)"\n\
    sleep 2\n\
done\n\
\n\
echo "🚀 Starting Django Server..."\n\
echo "📱 Application will be available at: http://0.0.0.0:8000"\n\
echo "🛑 Container running - access via port mapping"\n\
\n\
# Trap for cleanup\n\
trap '\''echo ""; echo "🛑 Stopping services..."; kill $DATABASE_PID 2>/dev/null; echo "✅ Stopped"; exit'\'' INT TERM\n\
\n\
# Start Django server\n\
python3 manage.py runserver 0.0.0.0:8000 &\n\
DJANGO_PID=$!\n\
\n\
# Wait for any process to exit\n\
wait\n\
' > /app/entrypoint.sh && chmod +x /app/entrypoint.sh

# Expose ports
EXPOSE 8000 3030

# Set the entrypoint
ENTRYPOINT ["/app/entrypoint.sh"]
