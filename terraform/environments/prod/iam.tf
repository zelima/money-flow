# IAM Configuration for Georgian Budget Data Pipeline

# Service account for Cloud Function
resource "google_service_account" "pipeline_function_sa" {
  account_id   = "georgian-budget-pipeline"
  display_name = "Georgian Budget Data Pipeline Function"
  description  = "Service account for the Georgian budget data processing Cloud Function"
}

# Service account for Cloud Scheduler
resource "google_service_account" "scheduler_sa" {
  account_id   = "georgian-budget-scheduler"
  display_name = "Georgian Budget Data Scheduler"
  description  = "Service account for Cloud Scheduler to trigger pipeline"
}

# IAM roles for pipeline function service account
resource "google_project_iam_member" "function_storage_admin" {
  project = var.project_id
  role    = "roles/storage.admin"
  member  = "serviceAccount:${google_service_account.pipeline_function_sa.email}"
}

resource "google_project_iam_member" "function_logging_writer" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.pipeline_function_sa.email}"
}

resource "google_project_iam_member" "function_monitoring_writer" {
  project = var.project_id
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${google_service_account.pipeline_function_sa.email}"
}

# Allow function to access external APIs (geostat.ge)
resource "google_project_iam_member" "function_networking" {
  project = var.project_id
  role    = "roles/compute.networkUser"
  member  = "serviceAccount:${google_service_account.pipeline_function_sa.email}"
}

# IAM roles for scheduler service account
resource "google_project_iam_member" "scheduler_function_invoker" {
  project = var.project_id
  role    = "roles/cloudfunctions.invoker"
  member  = "serviceAccount:${google_service_account.scheduler_sa.email}"
}

resource "google_project_iam_member" "scheduler_run_invoker" {
  project = var.project_id
  role    = "roles/run.invoker"
  member  = "serviceAccount:${google_service_account.scheduler_sa.email}"
}

# Grant default Cloud Build service account access to deploy the function
resource "google_project_iam_member" "cloudbuild_function_developer" {
  project = var.project_id
  role    = "roles/cloudfunctions.developer"
  member  = "serviceAccount:${data.google_project.project.number}@cloudbuild.gserviceaccount.com"
}

# Get project information
data "google_project" "project" {
  project_id = var.project_id
}
