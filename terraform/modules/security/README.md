# Security Module

This Terraform module manages all security infrastructure for the Georgian Budget application, including Secret Manager secrets and related IAM permissions for secure credential storage and access.

## Resources

- **Secret Manager Secrets**: Secure storage for sensitive data like database connection strings
- **Secret Versions**: Versioned secret values with automatic rotation capabilities
- **IAM Bindings**: Role assignments for accessing secrets across different services

## Usage

```hcl
module "security" {
  source = "../../modules/security"

  database_user_name = "db_user"
  database_user_password = "secure_password"
  database_private_ip = "10.0.0.1"
  database_name = "your_database"
  cloud_build_service_account_email = "cloudbuild-sa@project.iam.gserviceaccount.com"
  backend_service_account_email = "backend-sa@project.iam.gserviceaccount.com"

  required_apis = [google_project_service.required_apis]
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| database_user_name | Database username for secret construction | `string` | n/a | yes |
| database_user_password | Database password for secret construction | `string` | n/a | yes |
| database_private_ip | Private IP address of the database instance | `string` | n/a | yes |
| database_name | Name of the database | `string` | n/a | yes |
| cloud_build_service_account_email | Email of the Cloud Build service account | `string` | n/a | yes |
| backend_service_account_email | Email of the backend service account | `string` | n/a | yes |
| required_apis | List of required APIs | `any` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| database_url_secret_id | ID of the database URL secret |
| database_url_secret_name | Name of the database URL secret |
| database_url_secret_version_id | ID of the database URL secret version |
| cloud_build_secret_iam_member_id | ID of the Cloud Build secret IAM member |
| backend_secret_iam_member_id | ID of the backend secret IAM member |

## Features

- **Secure Secret Storage**: Database connection strings stored in Secret Manager
- **Automatic Replication**: Secrets replicated automatically across regions
- **Version Management**: Secret versions tracked and managed automatically
- **Granular Access Control**: IAM permissions for specific service accounts
- **Sensitive Data Protection**: Database passwords marked as sensitive
- **Dependency Management**: Proper resource dependencies for safe deployment

## Security Considerations

### Secret Management
- **Database Connection String**: Constructed from database credentials and stored securely
- **Automatic Replication**: Ensures high availability across regions
- **Version Control**: Changes to secrets create new versions for rollback capability

### Access Control
- **Cloud Build Access**: CI/CD pipeline can access secrets for deployments
- **Backend Service Access**: Application services can retrieve secrets at runtime
- **Least Privilege**: Only necessary service accounts have access to secrets

### Data Protection
- **Sensitive Variables**: Database passwords marked as sensitive in Terraform
- **Encrypted Storage**: All secrets encrypted at rest in Secret Manager
- **Audit Trail**: All secret access logged for security monitoring

## IAM Permissions

The following service accounts receive secret access:
- **Cloud Build Service Account**: `roles/secretmanager.secretAccessor`
  - Used during CI/CD pipeline for database connections
- **Backend Service Account**: `roles/secretmanager.secretAccessor`
  - Used by backend API for database access at runtime

## Best Practices

- **Secret Rotation**: Implement regular rotation of database credentials
- **Access Monitoring**: Monitor secret access patterns for anomalies
- **Principle of Least Privilege**: Only grant secret access to necessary services
- **Environment Separation**: Use separate secrets for different environments
- **Backup Strategy**: Leverage secret versioning for disaster recovery

## Prerequisites

Before using this module, ensure:
1. **Secret Manager API**: Enabled in your GCP project
2. **Service Accounts**: Target service accounts exist and are configured
3. **Database Module**: Database infrastructure deployed and accessible
4. **IAM Permissions**: Terraform has necessary permissions for Secret Manager operations
