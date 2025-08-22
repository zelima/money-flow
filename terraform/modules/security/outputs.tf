# Outputs for Security Module

output "database_url_secret_id" {
  description = "ID of the database URL secret"
  value       = google_secret_manager_secret.database_url.secret_id
}

output "database_url_secret_name" {
  description = "Name of the database URL secret"
  value       = google_secret_manager_secret.database_url.name
}

output "database_url_secret_version_id" {
  description = "ID of the database URL secret version"
  value       = google_secret_manager_secret_version.database_url.id
}

output "database_url_secret_version_name" {
  description = "Name of the database URL secret version"
  value       = google_secret_manager_secret_version.database_url.name
}

output "cloud_build_secret_iam_member_id" {
  description = "ID of the Cloud Build secret IAM member"
  value       = google_secret_manager_secret_iam_member.cloud_build_database_url.id
}

output "backend_secret_iam_member_id" {
  description = "ID of the backend secret IAM member"
  value       = google_secret_manager_secret_iam_member.backend_database_url.id
}
