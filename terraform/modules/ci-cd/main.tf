# CI/CD Module for Georgian Budget Application
# Includes Cloud Build triggers, Artifact Registry, and related IAM

# Cloud Build Trigger for Backend API
resource "google_cloudbuild_trigger" "backend_trigger" {
  name        = "georgian-budget-backend-trigger"
  description = "Trigger for building and deploying Backend API"
  location    = var.region

  # Use source repository trigger
  source_to_build {
    uri       = "https://github.com/zelima/money-flow"
    ref       = "refs/heads/main"
    repo_type = "GITHUB"
  }

  git_file_source {
    path      = "api/cloudbuild.yaml"
    uri       = "https://github.com/zelima/money-flow"
    revision  = "refs/heads/main"
    repo_type = "GITHUB"
  }

  # Substitution variables for Cloud Build
  substitutions = {
    _CLOUD_STORAGE_BUCKET = var.data_bucket_name
    _DATABASE_URL = "postgresql://${var.database_user_name}:${var.database_user_password}@${var.database_private_ip}:5432/${var.database_name}"
    _ARTIFACT_REGISTRY_REPO = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.docker_repo.repository_id}"
    _ARTIFACT_REGISTRY_LOCATION = var.region
  }

  service_account = google_service_account.cloud_build_sa.id

  depends_on = [var.required_apis]
}

# Cloud Build Trigger for Frontend Web App
resource "google_cloudbuild_trigger" "frontend_trigger" {
  name        = "georgian-budget-frontend-trigger"
  description = "Trigger for building and deploying Frontend Web App"
  location    = var.region

  # Use source repository trigger
  source_to_build {
    uri       = "https://github.com/zelima/money-flow"
    ref       = "refs/heads/main"
    repo_type = "GITHUB"
  }

  git_file_source {
    path      = "web-app/cloudbuild.yaml"
    uri       = "https://github.com/zelima/money-flow"
    revision  = "refs/heads/main"
    repo_type = "GITHUB"
  }

  # Substitution variables for Cloud Build
  substitutions = {
    _ARTIFACT_REGISTRY_REPO = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.docker_repo.repository_id}"
    _ARTIFACT_REGISTRY_LOCATION = var.region
    _BACKEND_URL = var.domain_name != "" ? "https://${var.domain_name}/api" : "http://${var.load_balancer_ip}/api"
  }

  service_account = google_service_account.cloud_build_sa.id

  depends_on = [var.required_apis]
}

# Service Account for Cloud Build
resource "google_service_account" "cloud_build_sa" {
  account_id   = "georgian-budget-cloudbuild-sa"
  display_name = "Georgian Budget Cloud Build Service Account"
  description  = "Service account for Cloud Build to deploy to Cloud Run"
}

# IAM binding for Custom Cloud Build Service Account (for Cloud Run deployments)
resource "google_project_iam_member" "cloud_build_roles" {
  for_each = toset([
    "roles/run.admin",
    "roles/iam.serviceAccountUser",
    "roles/storage.admin",
    "roles/logging.logWriter"
  ])

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.cloud_build_sa.email}"
}

# IAM binding for Cloud Build to access Cloud Run
resource "google_project_iam_member" "cloud_build_run_invoker" {
  project = var.project_id
  role    = "roles/run.invoker"
  member  = "serviceAccount:${google_service_account.cloud_build_sa.email}"
}

# Artifact Registry Repository for Docker Images
resource "google_artifact_registry_repository" "docker_repo" {
  location      = var.region
  repository_id = "docker-repo"
  description   = "Docker repository for Georgian Budget application images"
  format        = "DOCKER"

  depends_on = [var.required_apis]
}

# IAM binding for Cloud Build to access Artifact Registry
resource "google_project_iam_member" "cloud_build_artifact_registry" {
  project = var.project_id
  role    = "roles/artifactregistry.writer"
  member  = "serviceAccount:${google_service_account.cloud_build_sa.email}"
}

# IAM binding for Cloud Build to deploy to Cloud Run (for compute module)
resource "google_project_iam_member" "cloud_build_run_admin" {
  project = var.project_id
  role    = "roles/run.admin"
  member  = "serviceAccount:${google_service_account.cloud_build_sa.email}"
}

# IAM binding for Cloud Build to act as service accounts (for compute module)
resource "google_project_iam_member" "cloud_build_sa_user" {
  for_each = toset([
    var.backend_service_account_email,
    var.frontend_service_account_email
  ])

  project = var.project_id
  role    = "roles/iam.serviceAccountUser"
  member  = "serviceAccount:${google_service_account.cloud_build_sa.email}"
}
