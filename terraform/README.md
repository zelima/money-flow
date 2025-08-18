# Georgian Budget Data Pipeline - Cloud Infrastructure

This directory contains Terraform configuration for deploying the Georgian Budget Data Pipeline to Google Cloud Platform (GCP).

## 🏗️ Architecture Overview

**Phase 1: Data Pipeline Migration** (Current)
- **Cloud Storage**: Raw and processed data storage
- **Cloud Functions**: Data processing pipeline (replaces GitHub Actions)
- **Cloud Scheduler**: Quarterly automated runs
- **Pub/Sub**: Event-driven pipeline triggers

## 📋 Prerequisites

1. **GCP Project**: Create a new GCP project with billing enabled
2. **Terraform**: Install Terraform >= 1.0
3. **gcloud CLI**: Install and authenticate with your GCP account
4. **APIs**: The Terraform will enable required APIs automatically

### GCP Setup

```bash
# Create new project (optional)
gcloud projects create your-project-id --name="Georgian Budget Pipeline"

# Set active project
gcloud config set project your-project-id

# Authenticate Terraform
gcloud auth application-default login
```

## 🚀 Deployment Steps

### 1. Configure Variables

```bash
# Copy example variables file
cp terraform.tfvars.example terraform.tfvars

# Edit with your values
vim terraform.tfvars
```

Required variables:
```hcl
project_id = "your-gcp-project-id"
region     = "europe-west1"  # Choose region close to Georgia
zone       = "europe-west1-b"
```

### 2. Initialize Terraform

```bash
cd terraform/
terraform init
```

### 3. Plan Deployment

```bash
terraform plan
```

Review the planned resources:
- 2 Cloud Storage buckets
- 1 Cloud Function (data processing)
- 2 Cloud Scheduler jobs (quarterly + manual trigger)
- 2 Service accounts
- IAM roles and permissions
- 1 Pub/Sub topic

### 4. Deploy Infrastructure

```bash
terraform apply
```

Type `yes` when prompted. Deployment takes approximately 5-10 minutes.

### 5. Verify Deployment

```bash
# Check outputs
terraform output

# Test manual trigger
gcloud scheduler jobs run georgian-budget-manual-trigger --location=europe-west1

# Check storage bucket
gsutil ls gs://$(terraform output -raw data_bucket_name)/
```

## 📊 Usage

### Automatic Execution
The pipeline runs automatically on the 15th of March, June, September, and December at 6 AM UTC (9 AM Georgia time).

### Manual Execution

#### Via gcloud (Recommended)
```bash
# Run quarterly job manually
gcloud scheduler jobs run georgian-budget-quarterly-pipeline --location=europe-west1

# Trigger via Pub/Sub
gcloud pubsub topics publish georgian-budget-pipeline-trigger \
  --message='{"trigger_type":"manual","year":"2024"}'
```

### Accessing Data

After successful pipeline execution:

```bash
# Data URLs (replace BUCKET_NAME)
BUCKET_NAME=$(terraform output -raw data_bucket_name)

# CSV data
curl "https://storage.googleapis.com/$BUCKET_NAME/processed/georgian_budget.csv"

# JSON data
curl "https://storage.googleapis.com/$BUCKET_NAME/processed/georgian_budget.json"

# Metadata
curl "https://storage.googleapis.com/$BUCKET_NAME/processed/datapackage.json"
```

## 🔧 Configuration

### Pipeline Schedule
Default: `0 6 15 3,6,9,12 *` (quarterly)

To modify, update `pipeline_schedule` in `terraform.tfvars`:
```hcl
pipeline_schedule = "0 9 1 * *"  # Monthly on 1st at 9 AM
```

### Function Resources
Default: 2 GiB memory, 9-minute timeout

To modify:
```hcl
function_memory         = "4Gi"    # More memory for large files
function_timeout_seconds = 900     # 15 minutes timeout
```

### Data Retention
Default: 365 days

To modify:
```hcl
data_retention_days = 730  # 2 years
```

## 📈 Monitoring

### Logs
```bash
# Function logs
gcloud functions logs read georgian-budget-pipeline-processor --region=europe-west1

# Scheduler logs
gcloud logging read 'resource.type="gce_instance" AND "georgian-budget"' --limit=50
```

### Metrics
- **Function Executions**: Cloud Functions → Metrics
- **Storage Usage**: Cloud Storage → Metrics  
- **Scheduler Status**: Cloud Scheduler → Jobs

### Alerts
Budget alerts are configured at $200 threshold (configurable via `budget_alert_threshold`).

## 🛠️ Troubleshooting

### Common Issues

#### Function Timeout
```bash
# Increase timeout
terraform apply -var="function_timeout_seconds=900"  # 15 minutes
```

#### Permission Errors
```bash
# Check service account permissions
gcloud projects get-iam-policy your-project-id \
  --filter="bindings.members:serviceAccount:georgian-budget-pipeline@your-project-id.iam.gserviceaccount.com"
```

#### Data Processing Errors
```bash
# Check function logs
gcloud functions logs read georgian-budget-pipeline-processor --region=europe-west1 --limit=100
```

### Debug Commands

```bash
# Test data source availability
curl -I https://geostat.ge/media/72030/saxelmwifo-biujeti-funqcionalur-chrilshi.xlsx

# Check bucket contents
gsutil ls -la gs://$(terraform output -raw data_bucket_name)/

# Test function locally (requires Cloud Function Emulator)
functions-framework --target=process_budget_data --source=../cloud-function/main.py
```

## 💰 Cost Estimation

**Monthly costs (estimated):**
- Cloud Functions: $5-15 (quarterly execution + manual triggers)
- Cloud Storage: $1-5 (small data files)
- Cloud Scheduler: $0.10 (3 jobs)
- Pub/Sub: $0.40 (minimal usage)
- **Total: ~$6-20/month**

## 🔄 Updates

### Infrastructure Updates
```bash
# Update Terraform configuration
terraform plan
terraform apply
```

### Function Code Updates
The function source is automatically packaged and deployed via Terraform. To update:

1. Modify code in `../cloud-function/`
2. Run `terraform apply`

### Pipeline Updates
To modify the data processing logic, update `../cloud-function/main.py` and redeploy.

## 🗑️ Cleanup

```bash
# Destroy all resources
terraform destroy
```

**⚠️ Warning**: This will permanently delete all data and resources.

## 📞 Support

- **Issues**: Check Cloud Function logs and metrics
- **Documentation**: [Google Cloud Documentation](https://cloud.google.com/docs)
- **Pipeline Logic**: Based on `../data-pipeline/pipeline-spec.yaml`
