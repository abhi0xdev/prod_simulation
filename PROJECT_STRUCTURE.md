# Project Structure

```
prod_simulation/
│
├── frontend/                    # React Frontend Application
│   ├── public/
│   │   └── index.html          # HTML template
│   ├── src/
│   │   ├── App.js              # Main React component
│   │   ├── index.js            # React entry point
│   │   └── index.css           # Styles
│   ├── Dockerfile              # Frontend container build
│   ├── nginx.conf              # Nginx configuration
│   ├── package.json            # Node.js dependencies
│   └── .dockerignore           # Docker ignore rules
│
├── backend/                     # Flask Backend API
│   ├── app.py                  # Main Flask application
│   ├── requirements.txt        # Python dependencies
│   ├── Dockerfile              # Backend container build
│   └── .dockerignore           # Docker ignore rules
│
├── monitoring/                  # Monitoring Configuration
│   ├── prometheus.yml          # Prometheus scrape config
│   └── grafana/
│       ├── provisioning/
│       │   ├── datasources/
│       │   │   └── prometheus.yml  # Grafana datasource
│       │   └── dashboards/
│       │       └── default.yml     # Dashboard provisioning
│       └── dashboards/
│           └── backend-metrics.json  # Backend metrics dashboard
│
├── scripts/                     # Utility Scripts
│   ├── init-db.sh              # Database initialization
│   └── health-check.sh         # Service health checks
│
├── .github/
│   └── workflows/
│       └── ci-cd.yml           # GitHub Actions CI/CD pipeline
│
├── docker-compose.yml           # Local development setup
├── docker-compose.prod.yml      # Production overrides
├── Jenkinsfile                  # Jenkins CI/CD pipeline
├── deploy.sh                    # Deployment script
├── README.md                    # Main documentation
├── QUICKSTART.md                # Quick start guide
├── DEPLOYMENT.md                # Deployment instructions
├── PROJECT_STRUCTURE.md         # This file
└── .gitignore                   # Git ignore rules
```

## Component Details

### Frontend
- **Technology**: React 18
- **Build Tool**: Create React App
- **Web Server**: Nginx (Alpine)
- **Port**: 80
- **Features**:
  - Create/Delete items
  - Real-time API status
  - Responsive UI

### Backend
- **Technology**: Python Flask
- **WSGI Server**: Gunicorn
- **Port**: 5000
- **Features**:
  - RESTful API (CRUD operations)
  - PostgreSQL integration
  - Prometheus metrics
  - Health checks
  - Request logging

### Database
- **Technology**: PostgreSQL 15
- **Port**: 5432
- **Schema**: Simple items table (id, name, created_at)

### Monitoring
- **Prometheus**: Metrics collection (Port 9090)
- **Grafana**: Visualization dashboards (Port 3000)
- **Metrics**: HTTP requests, duration, error rates

## Data Flow

```
User Browser
    ↓
Frontend (React + Nginx) :80
    ↓ HTTP Request
Backend (Flask) :5000
    ↓ SQL Query
Database (PostgreSQL) :5432
    ↓ Metrics
Prometheus :9090
    ↓ Visualization
Grafana :3000
```

## Port Mapping

| Service    | Container Port | Host Port | Purpose           |
|------------|----------------|-----------|-------------------|
| Frontend   | 80             | 80        | Web UI            |
| Backend    | 5000           | 5000      | API               |
| Database   | 5432           | 5432      | PostgreSQL        |
| Prometheus | 9090           | 9090      | Metrics           |
| Grafana    | 3000           | 3000      | Dashboards        |

## Environment Variables

### Backend
- `DB_HOST`: Database hostname
- `DB_PORT`: Database port
- `DB_NAME`: Database name
- `DB_USER`: Database user
- `DB_PASSWORD`: Database password
- `PORT`: Backend port

### Frontend
- `REACT_APP_API_URL`: Backend API URL

## Docker Images

| Service    | Base Image              | Size (approx) |
|------------|-------------------------|---------------|
| Frontend   | nginx:alpine            | ~25 MB        |
| Backend    | python:3.11-slim        | ~150 MB       |
| Database   | postgres:15-alpine      | ~250 MB       |
| Prometheus | prom/prometheus:latest  | ~200 MB       |
| Grafana    | grafana/grafana:latest  | ~300 MB       |

**Total**: ~925 MB (excluding data volumes)

## Resource Requirements

### Minimum (Single VM)
- **RAM**: 2GB
- **CPU**: 1 core
- **Disk**: 10GB

### Recommended (Single VM)
- **RAM**: 4GB
- **CPU**: 2 cores
- **Disk**: 20GB

### Multi-VM Setup
- **VM 1** (Frontend + Backend): 2GB RAM, 1 CPU
- **VM 2** (Database): 2GB RAM, 1 CPU
- **VM 3** (Monitoring): 2GB RAM, 1 CPU

