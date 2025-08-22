# Networking Module

This Terraform module manages all networking infrastructure for the Georgian Budget application, including:

## Resources

- **VPC Network**: Custom VPC with private subnet
- **VPC Connector**: For Cloud Run to access Cloud SQL
- **Load Balancer**: Global HTTP(S) load balancer with CDN
- **DNS**: DNS records for the application domain
- **Firewall Rules**: Security rules for Cloud Run to SQL access
- **Service Accounts**: IAM roles for load balancer operations

## Usage

```hcl
module "networking" {
  source = "../../modules/networking"

  project_id = "your-project-id"
  region     = "europe-west1"

  domain_name         = "moneyflow.thelim.dev"
  force_https_redirect = true
  dns_provider        = "google_cloud"

  required_apis = [google_project_service.required_apis]
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| project_id | The GCP project ID | `string` | n/a | yes |
| region | The GCP region for resources | `string` | n/a | yes |
| domain_name | The domain name for SSL certificate | `string` | `""` | no |
| force_https_redirect | Whether to force HTTPS redirect | `bool` | `true` | no |
| dns_provider | DNS provider to use | `string` | `"google_cloud"` | no |
| required_apis | List of required APIs | `any` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| vpc_id | The ID of the VPC network |
| vpc_name | The name of the VPC network |
| subnet_id | The ID of the subnet |
| load_balancer_ip | The external IP address of the load balancer |
| frontend_backend_service_id | The ID of the frontend backend service |
| backend_api_service_id | The ID of the backend API service |

## Dependencies

This module depends on:
- Google Cloud APIs being enabled
- Cloud Run services existing (referenced by name)
- DNS managed zone existing (if using Google Cloud DNS)
