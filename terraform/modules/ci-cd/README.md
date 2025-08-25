# CI/CD Module

This Terraform module manages all CI/CD infrastructure for the Georgian Budget application, including Cloud Build triggers, Artifact Registry, and related IAM permissions.

## Resources

- **Cloud Build Triggers**: Automated builds for backend API and frontend web app
- **Artifact Registry**: Docker repository for storing application images
- **Service Accounts**: Cloud Build service account with necessary permissions
- **IAM Bindings**: Role assignments for Cloud Build operations

## Usage

```hcl
module "ci_cd" {
  source = "../../modules/ci-cd"

  project_id = "your-project-id"
  region = "europe-west1"
  domain_name = "yourdomain.com"
  load_balancer_ip = "1.2.3.4"
  data_bucket_name = "your-data-bucket"
  database_user_name = "db_user"
  database_user_password = "db_password"
  database_private_ip = "10.0.0.1"
  database_name = "your_database"

  required_apis = [google_project_service.required_apis]
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| project_id | The GCP project ID | `string` | n/a | yes |
| region | The GCP region for CI/CD resources | `string` | n/a | yes |
| domain_name | The domain name for the application | `string` | `""` | no |
| load_balancer_ip | IP address of the load balancer | `string` | n/a | yes |
| data_bucket_name | Name of the data storage bucket | `string` | n/a | yes |
| database_user_name | Database username | `string` | n/a | yes |
| database_user_password | Database password | `string` | n/a | yes |
| database_private_ip | Private IP of database instance | `string` | n/a | yes |
| database_name | Name of the database | `string` | n/a | yes |
| required_apis | List of required APIs | `any` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| cloud_build_service_account_email | Email of the Cloud Build service account |
| backend_trigger_id | ID of the backend Cloud Build trigger |
| frontend_trigger_id | ID of the frontend Cloud Build trigger |
| artifact_registry_repository_url | URL of the Artifact Registry repository |

## Features

- **Automated CI/CD Pipeline**: Triggers on GitHub repository changes
- **Multi-Service Support**: Separate triggers for backend API and frontend web app
- **Environment Variables**: Dynamic substitution for different environments
- **Secure IAM**: Least-privilege access for Cloud Build operations
- **Artifact Management**: Centralized Docker image storage

## Cloud Build Triggers

### Backend API Trigger
- **Source**: `moneyflow-back/cloudbuild.yaml` in main branch
- **Variables**: Database connection, storage bucket, artifact registry
- **Target**: Backend API service deployment

### Frontend Web App Trigger
- **Source**: `web-app/cloudbuild.yaml` in main branch
- **Variables**: Backend URL, artifact registry
- **Target**: Frontend web app deployment

## IAM Permissions

The Cloud Build service account has the following roles:
- **Cloud Run Admin**: Deploy to Cloud Run services
- **Service Account User**: Act as other service accounts
- **Storage Admin**: Access Cloud Storage buckets
- **Logging Writer**: Write logs during builds
- **Artifact Registry Writer**: Push images to repository

## Prerequisites

Before using this module, ensure:
1. **GitHub Repository**: Connected to Cloud Build in GCP Console
2. **Required APIs**: Cloud Build, Artifact Registry, Cloud Run APIs enabled
3. **Cloud Build YAML**: Proper build configuration files in repository
4. **Service Accounts**: Target services have appropriate IAM permissions

## Repository Structure

```
money-flow/
├── moneyflow-back/
│   └── cloudbuild.yaml          # Backend build configuration
├── web-app/
│   └── cloudbuild.yaml          # Frontend build configuration
└── terraform/
    └── modules/
        └── ci-cd/               # This module
```

## Security Considerations

- **Service Account**: Dedicated service account for Cloud Build operations
- **Least Privilege**: Minimal IAM roles required for operations
- **Private Network**: Database connections use private IP addresses
- **Secret Management**: Database credentials passed as build variables
