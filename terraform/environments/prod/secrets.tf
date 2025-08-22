# Secret Manager Configuration for Georgian Budget Application
# Phase 2: Secure credential storage for Cloud Build and Cloud Run

# Database URL Secret
resource "google_secret_manager_secret" "database_url" {
  secret_id = "georgian-budget-database-url"

  replication {
    auto {}
  }

  depends_on = [google_project_service.required_apis]
}

# Database URL Secret Version
resource "google_secret_manager_secret_version" "database_url" {
  secret      = google_secret_manager_secret.database_url.name
  secret_data = "postgresql://${google_sql_user.database_user.name}:${google_sql_user.database_user.password}@${google_sql_database_instance.instance.private_ip_address}:5432/${google_sql_database.database.name}"

  depends_on = [
    google_sql_database_instance.instance,
    google_sql_database.database,
    google_sql_user.database_user
  ]
}

# IAM binding for Cloud Build to access secrets
resource "google_secret_manager_secret_iam_member" "cloud_build_database_url" {
  secret_id = google_secret_manager_secret.database_url.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.cloud_build_sa.email}"
}

# IAM binding for Backend Service Account to access secrets
resource "google_secret_manager_secret_iam_member" "backend_database_url" {
  secret_id = google_secret_manager_secret.database_url.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.backend_service_account.email}"
}
