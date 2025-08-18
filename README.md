# 🇬🇪 Georgian Budget Data Pipeline

A comprehensive data-driven web application for analyzing Georgian government budget data from 2002-2020, now fully deployed on Google Cloud Platform (GCP).

## 🚀 **Current Status: Phase 2 Complete!**

### ✅ **Phase 1: Data Pipeline Migration (COMPLETED)**
- **Cloud Storage Buckets**: Data storage for raw and processed files
- **Cloud Function**: Data processing pipeline (replaces GitHub Actions)
- **Cloud Scheduler**: Quarterly automation (15th of Mar, Jun, Sep, Dec)
- **Pub/Sub Topic**: Event-driven pipeline triggers
- **Service Accounts**: Proper IAM permissions for security

### ✅ **Phase 2: Backend & Frontend Deployment (COMPLETED)**
- **Backend API**: FastAPI deployed to Cloud Run
- **Frontend Web App**: Flask dashboard deployed to Cloud Run
- **Cloud SQL**: PostgreSQL database for drill-down analytics
- **Global Load Balancer**: HTTP(S) load balancer with SSL/TLS
- **Cloud Build**: Automated CI/CD pipeline
- **VPC Network**: Private networking for security

## 🏗️ **Architecture**

```
Internet → Global Load Balancer → Cloud Run Services
                                    ├── Frontend (Flask) → User Dashboard
                                    └── Backend (FastAPI) → Data API
                                                          ├── Cloud Storage (Budget Data)
                                                          └── Cloud SQL (Analytics)
```

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

### **Local Development**
```bash
# Backend API
cd money-flow/api
pip install -r requirements.txt
uvicorn main:app --reload

# Frontend Web App
cd money-flow/web-app
pip install -r requirements.txt
flask run

# Database
docker-compose up -d
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
├── api/                    # Backend API (FastAPI)
│   ├── main.py            # API endpoints
│   ├── models.py          # Data models
│   ├── database.py        # Database connection
│   └── requirements.txt   # Python dependencies
├── web-app/               # Frontend Dashboard (Flask)
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
└── database/              # Database schema and migrations
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

## 🚨 **Support & Troubleshooting**

### **Common Issues**
1. **Service Unavailable**: Check Cloud Run service status
2. **Database Errors**: Verify Cloud SQL connection
3. **Build Failures**: Review Cloud Build logs
4. **Load Balancer Issues**: Check health check status

### **Useful Commands**
```bash
# Check service status
gcloud run services list --region=europe-west1

# View logs
gcloud logs read "resource.type=cloud_run_revision"

# Test endpoints
curl -I https://BACKEND_URL/health
```

## 🎯 **Next Steps (Phase 3)**

After successful Phase 2 deployment:
1. **Performance Optimization**: Auto-scaling, caching, database optimization
2. **Advanced Monitoring**: Custom dashboards, alerting, log analysis
3. **Security Hardening**: VPC controls, secret management, security scanning

## 📚 **Documentation**

- [Phase 1: Data Pipeline Migration](terraform/README.md)
- [Phase 2: Backend & Frontend Deployment](terraform/PHASE2_README.md)
- [Getting Started Guide](docs/getting-started.md)
- [Automation Documentation](docs/automation.md)

## 🤝 **Contributing**

This project is designed for Georgian government budget transparency and analysis. Contributions are welcome for:
- Data quality improvements
- Additional analytics features
- Performance optimizations
- Documentation enhancements

## 📄 **License**

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

**🎉 Your Georgian Budget application is now fully deployed and running in production on Google Cloud Platform!**

**🌐 Access your application**: Use the load balancer URL from Terraform outputs
**📊 Monitor performance**: Check Cloud Console for metrics and logs
**🔄 Automatic updates**: Data pipeline runs quarterly, apps deploy automatically
**💰 Cost optimized**: Well within your $300 GCP budget
