# Compute Module for Georgian Budget Application
# Includes Cloud Functions, Cloud Scheduler, service accounts, and IAM resources

# Service account for Cloud Function
resource "google_service_account" "pipeline_function_sa" {
  account_id   = "georgian-budget-pipeline"
  display_name = "Georgian Budget Data Pipeline Function"
  description  = "Service account for the Georgian budget data processing Cloud Function"
}

# Service account for Cloud Scheduler
resource "google_service_account" "scheduler_sa" {
  account_id   = "georgian-budget-scheduler"
  display_name = "Georgian Budget Data Scheduler"
  description  = "Service account for Cloud Scheduler to trigger pipeline"
}

# Service Account for Backend API
resource "google_service_account" "backend_service_account" {
  account_id   = "georgian-budget-backend-sa"
  display_name = "Georgian Budget Backend API Service Account"
  description  = "Service account for the Georgian Budget Backend API Cloud Run service"
}

# Service Account for Frontend Web App
resource "google_service_account" "frontend_service_account" {
  account_id   = "georgian-budget-frontend-sa"
  display_name = "Georgian Budget Frontend Web App Service Account"
  description  = "Service account for the Georgian Budget Frontend Web App Cloud Run service"
}

# Archive the function source code including data-pipeline directory
data "archive_file" "function_source" {
  type        = "zip"
  output_path = "function-source.zip"
  excludes    = ["__pycache__", "*.pyc", ".git", "README.md", "*.log", ".terraform"]

  # Include moneyflow-functions directory
  source {
    content  = file("${var.function_source_path}/cloud_function_main.py")
    filename = "main.py"
  }

  source {
    content  = file("${var.function_source_path}/requirements.txt")
    filename = "requirements.txt"
  }

  # Include the entire data-pipeline directory from moneyflow-functions
  dynamic "source" {
    for_each = fileset(var.data_pipeline_path, "**/*")
    content {
      content  = fileexists("${var.data_pipeline_path}/${source.value}") ? file("${var.data_pipeline_path}/${source.value}") : ""
      filename = "data-pipeline/${source.value}"
    }
  }
}

# Upload function source to bucket
resource "google_storage_bucket_object" "function_source" {
  name   = "function-source-${data.archive_file.function_source.output_md5}.zip"
  bucket = var.function_source_bucket_name
  source = data.archive_file.function_source.output_path
}

# Cloud Function for data pipeline processing
resource "google_cloudfunctions2_function" "pipeline_processor" {
  name     = "georgian-budget-pipeline-processor"
  location = var.region

  build_config {
    runtime     = "python311"
    entry_point = "http_handler"

    source {
      storage_source {
        bucket = var.function_source_bucket_name
        object = google_storage_bucket_object.function_source.name
      }
    }
  }

  service_config {
    max_instance_count    = 1  # Cost optimization - single instance
    min_instance_count    = 0  # Scale to zero when not in use
    available_memory      = "2Gi"  # More memory for datapackage-pipelines
    timeout_seconds       = 540  # 9 minutes for data processing
    service_account_email = google_service_account.pipeline_function_sa.email

    environment_variables = {
      DATA_BUCKET_NAME     = var.data_bucket_name
      PROJECT_ID           = var.project_id
      ENVIRONMENT          = var.environment
      GEOSTAT_URL          = "https://geostat.ge/media/72030/saxelmwifo-biujeti-funqcionalur-chrilshi.xlsx"
    }
  }

  # Event trigger for Pub/Sub messages
  event_trigger {
    trigger_region = var.region
    event_type     = "google.cloud.pubsub.topic.v1.messagePublished"
    pubsub_topic   = google_pubsub_topic.pipeline_trigger.id

    retry_policy = "RETRY_POLICY_RETRY"
  }

  depends_on = [
    var.required_apis,
    google_storage_bucket_object.function_source
  ]

  labels = {
    environment = var.environment
    project     = "georgian-budget"
    component   = "data-pipeline"
  }
}

# Pub/Sub topic for triggering the function
resource "google_pubsub_topic" "pipeline_trigger" {
  name = "georgian-budget-pipeline-trigger"

  labels = {
    environment = var.environment
    project     = "georgian-budget"
    component   = "data-pipeline"
  }
}

# Allow unauthenticated access to the HTTP function
resource "google_cloudfunctions2_function_iam_member" "pipeline_processor_invoker" {
  project        = var.project_id
  location       = google_cloudfunctions2_function.pipeline_processor.location
  cloud_function = google_cloudfunctions2_function.pipeline_processor.name
  role           = "roles/cloudfunctions.invoker"
  member         = "allUsers"
}

# Quarterly schedule job - matches the current GitHub Actions schedule


# Runs daily at 6 AM UTC (9 AM Georgia time)
resource "google_cloud_scheduler_job" "daily_pipeline" {
  name             = "georgian-budget-daily-pipeline"
  description      = "Daily Georgian budget data pipeline execution"
  schedule         = "0 6 * * *"  # Daily at 6 AM UTC
  time_zone        = "UTC"
  region           = var.region

  retry_config {
    retry_count          = 2
    max_retry_duration   = "30s"
    min_backoff_duration = "5s"
    max_backoff_duration = "10s"
  }

  pubsub_target {
    topic_name = google_pubsub_topic.pipeline_trigger.id

    data = base64encode(jsonencode({
      trigger_type = "daily_scheduled"
      year         = "current"
      force_download = false
      check_only     = false
      source        = "cloud_scheduler_daily"
    }))
  }

  depends_on = [
    var.required_apis,
    google_pubsub_topic.pipeline_trigger
  ]
}

# Manual trigger job for immediate execution
resource "google_cloud_scheduler_job" "manual_pipeline_trigger" {
  name             = "georgian-budget-manual-trigger"
  description      = "Manual trigger for Georgian budget data pipeline"
  schedule         = "0 0 1 1 *"  # January 1st (effectively disabled)
  time_zone        = "UTC"
  region           = var.region

  # This job is paused by default and only used for manual triggers
  paused = true

  retry_config {
    retry_count          = 1
    max_retry_duration   = "30s"
    min_backoff_duration = "5s"
    max_backoff_duration = "10s"
  }

  pubsub_target {
    topic_name = google_pubsub_topic.pipeline_trigger.id

    data = base64encode(jsonencode({
      trigger_type   = "manual"
      year          = "current"
      force_download = true
      check_only     = false
      source         = "manual_trigger"
    }))
  }

  depends_on = [
    var.required_apis,
    google_pubsub_topic.pipeline_trigger
  ]
}

# IAM roles for pipeline function service account
resource "google_project_iam_member" "function_storage_admin" {
  project = var.project_id
  role    = "roles/storage.admin"
  member  = "serviceAccount:${google_service_account.pipeline_function_sa.email}"
}

resource "google_project_iam_member" "function_logging_writer" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.pipeline_function_sa.email}"
}

resource "google_project_iam_member" "function_monitoring_writer" {
  project = var.project_id
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${google_service_account.pipeline_function_sa.email}"
}

# Allow function to access external APIs (geostat.ge)
resource "google_project_iam_member" "function_networking" {
  project = var.project_id
  role    = "roles/compute.networkUser"
  member  = "serviceAccount:${google_service_account.pipeline_function_sa.email}"
}

# IAM roles for scheduler service account
resource "google_project_iam_member" "scheduler_function_invoker" {
  project = var.project_id
  role    = "roles/cloudfunctions.invoker"
  member  = "serviceAccount:${google_service_account.scheduler_sa.email}"
}

resource "google_project_iam_member" "scheduler_run_invoker" {
  project = var.project_id
  role    = "roles/run.invoker"
  member  = "serviceAccount:${google_service_account.scheduler_sa.email}"
}

# IAM binding for Backend Service Account to access Cloud Storage
resource "google_project_iam_member" "backend_storage_access" {
  project = var.project_id
  role    = "roles/storage.objectViewer"
  member  = "serviceAccount:${google_service_account.backend_service_account.email}"
}

# IAM binding for Backend Service Account to access Cloud SQL
resource "google_project_iam_member" "backend_sql_access" {
  project = var.project_id
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${google_service_account.backend_service_account.email}"
}

# IAM binding for Frontend Service Account (minimal permissions)
resource "google_project_iam_member" "frontend_basic_access" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.frontend_service_account.email}"
}

# Grant default Cloud Build service account access to deploy the function
resource "google_project_iam_member" "cloudbuild_function_developer" {
  project = var.project_id
  role    = "roles/cloudfunctions.developer"
  member  = "serviceAccount:${data.google_project.project.number}@cloudbuild.gserviceaccount.com"
}

# Get project information
data "google_project" "project" {
  project_id = var.project_id
}
