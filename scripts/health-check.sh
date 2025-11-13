#!/bin/bash

# Health check script for all services
# Usage: ./scripts/health-check.sh

set -e

echo "🔍 Running health checks..."
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if services are running
check_service() {
    local service=$1
    if docker-compose ps | grep -q "$service.*Up"; then
        echo -e "${GREEN}✅ $service is running${NC}"
        return 0
    else
        echo -e "${RED}❌ $service is not running${NC}"
        return 1
    fi
}

# Check HTTP endpoint
check_endpoint() {
    local name=$1
    local url=$2
    if curl -f -s "$url" > /dev/null 2>&1; then
        echo -e "${GREEN}✅ $name is accessible${NC}"
        return 0
    else
        echo -e "${RED}❌ $name is not accessible${NC}"
        return 1
    fi
}

# Check services
echo "📦 Checking Docker containers..."
check_service "frontend"
check_service "backend"
check_service "db"
check_service "prometheus"
check_service "grafana"
echo ""

# Check endpoints
echo "🌐 Checking HTTP endpoints..."
sleep 2  # Give services time to respond

check_endpoint "Frontend" "http://localhost"
check_endpoint "Backend API" "http://localhost:5000/api/health"
check_endpoint "Prometheus" "http://localhost:9090"
check_endpoint "Grafana" "http://localhost:3000/api/health"
echo ""

# Check database connection
echo "🗄️  Checking database..."
if docker-compose exec -T db pg_isready -U postgres > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Database is ready${NC}"
else
    echo -e "${RED}❌ Database is not ready${NC}"
fi
echo ""

# Summary
echo "📊 Summary:"
echo "Run 'docker-compose ps' to see all container statuses"
echo "Run 'docker-compose logs <service>' to view logs"
echo ""
echo "Access points:"
echo "  - Frontend: http://localhost"
echo "  - Backend:  http://localhost:5000/api"
echo "  - Grafana:  http://localhost:3000 (admin/admin)"
echo "  - Prometheus: http://localhost:9090"

