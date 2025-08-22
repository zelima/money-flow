# Database Module

This Terraform module manages the Cloud SQL PostgreSQL database infrastructure for the Georgian Budget application.

## Resources

- **Cloud SQL Instance**: PostgreSQL 15 instance with private IP configuration
- **Database**: PostgreSQL database named `georgian_budget`
- **Database User**: User account with generated password
- **Backup Configuration**: Automated backups with point-in-time recovery

## Usage

```hcl
module "database" {
  source = "../../modules/database"

  region = "europe-west1"
  vpc_id = module.networking.vpc_id

  labels = {
    environment = "production"
    application = "georgian-budget"
  }

  required_apis = [google_project_service.required_apis]
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| region | The GCP region for the Cloud SQL instance | `string` | n/a | yes |
| vpc_id | The ID of the VPC network for private IP configuration | `string` | n/a | yes |
| labels | Labels to apply to the Cloud SQL instance | `map(string)` | `{}` | no |
| required_apis | List of required APIs | `any` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| instance_id | The ID of the Cloud SQL instance |
| instance_name | The name of the Cloud SQL instance |
| instance_connection_name | The connection name of the Cloud SQL instance |
| instance_private_ip_address | The private IP address of the Cloud SQL instance |
| database_name | The name of the PostgreSQL database |
| database_user_name | The name of the database user |
| database_user_password | The password for the database user (sensitive) |
| database_url | The database connection URL (sensitive) |

## Dependencies

This module depends on:
- Google Cloud APIs being enabled
- VPC network existing (provided by networking module)
- Networking module outputs

## Security Features

- **Private IP only**: No public IP access
- **VPC integration**: Connected to private VPC network
- **Automated backups**: Daily backups with 7-day retention
- **Point-in-time recovery**: Transaction log retention enabled
