# Outputs for Georgian Budget Data Pipeline Infrastructure

# Phase 1: Data Pipeline Outputs
output "data_pipeline_function_url" {
  description = "URL of the data processing Cloud Function"
  value       = module.compute.pipeline_processor_function_uri
}

output "data_pipeline_function_name" {
  description = "Name of the data processing Cloud Function"
  value       = module.compute.pipeline_processor_function_name
}

output "data_storage_bucket" {
  description = "Name of the data storage bucket"
  value       = module.storage.data_bucket_name
}

output "data_storage_bucket_url" {
  description = "URL of the data storage bucket"
  value       = module.storage.data_bucket_url
}

output "pipeline_scheduler_job" {
  description = "Name of the Cloud Scheduler job"
  value       = module.compute.quarterly_pipeline_job_name
}

output "pipeline_pubsub_topic" {
  description = "Name of the Pub/Sub topic for pipeline triggers"
  value       = module.compute.pipeline_trigger_topic_name
}

# Phase 2: Backend & Frontend Outputs
# Note: Cloud Run service URLs will be available after Cloud Build deployment

output "load_balancer_ip" {
  description = "IP address of the global load balancer"
  value       = module.networking.load_balancer_ip
}

output "load_balancer_url" {
  description = "URL of the global load balancer"
  value       = var.domain_name != "" ? "https://${var.domain_name}" : "http://${module.networking.load_balancer_ip}"
}

output "domain_setup_instructions" {
  description = "Instructions for setting up your domain"
  value = var.domain_name != "" ? jsonencode({
    domain = var.domain_name
    ip_address = module.networking.load_balancer_ip
    dns_records = [
      {
        type = "CNAME"
        name = "moneyflow"
        value = module.networking.load_balancer_ip
      }
    ]
    ssl_status = "Google-managed SSL certificate will be automatically provisioned"
    note = "Add CNAME record for 'moneyflow' pointing to your load balancer IP"
  }) : "No domain configured - using IP address"
}

output "frontend_backend_service" {
  description = "Name of the frontend backend service"
  value       = module.networking.frontend_backend_service_id
}

output "backend_api_service" {
  description = "Name of the backend API service"
  value       = module.networking.backend_api_service_id
}

# Phase 2: Database Outputs (from database module)
output "database_instance_name" {
  description = "Name of the Cloud SQL instance"
  value       = module.database.instance_name
}

output "database_connection_name" {
  description = "Connection name for the Cloud SQL instance"
  value       = module.database.instance_connection_name
}

output "database_private_ip_address" {
  description = "Private IP address of the Cloud SQL instance"
  value       = module.database.instance_private_ip_address
}

output "database_name" {
  description = "Name of the PostgreSQL database"
  value       = module.database.database_name
}

output "database_user" {
  description = "Database username"
  value       = module.database.database_user_name
}

output "database_password" {
  description = "Database password (sensitive)"
  value       = module.database.database_user_password
  sensitive   = true
}

# Phase 2: Cloud Build Outputs
output "cloud_build_service_account" {
  description = "Email of the Cloud Build service account"
  value       = module.ci_cd.cloud_build_service_account_email
}

output "artifact_registry_repository" {
  description = "Name of the Artifact Registry repository"
  value       = module.ci_cd.artifact_registry_repository_name
}

output "backend_trigger_id" {
  description = "ID of the backend Cloud Build trigger"
  value       = module.ci_cd.backend_trigger_id
}

output "frontend_trigger_id" {
  description = "ID of the frontend Cloud Build trigger"
  value       = module.ci_cd.frontend_trigger_id
}

# Service Account Outputs
output "backend_service_account" {
  description = "Email of the Backend API service account"
  value       = module.compute.backend_service_account_email
}

output "frontend_service_account" {
  description = "Email of the Frontend Web App service account"
  value       = module.compute.frontend_service_account_email
}

output "load_balancer_service_account" {
  description = "Email of the Load Balancer service account"
  value       = module.networking.load_balancer_sa_email
}

# VPC Outputs (from networking module)
output "vpc_network" {
  description = "Name of the VPC network"
  value       = module.networking.vpc_name
}

output "vpc_subnet" {
  description = "Name of the VPC subnet"
  value       = module.networking.subnet_name
}

output "vpc_connector" {
  description = "Name of the VPC connector"
  value       = module.networking.vpc_connector_name
}

# Monitoring Outputs
output "monitoring_dashboard_url" {
  description = "URL of the Cloud Monitoring dashboard"
  value       = module.monitoring.dashboard_url
}

output "frontend_uptime_check" {
  description = "Name of the frontend uptime check"
  value       = module.monitoring.frontend_uptime_check_name
}

output "backend_uptime_check" {
  description = "Name of the backend API uptime check"
  value       = module.monitoring.backend_uptime_check_name
}

output "pipeline_uptime_check" {
  description = "Name of the pipeline function uptime check"
  value       = module.monitoring.pipeline_uptime_check_name
}

# DNS Outputs (from networking module)
output "dns_configuration" {
  description = "DNS configuration status and details"
  value = var.dns_provider == "manual" ? {
    status = "Manual DNS configuration required"
    instructions = "Add A record: moneyflow -> ${module.networking.load_balancer_ip}"
  } : {
    status = "DNS managed by Terraform"
    provider = var.dns_provider
    record_created = var.dns_provider == "cloudflare" ? "moneyflow.thelim.dev -> ${module.networking.load_balancer_ip}" : "managed by Google Cloud DNS"
  }
}
