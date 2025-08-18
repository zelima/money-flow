# Cloud Build Configuration for Georgian Budget Application
# Phase 2: Automated CI/CD Pipeline
#
# IMPORTANT: Before applying this configuration, you must manually connect
# the GitHub repository in GCP Console:
# 1. Go to Cloud Build > Repositories
# 2. Click "Connect Repository"
# 3. Select GitHub and authorize the connection
# 4. Choose the "zelima/money-flow" repository
# 5. Then run `terraform apply` to create the triggers

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
    path      = "money-flow/api/cloudbuild.yaml"
    uri       = "https://github.com/zelima/money-flow"
    revision  = "refs/heads/main"
    repo_type = "GITHUB"
  }

  # Only trigger on changes to API files
  included_files = [
    "money-flow/api/**"
  ]
  
  # Substitution variables for Cloud Build
  substitutions = {
    _CLOUD_STORAGE_BUCKET = google_storage_bucket.data_bucket.name
    _DATABASE_URL = "postgresql://${google_sql_user.database_user.name}:${google_sql_user.database_user.password}@${google_sql_database_instance.instance.connection_name}/${google_sql_database.database.name}"
    _ARTIFACT_REGISTRY_REPO = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.docker_repo.repository_id}"
    _ARTIFACT_REGISTRY_LOCATION = var.region
  }
  
  service_account = google_service_account.cloud_build_sa.id
  
  depends_on = [
    google_project_service.required_apis,
    google_artifact_registry_repository.docker_repo,
    google_storage_bucket.data_bucket
  ]
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
    path      = "money-flow/web-app/cloudbuild.yaml"
    uri       = "https://github.com/zelima/money-flow"
    revision  = "refs/heads/main"
    repo_type = "GITHUB"
  }

  # Only trigger on changes to web-app files
  included_files = [
    "money-flow/web-app/**"
  ]
  
     # Substitution variables for Cloud Build
   substitutions = {
     _ARTIFACT_REGISTRY_REPO = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.docker_repo.repository_id}"
     _ARTIFACT_REGISTRY_LOCATION = var.region
   }
   
   service_account = google_service_account.cloud_build_sa.id
   
   depends_on = [
     google_project_service.required_apis,
     google_artifact_registry_repository.docker_repo
   ]
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
  
  depends_on = [google_project_service.required_apis]
}

# IAM binding for Cloud Build to access Artifact Registry
resource "google_project_iam_member" "cloud_build_artifact_registry" {
  project = var.project_id
  role    = "roles/artifactregistry.writer"
  member  = "serviceAccount:${google_service_account.cloud_build_sa.email}"
}


