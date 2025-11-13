# Production Simulation Application

A full-stack web application demonstrating a production-ready DevOps setup with containerization, CI/CD, and monitoring.

## Architecture

```
User → Frontend (Nginx/React) → Backend (Flask) → Database (PostgreSQL)
                                      ↓
                              Prometheus → Grafana
```

## Components

- **Frontend**: React app served by Nginx (Port 80)
- **Backend**: Flask REST API (Port 5000)
- **Database**: PostgreSQL (Port 5432)
- **Monitoring**: Prometheus (Port 9090) + Grafana (Port 3000)

## Quick Start (Local Development)

### Prerequisites

- Docker and Docker Compose installed
- Git

### Steps

1. **Clone the repository** (or use current directory if starting fresh)
   ```bash
   git clone <your-repo-url>
   cd prod_simulation
   ```

2. **Start all services**
   ```bash
   docker-compose up -d
   ```

3. **Access the application**
   - Frontend: http://localhost
   - Backend API: http://localhost:5000/api
   - Prometheus: http://localhost:9090
   - Grafana: http://localhost:3000 (admin/admin)

4. **View logs**
   ```bash
   docker-compose logs -f
   ```

5. **Stop services**
   ```bash
   docker-compose down
   ```

📖 **For detailed testing and GitHub setup instructions, see [TESTING_AND_GITHUB.md](TESTING_AND_GITHUB.md)**

## Project Structure

```
prod_simulation/
├── frontend/              # React frontend
│   ├── src/
│   ├── public/
│   ├── Dockerfile
│   └── nginx.conf
├── backend/              # Flask API
│   ├── app.py
│   ├── requirements.txt
│   └── Dockerfile
├── monitoring/           # Prometheus & Grafana configs
│   ├── prometheus.yml
│   └── grafana/
├── docker-compose.yml    # Local development
├── Jenkinsfile          # Jenkins CI/CD
├── .github/workflows/    # GitHub Actions CI/CD
└── README.md
```

## Deployment on Oracle Cloud / VM

### Option 1: Single VM Deployment

1. **SSH into your VM**
   ```bash
   ssh user@your-vm-ip
   ```

2. **Install Docker and Docker Compose**
   ```bash
   # Ubuntu/Debian
   curl -fsSL https://get.docker.com -o get-docker.sh
   sudo sh get-docker.sh
   sudo usermod -aG docker $USER
   sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
   sudo chmod +x /usr/local/bin/docker-compose
   ```

3. **Clone and deploy**
   ```bash
   git clone <your-repo-url>
   cd prod_simulation
   docker-compose up -d
   ```

4. **Configure firewall**
   ```bash
   sudo ufw allow 80/tcp
   sudo ufw allow 3000/tcp
   sudo ufw allow 9090/tcp
   sudo ufw enable
   ```

### Option 2: Multi-VM Deployment

#### VM 1: Frontend + Backend
```bash
# Create docker-compose.frontend-backend.yml
# Deploy frontend and backend services
```

#### VM 2: Database
```bash
# Deploy PostgreSQL with exposed port
# Update DB_HOST in backend environment
```

#### VM 3: Monitoring
```bash
# Deploy Prometheus and Grafana
# Update prometheus.yml to scrape backend from VM1
```

### Nginx Reverse Proxy (Production)

For production, use an external Nginx instance:

1. **Install Nginx on host**
   ```bash
   sudo apt-get update
   sudo apt-get install nginx
   ```

2. **Create Nginx config** (`/etc/nginx/sites-available/prod-sim`)
   ```nginx
   server {
       listen 80;
       server_name your-domain.com;

       location / {
           proxy_pass http://localhost:80;
           proxy_set_header Host $host;
           proxy_set_header X-Real-IP $remote_addr;
       }

       location /api {
           proxy_pass http://localhost:5000;
           proxy_set_header Host $host;
           proxy_set_header X-Real-IP $remote_addr;
       }
   }
   ```

3. **Enable and restart**
   ```bash
   sudo ln -s /etc/nginx/sites-available/prod-sim /etc/nginx/sites-enabled/
   sudo nginx -t
   sudo systemctl restart nginx
   ```

## CI/CD Setup

### GitHub Actions

1. Push code to GitHub
2. GitHub Actions automatically builds and pushes Docker images
3. Configure deployment step to SSH into your server and update containers

### Jenkins

1. **Install Jenkins**
   ```bash
   # On Ubuntu
   wget -q -O - https://pkg.jenkins.io/debian/jenkins.io-2023.key | sudo apt-key add -
   sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
   sudo apt-get update
   sudo apt-get install jenkins
   ```

2. **Configure Jenkins**
   - Install Docker and Docker Pipeline plugins
   - Create new Pipeline job
   - Point to Jenkinsfile in repository
   - Configure credentials for Docker registry and SSH

## Monitoring

### Prometheus

- Access: http://localhost:9090
- Scrapes metrics from backend at `/metrics` endpoint
- Metrics include:
  - HTTP request count
  - Request duration
  - Error rates

### Grafana

- Access: http://localhost:3000
- Default credentials: admin/admin
- Pre-configured Prometheus datasource
- Dashboard shows backend metrics

## API Endpoints

- `GET /api/health` - Health check
- `GET /api/items` - Get all items
- `POST /api/items` - Create item (body: `{"name": "string"}`)
- `DELETE /api/items/:id` - Delete item
- `GET /metrics` - Prometheus metrics

## Environment Variables

### Backend
- `DB_HOST` - Database host (default: db)
- `DB_PORT` - Database port (default: 5432)
- `DB_NAME` - Database name (default: prod_sim)
- `DB_USER` - Database user (default: postgres)
- `DB_PASSWORD` - Database password (default: postgres)
- `PORT` - Backend port (default: 5000)

### Frontend
- `REACT_APP_API_URL` - Backend API URL (default: http://localhost:5000/api)

## Troubleshooting

### Database connection issues
```bash
docker-compose logs db
docker-compose exec db psql -U postgres -d prod_sim
```

### Backend not starting
```bash
docker-compose logs backend
docker-compose exec backend python app.py
```

### Frontend not loading
```bash
docker-compose logs frontend
# Check if backend is accessible from frontend container
docker-compose exec frontend curl http://backend:5000/api/health
```

## Security Notes

⚠️ **For Production:**
- Change default passwords (PostgreSQL, Grafana)
- Use secrets management (Docker secrets, Vault)
- Enable HTTPS/TLS
- Configure firewall rules
- Use non-root users in containers
- Regularly update base images

## License

MIT

# prod_simulation
