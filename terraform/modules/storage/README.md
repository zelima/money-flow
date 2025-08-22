# Storage Module

This Terraform module manages all storage infrastructure for the Georgian Budget application, including Cloud Storage buckets and objects.

## Resources

- **Data Bucket**: Main storage bucket for raw and processed data files
- **Function Source Bucket**: Storage bucket for Cloud Function source code
- **Bucket Objects**: Folder structure placeholders and organization
- **Lifecycle Rules**: Automatic data management and cost optimization

## Usage

```hcl
module "storage" {
  source = "../../modules/storage"

  region = "europe-west1"
  data_bucket_name = "my-project-data-bucket"
  function_source_bucket_name = "my-project-function-source-bucket"

  labels = {
    environment = "prod"
    project     = "georgian-budget"
    component   = "data-pipeline"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| region | The GCP region for storage buckets | `string` | n/a | yes |
| data_bucket_name | Name of the main data bucket | `string` | n/a | yes |
| function_source_bucket_name | Name of the function source bucket | `string` | n/a | yes |
| labels | Labels to apply to storage resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| data_bucket_name | Name of the main data bucket |
| data_bucket_url | URL of the main data bucket |
| function_source_bucket_name | Name of the function source bucket |
| function_source_bucket_url | URL of the function source bucket |
| raw_folder_object_id | ID of the raw folder placeholder object |
| processed_folder_object_id | ID of the processed folder placeholder object |

## Features

- **Data Organization**: Structured folder hierarchy for raw and processed data
- **Versioning**: Automatic versioning for data safety and recovery
- **Lifecycle Management**: Automatic cleanup of old data and versions
- **Security**: Enforced public access prevention and uniform bucket-level access
- **Cost Optimization**: Lifecycle rules to manage storage costs
- **Separation of Concerns**: Separate buckets for data and function source code

## Folder Structure

The module creates the following folder structure in the data bucket:

```
data-bucket/
├── raw/
│   └── georgian-budget-YYYY-MM-DD.xlsx
└── processed/
    ├── georgian_budget.csv
    ├── georgian_budget.json
    └── datapackage.json
```

## Lifecycle Rules

- **Age-based cleanup**: Files older than 365 days are automatically deleted
- **Version management**: Only the 3 most recent versions of each file are kept
- **Cost optimization**: Reduces storage costs by automatically managing old data
