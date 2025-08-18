# Cloud Storage buckets for Georgian Budget Data Pipeline

# Main data bucket for raw and processed files
resource "google_storage_bucket" "data_bucket" {
  name     = local.bucket_name
  location = var.region
  
  # Prevent accidental deletion
  lifecycle {
    prevent_destroy = false
  }

  # Enable versioning for data safety
  versioning {
    enabled = true
  }

  # Lifecycle management to control costs
  lifecycle_rule {
    condition {
      age = 365  # Keep files for 1 year
    }
    action {
      type = "Delete"
    }
  }

  # Lifecycle rule for versioned objects
  lifecycle_rule {
    condition {
      num_newer_versions = 3  # Keep only 3 versions
    }
    action {
      type = "Delete"
    }
  }

  # Public access prevention
  public_access_prevention = "enforced"
  
  # Uniform bucket-level access
  uniform_bucket_level_access = true

  labels = {
    environment = var.environment
    project     = "georgian-budget"
    component   = "data-pipeline"
  }
}

# Raw data folder structure (organized via object naming)
# /raw/
#   └── georgian-budget-YYYY-MM-DD.xlsx

# Processed data folder structure  
# /processed/
#   ├── georgian_budget.csv
#   ├── georgian_budget.json
#   └── datapackage.json

# Create initial folder structure with placeholder objects
resource "google_storage_bucket_object" "raw_folder" {
  name   = "raw/.keep"
  bucket = google_storage_bucket.data_bucket.name
  content = "# Raw data folder for Georgian budget Excel files"
}

resource "google_storage_bucket_object" "processed_folder" {
  name   = "processed/.keep" 
  bucket = google_storage_bucket.data_bucket.name
  content = "# Processed data folder for CSV/JSON output"
}

# Bucket for Cloud Function source code
resource "google_storage_bucket" "function_source_bucket" {
  name     = "${var.project_id}-function-source-${random_id.bucket_suffix.hex}"
  location = var.region
  
  # Uniform bucket-level access
  uniform_bucket_level_access = true
  
  # Public access prevention
  public_access_prevention = "enforced"

  labels = {
    environment = var.environment
    project     = "georgian-budget"
    component   = "cloud-function"
  }
}
