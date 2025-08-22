# Variables for Security Module

variable "database_user_name" {
  description = "Database username for secret construction"
  type        = string
}

variable "database_user_password" {
  description = "Database password for secret construction"
  type        = string
  sensitive   = true
}

variable "database_private_ip" {
  description = "Private IP address of the database instance"
  type        = string
}

variable "database_name" {
  description = "Name of the database"
  type        = string
}

variable "cloud_build_service_account_email" {
  description = "Email of the Cloud Build service account"
  type        = string
}

variable "backend_service_account_email" {
  description = "Email of the backend service account"
  type        = string
}

variable "required_apis" {
  description = "List of required APIs that should be enabled before creating resources"
  type        = any
  default     = []
}
