# Variables for CI/CD Module

variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The GCP region for CI/CD resources"
  type        = string
}

variable "domain_name" {
  description = "The domain name for the application (optional)"
  type        = string
  default     = ""
}

variable "load_balancer_ip" {
  description = "IP address of the load balancer for backend URL construction"
  type        = string
}

variable "data_bucket_name" {
  description = "Name of the data storage bucket"
  type        = string
}

variable "database_user_name" {
  description = "Database username for connection string"
  type        = string
}

variable "database_user_password" {
  description = "Database password for connection string"
  type        = string
}

variable "database_private_ip" {
  description = "Private IP address of the database instance"
  type        = string
}

variable "database_name" {
  description = "Name of the database"
  type        = string
}

variable "backend_service_account_email" {
  description = "Email of the backend service account"
  type        = string
}

variable "frontend_service_account_email" {
  description = "Email of the frontend service account"
  type        = string
}

variable "required_apis" {
  description = "List of required APIs that should be enabled before creating resources"
  type        = any
  default     = []
}
