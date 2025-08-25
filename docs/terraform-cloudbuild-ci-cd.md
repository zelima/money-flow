# Terraform CI/CD with Cloud Build

This document describes the automated Terraform deployment setup for the money-flow project using Google Cloud Build.

## Overview

The CI/CD pipeline automatically deploys infrastructure changes when:
- Changes are made to the `terraform/` directory
- Changes are made to the `moneyflow-functions/` directory
- Code is pushed to specific branches

## Architecture

### Cloud Build Triggers

The system uses environment-specific Cloud Build triggers that automatically deploy to the correct environment:

- **Staging Environment**: Creates `terraform-staging-trigger` that activates on push to `staging` branch
- **Production Environment**: Creates `terraform-production-trigger` that activates on push to `main` branch

Each environment only creates its own trigger, ensuring clean separation and preventing cross-environment deployments.

### File Filtering

Both triggers only activate when changes are made to:
- `terraform/**` - Any Terraform configuration changes
- `moneyflow-functions/**` - Data pipeline function changes

## Cloud Build Configuration

### Main Configuration (`terraform/cloudbuild.yaml`)

The Cloud Build configuration:
- Uses the official Terraform Docker image
- Automatically detects environment from substitutions
- Runs Terraform init, validate, plan, and apply
- Handles environment-specific variables

### Environment Detection

```yaml
# Environment is determined by _ENVIRONMENT substitution
if [ "$_ENVIRONMENT" = "production" ]; then
  WORKING_DIR="terraform/environments/prod"
else
  WORKING_DIR="terraform/environments/staging"
fi
```

### Terraform Operations

1. **Initialize**: `terraform init`
2. **Format Check**: `terraform fmt -check`
3. **Validate**: `terraform validate`
4. **Plan**: `terraform plan -out=tfplan`
5. **Apply**: `terraform apply tfplan` (or `-auto-approve` for staging)

## Infrastructure as Code

### CI/CD Module

The Terraform CI/CD module (`terraform/modules/ci-cd/`) creates:

- Cloud Build triggers for both environments
- Service account with necessary permissions
- IAM roles for Terraform operations
- Artifact Registry for Docker images

### Required IAM Roles

The Cloud Build service account has these roles:
- `roles/editor` - Basic Terraform operations
- `roles/resourcemanager.projectIamAdmin` - IAM changes
- `roles/serviceusage.serviceUsageAdmin` - API management
- `roles/compute.networkAdmin` - VPC operations
- `roles/dns.admin` - DNS management
- `roles/secretmanager.admin` - Secrets management
- `roles/cloudsql.admin` - Database operations
- `roles/cloudfunctions.admin` - Cloud Functions
- `roles/cloudscheduler.admin` - Cloud Scheduler
- `roles/eventarc.admin` - Eventarc operations

## Deployment Flow

### Staging Deployment
1. Developer pushes to `staging` branch
2. Cloud Build trigger activates automatically
3. Terraform deploys to staging environment
4. No approval required

### Production Deployment
1. Developer pushes to `main` branch
2. Cloud Build trigger activates automatically
3. Terraform deploys to production environment
4. No approval required (Cloud Build handles authentication)

### Manual Deployment
1. Go to Cloud Build in Google Cloud Console
2. Select "Triggers"
3. Manually run any trigger with custom substitutions

## Configuration

### Environment Variables

The Cloud Build configuration uses these substitutions:

```yaml
substitutions:
  _ENVIRONMENT: 'staging'  # or 'production'
  _REGION: 'europe-west1'
  _ZONE: 'europe-west1-b'
  _DOMAIN_NAME: 'your-domain.com'
```

### Terraform Variables

These are automatically passed to Terraform:
- `TF_VAR_project_id` - From Cloud Build `$PROJECT_ID`
- `TF_VAR_region` - From `_REGION` substitution
- `TF_VAR_zone` - From `_ZONE` substitution
- `TF_VAR_domain_name` - From `_DOMAIN_NAME` substitution

## Security Features

### Service Account Isolation
- Dedicated service account for Cloud Build operations
- Minimal required permissions
- No long-lived credentials stored in code

### State Management
- Uses GCS backend for Terraform state
- Separate state files for staging and production
- State locking and consistency

### Network Security
- All operations run within Google Cloud
- No external API calls required
- Secure credential management

## Monitoring and Logging

### Build Logs
- All build logs stored in Cloud Logging
- Structured logging for easy filtering
- Build history and audit trail

### Notifications
- Build status notifications available
- Integration with Cloud Monitoring
- Custom notification steps can be added

## Troubleshooting

### Common Issues

1. **Permission Denied**
   - Verify service account has required roles
   - Check IAM bindings in the CI/CD module

2. **State Lock Issues**
   - Check if another deployment is running
   - Verify GCS bucket permissions

3. **Variable Errors**
   - Ensure all substitutions are set correctly
   - Check variable definitions in Terraform files

4. **Build Failures**
   - Check Cloud Build logs in Google Cloud Console
   - Verify Terraform configuration syntax

### Debug Mode

Enable verbose logging in Cloud Build:
```yaml
options:
  logging: CLOUD_LOGGING_ONLY
  machineType: 'E2_HIGHCPU_8'
  diskSizeGb: '50'
```

## Best Practices

1. **Always test in staging** before production
2. **Use meaningful commit messages** for infrastructure changes
3. **Monitor resource costs** after deployments
4. **Keep Terraform versions** consistent across environments
5. **Review Cloud Build logs** for any issues
6. **Use included_files** to limit trigger scope

## Advantages of Cloud Build

### Native Integration
- **GCP Native**: Built for Google Cloud workloads
- **Authentication**: No need to manage service account keys
- **Performance**: Runs on Google's infrastructure
- **Cost**: Often cheaper than external CI/CD

### Security
- **IAM Integration**: Uses Google Cloud IAM directly
- **No Credentials**: No secrets to store or rotate
- **Audit Trail**: Full logging and monitoring
- **Network Security**: Runs within Google Cloud

### Scalability
- **Auto-scaling**: Handles multiple concurrent builds
- **Resource Management**: Configurable machine types
- **Timeout Control**: Configurable build timeouts
- **Artifact Management**: Built-in artifact storage

## Migration from GitHub Actions

### Benefits of Migration
- **Simplified Authentication**: No GitHub secrets management
- **Better Performance**: Native GCP integration
- **Cost Reduction**: Often cheaper than GitHub Actions
- **Unified Tooling**: Same platform as your infrastructure

### Migration Steps
1. Deploy the updated Terraform configuration
2. Verify Cloud Build triggers are created
3. Test deployments in both environments
4. Remove GitHub Actions workflows
5. Update documentation and team processes

## Support

For issues with the Cloud Build CI/CD pipeline:
1. Check Cloud Build logs in Google Cloud Console
2. Verify IAM permissions for the service account
3. Check Terraform state and configuration
4. Review Cloud Build trigger configuration
5. Check included_files patterns for trigger activation

## Future Enhancements

### Potential Improvements
- **Approval Workflows**: Add manual approval for production
- **Slack/Email Notifications**: Integrate with communication tools
- **Build Caching**: Optimize build performance
- **Multi-environment Support**: Add development environment
- **Rollback Capabilities**: Automated rollback on failures
