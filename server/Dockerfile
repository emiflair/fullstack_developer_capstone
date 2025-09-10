###############################
# Frontend build stage
###############################
FROM node:18-bullseye-slim AS frontend-build

WORKDIR /opt/frontend

# Install deps using lockfile when available
COPY frontend/package*.json ./
RUN npm ci --silent || npm install --silent

# Copy the rest of the frontend and build
COPY frontend ./
ENV GENERATE_SOURCEMAP=false
RUN npm run build

###############################
# Backend runtime image
###############################
FROM python:3.12.0-slim-bookworm
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1
ENV APP=/app
# Change the workdir.
WORKDIR $APP
# Install the requirements
COPY requirements.txt $APP
RUN pip3 install -r requirements.txt
# Copy the rest of the files
COPY . $APP

# Bring in the React build so Django can serve index.html
COPY --from=frontend-build /opt/frontend/build $APP/frontend/build

EXPOSE 8000
RUN chmod +x /app/entrypoint.sh
ENTRYPOINT ["/bin/bash", "/app/entrypoint.sh"]
CMD ["gunicorn", "--bind", ":8000", "--workers", "3", "djangoproj.wsgi"]
