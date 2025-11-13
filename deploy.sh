#!/bin/bash

# Deployment script for production
# Usage: ./deploy.sh [environment]

set -e

ENVIRONMENT=${1:-production}
COMPOSE_FILE="docker-compose.yml"

echo "Deploying to $ENVIRONMENT environment..."

# Pull latest images
echo "Pulling latest images..."
docker-compose -f $COMPOSE_FILE pull

# Stop existing containers
echo "Stopping existing containers..."
docker-compose -f $COMPOSE_FILE down

# Start new containers
echo "Starting new containers..."
docker-compose -f $COMPOSE_FILE up -d

# Wait for services to be healthy
echo "Waiting for services to be healthy..."
sleep 10

# Check service status
echo "Service status:"
docker-compose -f $COMPOSE_FILE ps

# Health check
echo "Performing health check..."
if curl -f http://localhost/api/health > /dev/null 2>&1; then
    echo "✅ Deployment successful! Application is healthy."
else
    echo "⚠️  Health check failed. Check logs with: docker-compose logs"
    exit 1
fi

echo "Deployment complete!"

