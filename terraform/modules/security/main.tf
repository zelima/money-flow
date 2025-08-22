# Security Module for Georgian Budget Application
# Includes Secret Manager secrets and related IAM permissions

# Database URL Secret
resource "google_secret_manager_secret" "database_url" {
  secret_id = "georgian-budget-database-url"

  replication {
    auto {}
  }

  depends_on = [var.required_apis]
}

# Database URL Secret Version
resource "google_secret_manager_secret_version" "database_url" {
  secret      = google_secret_manager_secret.database_url.name
  secret_data = "postgresql://${var.database_user_name}:${var.database_user_password}@${var.database_private_ip}:5432/${var.database_name}"
}

# IAM binding for Cloud Build to access secrets
resource "google_secret_manager_secret_iam_member" "cloud_build_database_url" {
  secret_id = google_secret_manager_secret.database_url.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${var.cloud_build_service_account_email}"
}

# IAM binding for Backend Service Account to access secrets
resource "google_secret_manager_secret_iam_member" "backend_database_url" {
  secret_id = google_secret_manager_secret.database_url.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${var.backend_service_account_email}"
}
