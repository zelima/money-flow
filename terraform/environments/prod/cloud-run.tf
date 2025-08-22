# Cloud Run Infrastructure Configuration
# Phase 2: Service Accounts and Permissions Only
# Note: Actual Cloud Run service deployments are handled by Cloud Build

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

# IAM binding for Cloud Build to deploy to Cloud Run
resource "google_project_iam_member" "cloud_build_run_admin" {
  project = var.project_id
  role    = "roles/run.admin"
  member  = "serviceAccount:${google_service_account.cloud_build_sa.email}"
}

# IAM binding for Cloud Build to act as service accounts
resource "google_project_iam_member" "cloud_build_sa_user" {
  for_each = toset([
    google_service_account.backend_service_account.email,
    google_service_account.frontend_service_account.email
  ])

  project = var.project_id
  role    = "roles/iam.serviceAccountUser"
  member  = "serviceAccount:${google_service_account.cloud_build_sa.email}"
}

# VPC Connector is defined in cloud-sql.tf to avoid duplication
