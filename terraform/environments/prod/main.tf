# Georgian Budget Data Pipeline - GCP Infrastructure
# Phase 1: Data Pipeline Migration
# Phase 2: Backend & Frontend Deployment

terraform {
  required_version = ">= 1.0"

  backend "gcs" {
    bucket = "thelim-tf-states"
    prefix = "money-flow/prod"
  }

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

# Configure the Google Cloud Provider
provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

provider "google-beta" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

# Enable required APIs
resource "google_project_service" "required_apis" {
  for_each = toset([
    "cloudfunctions.googleapis.com",
    "cloudbuild.googleapis.com",
    "cloudscheduler.googleapis.com",
    "storage.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "eventarc.googleapis.com",
    "run.googleapis.com",
    "artifactregistry.googleapis.com",
    "sql-component.googleapis.com",
    "sqladmin.googleapis.com",
    "compute.googleapis.com",
    "vpcaccess.googleapis.com",
    "servicenetworking.googleapis.com",
    "secretmanager.googleapis.com",
    "dns.googleapis.com"
  ])

  service = each.key

  disable_dependent_services = false
  disable_on_destroy        = false
}

# Networking Module
module "networking" {
  source = "../../modules/networking"

  project_id = var.project_id
  region     = var.region

  domain_name         = var.domain_name
  force_https_redirect = var.force_https_redirect
  dns_provider        = var.dns_provider

  required_apis = [google_project_service.required_apis]
}

# Database Module
module "database" {
  source = "../../modules/database"

  region = var.region
  vpc_id = module.networking.vpc_id

  labels = var.labels

  required_apis = [google_project_service.required_apis]
}

# Compute Module
module "compute" {
  source = "../../modules/compute"

  project_id = var.project_id
  region     = var.region
  environment = var.environment

  function_source_path = "../../../cloud-function"
  data_pipeline_path   = "../cloud-function/data-pipeline"
  function_source_bucket_name = module.storage.function_source_bucket_name
  data_bucket_name = module.storage.data_bucket_name

  required_apis = [google_project_service.required_apis]
}

# Storage Module
module "storage" {
  source = "../../modules/storage"

  region = var.region
  data_bucket_name = local.bucket_name
  function_source_bucket_name = "${var.project_id}-function-source-${random_id.bucket_suffix.hex}"

  labels = var.labels
}

# Monitoring Module
module "monitoring" {
  source = "../../modules/monitoring"

  project_id = var.project_id
  load_balancer_ip = module.networking.load_balancer_ip
  pipeline_function_uri = module.compute.pipeline_processor_function_uri
  notification_email = var.notification_email

  required_apis = [google_project_service.required_apis]
}

# CI/CD Module
module "ci_cd" {
  source = "../../modules/ci-cd"

  project_id = var.project_id
  region = var.region
  domain_name = var.domain_name
  load_balancer_ip = module.networking.load_balancer_ip
  data_bucket_name = module.storage.data_bucket_name
  database_user_name = module.database.database_user_name
  database_user_password = module.database.database_user_password
  database_private_ip = module.database.instance_private_ip_address
  database_name = module.database.database_name
  backend_service_account_email = module.compute.backend_service_account_email
  frontend_service_account_email = module.compute.frontend_service_account_email

  required_apis = [google_project_service.required_apis]
}

# Security Module
module "security" {
  source = "../../modules/security"

  database_user_name = module.database.database_user_name
  database_user_password = module.database.database_user_password
  database_private_ip = module.database.instance_private_ip_address
  database_name = module.database.database_name
  cloud_build_service_account_email = module.ci_cd.cloud_build_service_account_email
  backend_service_account_email = module.compute.backend_service_account_email

  required_apis = [google_project_service.required_apis]
}

# Random suffix for globally unique resources
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

locals {
  bucket_name = "${var.project_id}-georgian-budget-data-${random_id.bucket_suffix.hex}"
}
