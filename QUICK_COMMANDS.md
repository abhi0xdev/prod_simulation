# Quick Command Reference

## 🚀 Local Testing

```bash
# Start everything
docker-compose up -d

# View logs
docker-compose logs -f

# Check status
docker-compose ps

# Health check
./scripts/health-check.sh

# Stop everything
docker-compose down

# Rebuild after code changes
docker-compose up -d --build
```

## 🧪 Testing Endpoints

```bash
# Frontend
curl http://localhost

# Backend health
curl http://localhost:5000/api/health

# Get items
curl http://localhost:5000/api/items

# Create item
curl -X POST http://localhost:5000/api/items \
  -H "Content-Type: application/json" \
  -d '{"name": "Test Item"}'

# Delete item (replace 1 with ID)
curl -X DELETE http://localhost:5000/api/items/1
```

## 📦 Git & GitHub

```bash
# Initialize (if needed)
git init

# Check status
git status

# Stage all files
git add .

# Commit
git commit -m "Your message"

# Add remote (first time)
git remote add origin https://github.com/USERNAME/REPO.git

# Push (first time)
git push -u origin main

# Push (subsequent)
git push

# Pull latest
git pull
```

## 🐳 Docker Commands

```bash
# View running containers
docker ps

# View all containers
docker ps -a

# View logs
docker logs <container_name>

# Execute command in container
docker exec -it <container_name> /bin/sh

# Remove all stopped containers
docker container prune

# Remove unused images
docker image prune -a
```

## 🔍 Troubleshooting

```bash
# Check if port is in use (Windows)
netstat -ano | findstr :80

# Check if port is in use (Linux/Mac)
lsof -i :80

# Clean Docker system
docker system prune -a

# Reset everything
docker-compose down -v
docker-compose up -d --build
```

## 📊 Service URLs

- **Frontend**: http://localhost
- **Backend API**: http://localhost:5000/api
- **Prometheus**: http://localhost:9090
- **Grafana**: http://localhost:3000 (admin/admin)

## 🔐 Default Credentials

- **Grafana**: admin / admin
- **PostgreSQL**: postgres / postgres
- **Database**: prod_sim

⚠️ **Change these in production!**

