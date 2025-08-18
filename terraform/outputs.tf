# Outputs for Georgian Budget Data Pipeline Infrastructure

# Phase 1: Data Pipeline Outputs
output "data_pipeline_function_url" {
  description = "URL of the data processing Cloud Function"
  value       = google_cloudfunctions2_function.pipeline_processor.service_config[0].uri
}

output "data_pipeline_function_name" {
  description = "Name of the data processing Cloud Function"
  value       = google_cloudfunctions2_function.pipeline_processor.name
}

output "data_storage_bucket" {
  description = "Name of the data storage bucket"
  value       = google_storage_bucket.data_bucket.name
}

output "data_storage_bucket_url" {
  description = "URL of the data storage bucket"
  value       = google_storage_bucket.data_bucket.url
}

output "pipeline_scheduler_job" {
  description = "Name of the Cloud Scheduler job"
  value       = google_cloud_scheduler_job.quarterly_pipeline.name
}

output "pipeline_pubsub_topic" {
  description = "Name of the Pub/Sub topic for pipeline triggers"
  value       = google_pubsub_topic.pipeline_trigger.name
}

# Phase 2: Backend & Frontend Outputs
# Note: Cloud Run service URLs will be available after Cloud Build deployment

output "load_balancer_ip" {
  description = "IP address of the global load balancer"
  value       = google_compute_global_address.load_balancer_ip.address
}

output "load_balancer_url" {
  description = "URL of the global load balancer"
  value       = "http://${google_compute_global_address.load_balancer_ip.address}"
}

# Phase 2: Database Outputs
output "database_instance_name" {
  description = "Name of the Cloud SQL instance"
  value       = google_sql_database_instance.instance.name
}

output "database_connection_name" {
  description = "Connection name for the Cloud SQL instance"
  value       = google_sql_database_instance.instance.connection_name
}

output "database_private_ip_address" {
  description = "Private IP address of the Cloud SQL instance"
  value       = google_sql_database_instance.instance.private_ip_address
}

output "database_name" {
  description = "Name of the PostgreSQL database"
  value       = google_sql_database.database.name
}

output "database_user" {
  description = "Database username"
  value       = google_sql_user.database_user.name
}

output "database_password" {
  description = "Database password (sensitive)"
  value       = google_sql_user.database_user.password
  sensitive   = true
}

# Phase 2: Cloud Build Outputs
output "cloud_build_service_account" {
  description = "Email of the Cloud Build service account"
  value       = google_service_account.cloud_build_sa.email
}

output "artifact_registry_repository" {
  description = "Name of the Artifact Registry repository"
  value       = google_artifact_registry_repository.docker_repo.name
}

output "backend_trigger_id" {
  description = "ID of the backend Cloud Build trigger"
  value       = google_cloudbuild_trigger.backend_trigger.id
}

output "frontend_trigger_id" {
  description = "ID of the frontend Cloud Build trigger"
  value       = google_cloudbuild_trigger.frontend_trigger.id
}

# Service Account Outputs
output "backend_service_account" {
  description = "Email of the Backend API service account"
  value       = google_service_account.backend_service_account.email
}

output "frontend_service_account" {
  description = "Email of the Frontend Web App service account"
  value       = google_service_account.frontend_service_account.email
}

output "load_balancer_service_account" {
  description = "Email of the Load Balancer service account"
  value       = google_service_account.load_balancer_sa.email
}

# VPC Outputs
output "vpc_network" {
  description = "Name of the VPC network"
  value       = google_compute_network.vpc.name
}

output "vpc_subnet" {
  description = "Name of the VPC subnet"
  value       = google_compute_subnetwork.subnet.name
}

output "vpc_connector" {
  description = "Name of the VPC connector"
  value       = google_vpc_access_connector.connector.name
}
