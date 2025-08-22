# Cloud Function for Georgian Budget Data Pipeline

# Archive the function source code including data-pipeline directory
data "archive_file" "function_source" {
  type        = "zip"
  output_path = "function-source.zip"
  excludes    = ["__pycache__", "*.pyc", ".git", "README.md", "*.log", ".terraform"]

  # Include cloud-function directory
  source {
    content  = file("../cloud-function/cloud_function_main.py")
    filename = "main.py"
  }

  source {
    content  = file("../cloud-function/requirements.txt")
    filename = "requirements.txt"
  }

  # Include the entire data-pipeline directory from cloud-function
  dynamic "source" {
    for_each = fileset("../cloud-function/data-pipeline", "**/*")
    content {
      content  = fileexists("../cloud-function/data-pipeline/${source.value}") ? file("../cloud-function/data-pipeline/${source.value}") : ""
      filename = "data-pipeline/${source.value}"
    }
  }
}

# Upload function source to bucket
resource "google_storage_bucket_object" "function_source" {
  name   = "function-source-${data.archive_file.function_source.output_md5}.zip"
  bucket = google_storage_bucket.function_source_bucket.name
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
        bucket = google_storage_bucket.function_source_bucket.name
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
      DATA_BUCKET_NAME     = google_storage_bucket.data_bucket.name
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
    google_project_service.required_apis,
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
