# Compute Module

This Terraform module manages all compute infrastructure for the Georgian Budget application, including Cloud Functions, Cloud Scheduler, service accounts, and IAM resources.

## Resources

- **Cloud Functions**: Data pipeline processing function
- **Cloud Scheduler**: Automated and manual pipeline triggers
- **Pub/Sub Topics**: Event-driven function triggers
- **Service Accounts**: Pipeline, scheduler, backend, and frontend service accounts
- **IAM Roles**: Comprehensive permissions for all compute resources

## Usage

```hcl
module "compute" {
  source = "../../modules/compute"

  project_id = "your-project-id"
  region     = "europe-west1"
  environment = "prod"

  function_source_path = "../../../moneyflow-functions"
  data_pipeline_path   = "../moneyflow-functions/data-pipeline"
  function_source_bucket_name = "your-function-source-bucket"
  data_bucket_name = "your-data-bucket"

  required_apis = [google_project_service.required_apis]
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| project_id | The GCP project ID | `string` | n/a | yes |
| region | The GCP region for resources | `string` | n/a | yes |
| environment | The environment (dev, staging, prod) | `string` | n/a | yes |
| function_source_path | Path to the cloud function source code | `string` | n/a | yes |
| data_pipeline_path | Path to the data pipeline source code | `string` | n/a | yes |
| function_source_bucket_name | Name of the bucket to store function source code | `string` | n/a | yes |
| data_bucket_name | Name of the data bucket | `string` | n/a | yes |
| required_apis | List of required APIs | `any` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| pipeline_function_sa_email | Email of the pipeline function service account |
| scheduler_sa_email | Email of the scheduler service account |
| backend_service_account_email | Email of the backend service account |
| frontend_service_account_email | Email of the frontend service account |
| pipeline_processor_function_uri | URI of the pipeline processor Cloud Function |
| pipeline_trigger_topic_name | Name of the pipeline trigger Pub/Sub topic |
| quarterly_pipeline_job_name | Name of the quarterly pipeline scheduler job |

## Dependencies

This module depends on:
- Google Cloud APIs being enabled
- Storage buckets existing
- Networking module outputs (for IAM references)

## Features

- **Automated Scheduling**: Quarterly pipeline execution
- **Manual Triggers**: On-demand pipeline execution
- **Event-Driven**: Pub/Sub based function invocation
- **Comprehensive IAM**: Proper security permissions
- **Cost Optimization**: Scale-to-zero Cloud Functions
