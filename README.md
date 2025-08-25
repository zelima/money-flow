# Budget Data Pipeline

A comprehensive data-driven web application for analyzing government budget data from 2002-2020, now fully deployed on Google Cloud Platform (GCP).



## 📊 **Features**

### **Data Processing**
- **Automated Pipeline**: Quarterly data updates via Cloud Functions
- **Georgian Language Support**: Full translation and processing
- **Data Validation**: Automated quality checks and error handling
- **Storage**: Cloud Storage with versioning and lifecycle management

### **Backend API (FastAPI)**
- **RESTful Endpoints**: Complete budget data API
- **Real-time Data**: Live data from Cloud Storage
- **PostgreSQL Integration**: Drill-down analytics database
- **Health Monitoring**: Built-in health checks and monitoring
- **Auto-scaling**: Cloud Run with scale-to-zero

### **Frontend Dashboard (Flask)**
- **Interactive Charts**: Budget trends and department analysis
- **Responsive Design**: Mobile-friendly web interface
- **Real-time Updates**: Live data from backend API
- **Search & Filter**: Advanced data exploration tools

### **Infrastructure**
- **Serverless**: Cloud Run with automatic scaling
- **Security**: Private VPC, IAM, and encrypted communications
- **Monitoring**: Cloud Monitoring, logging, and alerting
- **CI/CD**: Automated deployment via Cloud Build
- **CDN**: Global content delivery optimization

## 💰 **Cost Optimization**

### **Monthly Costs**
- **Phase 1**: $6-20/month (Data Pipeline)
- **Phase 2**: $63-128/month (Full Application)
- **Total**: $69-148/month (well within $300 budget)

### **Cost-Saving Features**
- **Scale-to-Zero**: Cloud Run scales down when not in use
- **Efficient Storage**: Cloud Storage with lifecycle policies
- **Shared Load Balancer**: Single load balancer for all services
- **CDN Caching**: Reduces data transfer costs

## 🚀 **Quick Start**

### **1. Access the Application**
```bash
# Get the load balancer URL
cd money-flow/terraform
terraform output load_balancer_url

# Access your application
open http://LOAD_BALANCER_IP
```

### **2. API Documentation**
```bash
# Backend API docs
open https://BACKEND_URL/docs

# Health check
curl https://BACKEND_URL/health
```

### **3. Data Pipeline**
```bash
# Manual trigger
curl -X POST https://FUNCTION_URL \
  -H 'Content-Type: application/json' \
  -d '{"trigger_type": "manual"}'
```

## 🔧 **Development**

### **Local Development with Docker Compose & Makefile**
```bash
# Setup development environment
make setup

# Start all services (database, API, frontend)
make start

# Start only specific services
make api-only          # Start database + API only
make frontend-only     # Start frontend only
make db-start          # Start database only

# Development mode with hot reload
make dev

# View logs
make logs              # All services
make logs-api          # API only
make logs-frontend     # Frontend only

# Stop services
make stop
make restart
```

### **Available Make Commands**
```bash
make help              # Show all available commands
make install           # Install all dependencies
make test              # Run tests
make lint              # Code linting
make format            # Code formatting
make clean             # Clean up containers
make health            # Check service health
```

### **Cloud Deployment**
```bash
# Deploy infrastructure
cd money-flow/terraform
terraform init
terraform plan
terraform apply

# Deploy applications (automatic via Cloud Build)
git push origin main
```

## 📁 **Project Structure**

```
money-flow/
├── moneyflow-back/         # Backend API (FastAPI)
│   ├── main.py            # API endpoints
│   ├── models.py          # Data models
│   ├── database.py        # Database connection
│   └── requirements.txt   # Python dependencies
├── moneyflow-front/        # Frontend Dashboard (Flask)
│   ├── app.py             # Web application
│   ├── templates/         # HTML templates
│   └── requirements.txt   # Python dependencies
├── data-pipeline/         # Data processing pipeline
│   ├── pipeline-spec.yaml # Pipeline configuration
│   └── processors/        # Data processors
├── terraform/             # Infrastructure as Code
│   ├── main.tf            # Main configuration
│   ├── cloud-run.tf       # Cloud Run services
│   ├── cloud-sql.tf       # Cloud SQL database
│   ├── load-balancer.tf   # Load balancer
│   └── cloud-build.tf     # CI/CD pipeline
└── fixtures/              # Database schema and migrations for tixture data
    └── init/              # SQL initialization scripts
```

## 🌐 **API Endpoints**

### **Core Budget Data**
- `GET /budget` - Get budget data with filters
- `GET /summary` - Overall budget summary
- `GET /departments` - List all departments
- `GET /trends/{department}` - Department budget trends
- `GET /years/{year}` - Year-specific summary

### **Advanced Analytics**
- `GET /drill-down/{department}` - Sub-department breakdown
- `GET /drill-down/analysis/{department}/{year}` - Detailed analysis
- `GET /search` - Search departments by name

### **System Health**
- `GET /health` - Health check and status
- `GET /docs` - Interactive API documentation

## 🔒 **Security & Compliance**

- **Private Networking**: VPC with restricted access
- **IAM Security**: Service accounts with minimal permissions
- **Data Encryption**: Encrypted in transit and at rest
- **Audit Logging**: Comprehensive access and change logs
- **Health Monitoring**: Continuous health checks and alerting

## 📈 **Monitoring & Observability**

- **Cloud Monitoring**: Performance metrics and dashboards
- **Cloud Logging**: Centralized logging and analysis
- **Health Checks**: Automatic health monitoring
- **Error Tracking**: Real-time error detection and alerting
- **Cost Monitoring**: Budget alerts and optimization



## 🎯 **TODO**

1. **Performance Optimization**: Auto-scaling, caching, database optimization
2. **Advanced Monitoring**: Custom dashboards, alerting, log analysis
3. **Security Hardening**: VPC controls, secret management, security scanning



## 🤝 **Contributing**

This project is designed for government budget transparency and analysis. Contributions are welcome for:
- Data quality improvements
- Additional analytics features
- Performance optimizations
- Documentation enhancements

## 📄 **License**

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
