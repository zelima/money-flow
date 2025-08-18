# Outputs for Georgian Budget Data Pipeline Infrastructure

# Storage outputs
output "data_bucket_name" {
  description = "Name of the main data storage bucket"
  value       = google_storage_bucket.data_bucket.name
}

output "data_bucket_url" {
  description = "URL of the main data storage bucket"
  value       = google_storage_bucket.data_bucket.url
}

output "function_source_bucket_name" {
  description = "Name of the function source storage bucket"
  value       = google_storage_bucket.function_source_bucket.name
}

# Cloud Function outputs
output "pipeline_processor_function_name" {
  description = "Name of the data processing Cloud Function"
  value       = google_cloudfunctions2_function.pipeline_processor.name
}

output "pipeline_processor_function_url" {
  description = "URL of the data processing Cloud Function (HTTP endpoint)"
  value       = google_cloudfunctions2_function.pipeline_processor.service_config[0].uri
}



# Pub/Sub outputs
output "pipeline_trigger_topic" {
  description = "Name of the Pub/Sub topic for triggering the pipeline"
  value       = google_pubsub_topic.pipeline_trigger.name
}

output "pipeline_trigger_topic_id" {
  description = "Full ID of the Pub/Sub topic for triggering the pipeline"
  value       = google_pubsub_topic.pipeline_trigger.id
}

# Scheduler outputs
output "quarterly_schedule_job_name" {
  description = "Name of the quarterly Cloud Scheduler job"
  value       = google_cloud_scheduler_job.quarterly_pipeline.name
}

output "manual_trigger_job_name" {
  description = "Name of the manual trigger Cloud Scheduler job"
  value       = google_cloud_scheduler_job.manual_pipeline_trigger.name
}



# Service Account outputs
output "pipeline_function_service_account_email" {
  description = "Email of the service account used by Cloud Functions"
  value       = google_service_account.pipeline_function_sa.email
}

output "scheduler_service_account_email" {
  description = "Email of the service account used by Cloud Scheduler"
  value       = google_service_account.scheduler_sa.email
}

# Data endpoints for your application
output "processed_data_urls" {
  description = "URLs for accessing processed data files"
  value = {
    csv_url        = "https://storage.googleapis.com/${google_storage_bucket.data_bucket.name}/processed/georgian_budget.csv"
    json_url       = "https://storage.googleapis.com/${google_storage_bucket.data_bucket.name}/processed/georgian_budget.json"
    datapackage_url = "https://storage.googleapis.com/${google_storage_bucket.data_bucket.name}/processed/datapackage.json"
  }
}

# Project information
output "project_id" {
  description = "The GCP project ID"
  value       = var.project_id
}

output "region" {
  description = "The GCP region where resources are deployed"
  value       = var.region
}

# Manual trigger commands
output "manual_trigger_commands" {
  description = "Commands to manually trigger the pipeline"
  value = {
    via_http     = "curl -X POST ${google_cloudfunctions2_function.pipeline_processor.service_config[0].uri} -H 'Content-Type: application/json' -d '{\"year\":\"2024\",\"force_download\":true}'"
    via_gcloud   = "gcloud scheduler jobs run ${google_cloud_scheduler_job.manual_pipeline_trigger.name} --location=${var.region}"
    via_pubsub   = "gcloud pubsub topics publish ${google_pubsub_topic.pipeline_trigger.name} --message='{\"trigger_type\":\"manual\"}'"
  }
}
