# Outputs for CI/CD Module

output "cloud_build_service_account_email" {
  description = "Email of the Cloud Build service account"
  value       = google_service_account.cloud_build_sa.email
}

output "cloud_build_service_account_id" {
  description = "ID of the Cloud Build service account"
  value       = google_service_account.cloud_build_sa.id
}

output "backend_trigger_id" {
  description = "ID of the backend Cloud Build trigger"
  value       = google_cloudbuild_trigger.backend_trigger.id
}

output "backend_trigger_name" {
  description = "Name of the backend Cloud Build trigger"
  value       = google_cloudbuild_trigger.backend_trigger.name
}

output "frontend_trigger_id" {
  description = "ID of the frontend Cloud Build trigger"
  value       = google_cloudbuild_trigger.frontend_trigger.id
}

output "frontend_trigger_name" {
  description = "Name of the frontend Cloud Build trigger"
  value       = google_cloudbuild_trigger.frontend_trigger.name
}

output "terraform_trigger_id" {
  description = "ID of the Terraform deployment trigger"
  value       = google_cloudbuild_trigger.terraform_deployment_trigger.id
}

output "terraform_trigger_name" {
  description = "Name of the Terraform deployment trigger"
  value       = google_cloudbuild_trigger.terraform_deployment_trigger.name
}

output "artifact_registry_repository_id" {
  description = "ID of the Artifact Registry repository"
  value       = google_artifact_registry_repository.docker_repo.repository_id
}

output "artifact_registry_repository_name" {
  description = "Name of the Artifact Registry repository"
  value       = google_artifact_registry_repository.docker_repo.name
}

output "artifact_registry_repository_location" {
  description = "Location of the Artifact Registry repository"
  value       = google_artifact_registry_repository.docker_repo.location
}

output "artifact_registry_repository_url" {
  description = "URL of the Artifact Registry repository"
  value       = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.docker_repo.repository_id}"
}
