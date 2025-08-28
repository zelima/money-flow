# Money Flow - Georgian Budget Analysis Platform

A modern cloud-native web application for analyzing Georgian government budget data, showcasing production-ready infrastructure and development skills. Built with FastAPI, Flask, PostgreSQL, and deployed on Google Cloud Platform (GCP).

## 🎯 **Project Overview**

This project demonstrates:
- **Full-Stack Development**: FastAPI backend + Flask frontend
- **Cloud-Native Architecture**: Serverless deployment on GCP
- **DevOps & Infrastructure**: Terraform IaC + Docker + CI/CD
- **Data Engineering**: Automated data pipeline processing Georgian government data
- **Production-Ready Code**: Testing, monitoring, and scalable design

## 🏗️ **Architecture Overview**

Three-tier architecture with automated data processing:

- **Data Layer**: Cloud Storage + Cloud SQL (PostgreSQL) + Cloud Functions
- **Application Layer**: Cloud Run (FastAPI backend + Flask frontend)
- **Infrastructure Layer**: Load Balancer + VPC + Secret Manager + CI/CD
- **Monitoring Layer**: Cloud Monitoring + Logging + Health Checks

For detailed technical architecture, see [ARCHITECTURE.md](ARCHITECTURE.md).

## 🚀 **Quick Start**

### **Option 1: Local Development**
```bash
# Clone and setup
git clone https://github.com/zelima/money-flow
cd money-flow

# Start all services with Docker Compose
make setup      # Install dependencies and start database
make start      # Start all services (API, Frontend, Database)

# Access the application

  # Frontend dashboard
open http://localhost:5000      # Frontend dashboard
open http://localhost:8000/docs # API documentation
```

### **Option 2: Cloud Deployment**
```bash
# Deploy infrastructure with Terraform
cd terraform/environments/prod
terraform init
terraform plan
terraform apply

# Applications deploy automatically via Cloud Build
# Access via load balancer IP from terraform output
```

### **🔗 Key URLs (Local Development)**
- **Frontend Dashboard**: http://localhost:5000
- **API Documentation**: http://localhost:8000/docs
- **API Health Check**: http://localhost:8000/health
- **Database**: localhost:5432 (PostgreSQL)

## 🚀 **Automated Releases**

The project uses automated semantic versioning through GitHub Actions. Releases are automatically created when pull requests are merged based on commit message conventions.

### **Release Triggers**
- **Automatic**: When PRs are merged to `main` or `develop` branches
- **Manual**: Via GitHub Actions workflow dispatch

### **Version Bumping Rules**
- **Major** (`!feat`, `!fix`, `breaking change`, `major`): Breaking changes
- **Minor** (`feat:`, `feature:`, `minor`, `enhancement`): New features
- **Patch** (`fix:`, `bugfix:`, `patch:`, `hotfix:`, `docs:`, `style:`, `refactor:`, `perf:`, `test:`, `chore:`): Bug fixes and improvements

### **Example PR Titles**
```
feat: Add new budget visualization charts
fix: Resolve data loading issue in dashboard
docs: Update API documentation
!feat: Breaking change in API response format
```

### **Manual Release**
1. Go to Actions → Automated Release
2. Click "Run workflow"
3. Select version type (major/minor/patch)
4. Run the workflow

## 🔧 **Development Guide**

### **Prerequisites**
- Docker and Docker Compose
- Make (for development commands)
- Python 3.11+ (for local development)
- GCP account (for cloud deployment)
- Terraform (for infrastructure)

### **Local Development**
```bash
# Start development environment
make setup              # Install dependencies and setup database
make start              # Start all services
make dev                # Start with hot reload

# Individual services
make api-only           # Database + API only
make frontend-only      # Frontend only
make db-start           # Database only

# Useful commands
make logs               # View all service logs
make health             # Check service health
make test               # Run all tests
make lint               # Code quality checks
make clean              # Clean up containers
```

### **Available Services**
- **PostgreSQL Database**: localhost:5432
- **FastAPI Backend**: localhost:8000
- **Flask Frontend**: localhost:5000

### **Testing**
```bash
make test               # Run all tests
make test-api           # Backend tests only
make test-web-app       # Frontend tests only
make test-integration   # Integration tests
```

### **Code Quality**
```bash
make lint               # Run linting
make format             # Format code with black
```

## 📁 **Project Structure**

```
money-flow/
├── 🔧 moneyflow-back/           # FastAPI Backend
│   ├── main.py                  # API endpoints & business logic
│   ├── models.py                # Pydantic data models
│   ├── database.py              # PostgreSQL connection & queries
│   ├── requirements.txt         # Python dependencies
│   └── tests/                   # Backend tests
├── 🌐 moneyflow-front/          # Flask Frontend
│   ├── app.py                   # Web application & routes
│   ├── templates/               # HTML templates
│   ├── static/                  # CSS & JavaScript
│   ├── web_app_tests/           # Frontend tests
│   └── requirements.txt         # Python dependencies
├── ☁️ moneyflow-functions/       # Cloud Functions
│   ├── cloud_function_main.py   # Data pipeline function
│   ├── data-pipeline/           # datapackage-pipelines config
│   └── requirements.txt         # Function dependencies
├── 🏗️ terraform/                # Infrastructure as Code
│   ├── environments/            # Environment configs (prod/staging)
│   └── modules/                 # Reusable Terraform modules
│       ├── networking/          # VPC, load balancer, DNS
│       ├── compute/             # Cloud Run, Cloud Functions
│       ├── database/            # Cloud SQL PostgreSQL
│       ├── storage/             # Cloud Storage buckets
│       ├── security/            # IAM, Secret Manager
│       ├── monitoring/          # Cloud Monitoring, alerts
│       └── ci-cd/               # Cloud Build triggers
├── 🗄️ fixtures/                 # Database initialization
│   └── init/                    # SQL schema & seed data
├── 📋 docker-compose.yml        # Local development environment
├── 📝 Makefile                  # Development commands
└── 📖 ARCHITECTURE.md           # Technical architecture docs
```

## 🌐 **API Endpoints**

### **📊 Budget Data**
| Endpoint | Method | Description |
|----------|--------|-------------|
| `/budget` | GET | Get budget data with optional filters (year, department, limit) |
| `/summary` | GET | Overall budget statistics and data summary |
| `/departments` | GET | List all available departments |
| `/trends/{department}` | GET | Budget trends over time for specific department |
| `/years/{year}` | GET | Budget summary for specific year |
| `/search?q={query}` | GET | Search departments by name |

### **🔍 Advanced Analytics (PostgreSQL)**
| Endpoint | Method | Description |
|----------|--------|-------------|
| `/drill-down/{department}` | GET | Sub-department breakdown with allocation percentages |
| `/drill-down/analysis/{department}/{year}` | GET | Detailed budget allocation analysis |
| `/drill-down/explore` | GET | Explore drill-down data across departments |

### **⚡ System**
| Endpoint | Method | Description |
|----------|--------|-------------|
| `/health` | GET | Health check and system status |
| `/docs` | GET | Interactive API documentation (Swagger UI) |
| `/` | GET | API information and available endpoints |

## 💡 **Technical Highlights**

### **🏗️ Infrastructure as Code**
- **Terraform Modules**: Modular, reusable infrastructure components
- **Multi-Environment**: Separate staging and production environments
- **Auto-scaling**: Cloud Run scales from 0 to multiple instances
- **Cost-Optimized**: Pay-per-use serverless architecture

### **🔒 Security & Best Practices**
- **Private VPC**: Isolated network with restricted access
- **IAM Roles**: Least-privilege service accounts
- **Secret Management**: Google Secret Manager for credentials
- **HTTPS Only**: SSL certificates and encrypted communication
- **Data Encryption**: Encrypted at rest and in transit

### **📊 Data Engineering**
- **Pipeline Automation**: Cloud Functions with Cloud Scheduler triggers
- **Data Processing**: `datapackage-pipelines` framework
- **Storage Strategy**: Cloud Storage with lifecycle policies
- **Database Design**: PostgreSQL with proper indexing

### **⚡ Performance & Monitoring**
- **Health Checks**: Automatic service monitoring
- **Logging**: Centralized Cloud Logging
- **Metrics**: Cloud Monitoring with custom dashboards
- **Error Tracking**: Real-time error detection
- **Uptime Monitoring**: Continuous availability checks

## 🎯 **Technology Stack**

| Component | Technology | Purpose |
|-----------|------------|---------|
| **Backend API** | FastAPI + Python 3.11 | RESTful API with automatic docs |
| **Frontend** | Flask + HTML/CSS/JS | Web dashboard and visualization |
| **Database** | PostgreSQL | Sub-department analytics data |
| **Data Storage** | Google Cloud Storage | Budget data files (CSV/JSON) |
| **Data Pipeline** | Cloud Functions + datapackage-pipelines | Automated data processing |
| **Infrastructure** | Terraform | Infrastructure as Code |
| **Containerization** | Docker + Cloud Run | Serverless container deployment |
| **CI/CD** | Cloud Build | Automated testing and deployment |
| **Monitoring** | Cloud Monitoring + Logging | Observability and alerting |
| **Security** | VPC + IAM + Secret Manager | Security and access control |

---

**💼 Built for showcasing production-ready development skills including full-stack development, cloud architecture, DevOps practices, and data engineering.**
