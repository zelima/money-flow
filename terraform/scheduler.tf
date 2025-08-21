# Cloud Scheduler for Georgian Budget Data Pipeline

# Quarterly schedule job - matches the current GitHub Actions schedule
# Runs on 15th of March, June, September, and December at 6 AM UTC (9 AM Georgia time)
resource "google_cloud_scheduler_job" "quarterly_pipeline" {
  name             = "georgian-budget-quarterly-pipeline"
  description      = "Quarterly Georgian budget data pipeline execution"
  schedule         = "0 6 15 3,6,9,12 *"  # Same cron as GitHub Actions
  time_zone        = "UTC"
  region           = var.region
  attempt_deadline = "600s"  # 10 minutes timeout

  retry_config {
    retry_count          = 2
    max_retry_duration   = "30s"
    min_backoff_duration = "5s"
    max_backoff_duration = "10s"
  }

  pubsub_target {
    topic_name = google_pubsub_topic.pipeline_trigger.id

    data = base64encode(jsonencode({
      trigger_type = "scheduled"
      year         = "current"
      force_download = false
      check_only     = false
      source        = "cloud_scheduler"
    }))
  }

  depends_on = [
    google_project_service.required_apis,
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
  attempt_deadline = "600s"

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
    google_project_service.required_apis,
    google_pubsub_topic.pipeline_trigger
  ]
}
