# Outputs for Compute Module

output "pipeline_function_sa_email" {
  description = "Email of the pipeline function service account"
  value       = google_service_account.pipeline_function_sa.email
}

output "scheduler_sa_email" {
  description = "Email of the scheduler service account"
  value       = google_service_account.scheduler_sa.email
}

output "backend_service_account_email" {
  description = "Email of the backend service account"
  value       = google_service_account.backend_service_account.email
}

output "frontend_service_account_email" {
  description = "Email of the frontend service account"
  value       = google_service_account.frontend_service_account.email
}

output "pipeline_processor_function_id" {
  description = "ID of the pipeline processor Cloud Function"
  value       = google_cloudfunctions2_function.pipeline_processor.id
}

output "pipeline_processor_function_name" {
  description = "Name of the pipeline processor Cloud Function"
  value       = google_cloudfunctions2_function.pipeline_processor.name
}

output "pipeline_processor_function_uri" {
  description = "URI of the pipeline processor Cloud Function"
  value       = google_cloudfunctions2_function.pipeline_processor.service_config[0].uri
}

output "pipeline_trigger_topic_id" {
  description = "ID of the pipeline trigger Pub/Sub topic"
  value       = google_pubsub_topic.pipeline_trigger.id
}

output "pipeline_trigger_topic_name" {
  description = "Name of the pipeline trigger Pub/Sub topic"
  value       = google_pubsub_topic.pipeline_trigger.name
}



output "manual_pipeline_trigger_job_id" {
  description = "ID of the manual pipeline trigger scheduler job"
  value       = google_cloud_scheduler_job.manual_pipeline_trigger.id
}

output "manual_pipeline_trigger_job_name" {
  description = "Name of the manual pipeline trigger scheduler job"
  value       = google_cloud_scheduler_job.manual_pipeline_trigger.name
}

output "daily_pipeline_job_id" {
  description = "ID of the daily pipeline scheduler job"
  value       = google_cloud_scheduler_job.daily_pipeline.id
}

output "daily_pipeline_job_name" {
  description = "Name of the daily pipeline scheduler job"
  value       = google_cloud_scheduler_job.daily_pipeline.name
}

output "function_source_object_name" {
  description = "Name of the function source object in storage"
  value       = google_storage_bucket_object.function_source.name
}
