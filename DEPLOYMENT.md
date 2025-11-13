# Deployment Guide

This guide provides detailed instructions for deploying the Production Simulation Application on Oracle Cloud Infrastructure (OCI) or VirtualBox VMs.

## Prerequisites

- Oracle Cloud account (or VirtualBox installed)
- SSH access to your VMs
- Basic knowledge of Docker and Linux

## Option 1: Single VM Deployment (Recommended for Demo)

### Step 1: Create VM on Oracle Cloud

1. Log in to Oracle Cloud Console
2. Navigate to Compute → Instances
3. Create a new instance:
   - **Shape**: VM.Standard.E2.1.Micro (Free Tier) or VM.Standard2.1 (2 OCPUs, 4GB RAM)
   - **OS**: Ubuntu 22.04 LTS
   - **Networking**: Allow HTTP (80), HTTPS (443), and custom ports (3000, 9090)
   - **SSH Key**: Upload your public SSH key

### Step 2: Connect to VM

```bash
ssh -i ~/.ssh/your_key ubuntu@<VM_PUBLIC_IP>
```

### Step 3: Install Docker and Docker Compose

```bash
# Update system
sudo apt-get update
sudo apt-get upgrade -y

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Log out and back in for group changes to take effect
exit
```

### Step 4: Clone Repository

```bash
# Reconnect to VM
ssh -i ~/.ssh/your_key ubuntu@<VM_PUBLIC_IP>

# Clone repository
git clone <your-repo-url>
cd prod_simulation
```

### Step 5: Configure Environment

```bash
# Copy example env file
cp .env.example .env

# Edit with production values
nano .env
# Change passwords and other sensitive values
```

### Step 6: Deploy Application

```bash
# Start all services
docker-compose up -d

# Check status
docker-compose ps

# View logs
docker-compose logs -f
```

### Step 7: Configure Firewall

```bash
# Allow required ports
sudo ufw allow 22/tcp    # SSH
sudo ufw allow 80/tcp    # Frontend
sudo ufw allow 3000/tcp  # Grafana
sudo ufw allow 9090/tcp  # Prometheus
sudo ufw enable
```

### Step 8: Access Application

- Frontend: http://<VM_PUBLIC_IP>
- Grafana: http://<VM_PUBLIC_IP>:3000 (admin/admin)
- Prometheus: http://<VM_PUBLIC_IP>:9090

## Option 2: Multi-VM Deployment

### Architecture

- **VM 1**: Frontend + Backend (2GB RAM)
- **VM 2**: Database (2GB RAM)
- **VM 3**: Monitoring (2GB RAM)

### VM 1: Frontend + Backend

```bash
# Install Docker (same as above)

# Create docker-compose.frontend-backend.yml
cat > docker-compose.frontend-backend.yml << EOF
version: '3.8'
services:
  backend:
    build: ./backend
    environment:
      DB_HOST: <VM2_PRIVATE_IP>
      DB_PORT: 5432
      DB_NAME: prod_sim
      DB_USER: postgres
      DB_PASSWORD: <secure_password>
    ports:
      - "5000:5000"
    networks:
      - app-network

  frontend:
    build: ./frontend
    ports:
      - "80:80"
    depends_on:
      - backend
    networks:
      - app-network

networks:
  app-network:
    driver: bridge
EOF

docker-compose -f docker-compose.frontend-backend.yml up -d
```

### VM 2: Database

```bash
# Install Docker

# Create docker-compose.db.yml
cat > docker-compose.db.yml << EOF
version: '3.8'
services:
  db:
    image: postgres:15-alpine
    environment:
      POSTGRES_DB: prod_sim
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: <secure_password>
    volumes:
      - postgres_data:/var/lib/postgresql/data
    ports:
      - "5432:5432"
    networks:
      - db-network

networks:
  db-network:
    driver: bridge

volumes:
  postgres_data:
EOF

# Configure PostgreSQL to accept connections from VM1
# Edit /etc/postgresql/postgresql.conf (if installed via package)
# Or use Docker environment variables

docker-compose -f docker-compose.db.yml up -d

# Configure firewall to allow connections from VM1 only
sudo ufw allow from <VM1_PRIVATE_IP> to any port 5432
```

### VM 3: Monitoring

```bash
# Install Docker

# Update prometheus.yml to point to VM1 backend
# Edit monitoring/prometheus.yml:
#   - targets: ['<VM1_PRIVATE_IP>:5000']

docker-compose -f docker-compose.yml up -d prometheus grafana
```

## Option 3: VirtualBox Local Deployment

### Step 1: Create VMs in VirtualBox

1. Create 2-3 VMs with Ubuntu 22.04
2. Allocate resources:
   - VM 1 (App): 2GB RAM, 1 CPU
   - VM 2 (DB): 2GB RAM, 1 CPU (optional)
   - VM 3 (Monitoring): 2GB RAM, 1 CPU (optional)

### Step 2: Network Configuration

- **Option A**: NAT with port forwarding
  - VM Settings → Network → Advanced → Port Forwarding
  - Forward: Host 8080 → Guest 80
  - Forward: Host 3000 → Guest 3000

- **Option B**: Bridged Network
  - VM Settings → Network → Bridged Adapter
  - VMs will get IPs on your local network

### Step 3: Follow Single VM Deployment Steps

Use the same steps as Oracle Cloud deployment.

## Production Nginx Reverse Proxy

For production, use an external Nginx instance on the host or a separate VM:

### Install Nginx

```bash
sudo apt-get update
sudo apt-get install nginx
```

### Create Configuration

```bash
sudo nano /etc/nginx/sites-available/prod-sim
```

```nginx
upstream backend {
    server localhost:5000;
}

server {
    listen 80;
    server_name your-domain.com;

    # Frontend
    location / {
        proxy_pass http://localhost:80;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # Backend API
    location /api {
        proxy_pass http://backend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # Health check
    location /health {
        proxy_pass http://backend/api/health;
    }
}
```

### Enable and Restart

```bash
sudo ln -s /etc/nginx/sites-available/prod-sim /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

## SSL/HTTPS Setup (Optional)

### Using Let's Encrypt

```bash
sudo apt-get install certbot python3-certbot-nginx
sudo certbot --nginx -d your-domain.com
```

## Monitoring and Maintenance

### View Logs

```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f backend

# Last 100 lines
docker-compose logs --tail=100 backend
```

### Update Application

```bash
# Pull latest code
git pull

# Rebuild and restart
docker-compose up -d --build

# Or use deploy script
./deploy.sh
```

### Backup Database

```bash
# Create backup
docker-compose exec db pg_dump -U postgres prod_sim > backup_$(date +%Y%m%d).sql

# Restore backup
docker-compose exec -T db psql -U postgres prod_sim < backup_20240101.sql
```

### Health Checks

```bash
# Application health
curl http://localhost/api/health

# Prometheus targets
curl http://localhost:9090/api/v1/targets

# Grafana health
curl http://localhost:3000/api/health
```

## Troubleshooting

### Port Already in Use

```bash
# Find process using port
sudo lsof -i :80
sudo lsof -i :5000

# Kill process
sudo kill -9 <PID>
```

### Database Connection Issues

```bash
# Test connection
docker-compose exec backend python -c "import psycopg2; psycopg2.connect(host='db', dbname='prod_sim', user='postgres', password='postgres')"

# Check database logs
docker-compose logs db
```

### Container Won't Start

```bash
# Check container logs
docker-compose logs <service_name>

# Check container status
docker-compose ps

# Restart service
docker-compose restart <service_name>
```

### Out of Memory

```bash
# Check memory usage
docker stats

# Increase swap (if needed)
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
```

## Security Checklist

- [ ] Change all default passwords
- [ ] Use strong database passwords
- [ ] Configure firewall rules
- [ ] Enable HTTPS/TLS
- [ ] Use secrets management
- [ ] Regularly update images
- [ ] Monitor logs for suspicious activity
- [ ] Restrict SSH access
- [ ] Use non-root users in containers
- [ ] Enable automatic security updates

## Performance Tuning

### Database

```sql
-- Increase connection pool
-- Edit docker-compose.yml: add environment variables
POSTGRES_MAX_CONNECTIONS=100
```

### Backend

```python
# Increase Gunicorn workers
# Edit backend/Dockerfile CMD:
CMD ["gunicorn", "--workers", "4", "--threads", "2", ...]
```

### Frontend

```nginx
# Enable caching in nginx.conf
location ~* \.(jpg|jpeg|png|gif|ico|css|js)$ {
    expires 1y;
    add_header Cache-Control "public, immutable";
}
```

## Next Steps

1. Set up automated backups
2. Configure alerting in Grafana
3. Set up log aggregation (Loki, ELK)
4. Implement blue-green deployments
5. Add load balancing for multiple instances
6. Set up monitoring alerts

