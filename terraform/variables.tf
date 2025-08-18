# Variables for Georgian Budget Data Pipeline Infrastructure

variable "project_id" {
  description = "The GCP project ID"
  type        = string
  validation {
    condition     = length(var.project_id) > 0
    error_message = "Project ID cannot be empty."
  }
}

variable "region" {
  description = "The GCP region for resources"
  type        = string
  default     = "europe-west1"
  validation {
    condition = can(regex("^[a-z]+-[a-z]+[0-9]+$", var.region))
    error_message = "Region must be a valid GCP region format."
  }
}

variable "zone" {
  description = "The GCP zone for resources that require a zone"
  type        = string
  default     = "europe-west1-b"
  validation {
    condition = can(regex("^[a-z]+-[a-z]+[0-9]+-[a-z]$", var.zone))
    error_message = "Zone must be a valid GCP region format."
  }
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "prod"
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "domain_name" {
  description = "Custom domain name for the application (optional)"
  type        = string
  default     = ""
  validation {
    condition = var.domain_name == "" || can(regex("^[a-zA-Z0-9]([a-zA-Z0-9\\-]{0,61}[a-zA-Z0-9])?\\.[a-zA-Z]{2,}$", var.domain_name))
    error_message = "Domain name must be a valid domain format or empty."
  }
}

variable "pipeline_schedule" {
  description = "Cron schedule for quarterly pipeline runs"
  type        = string
  default     = "0 6 15 3,6,9,12 *"  # 15th of Mar, Jun, Sep, Dec at 6 AM UTC
}

variable "data_retention_days" {
  description = "Number of days to retain data in storage buckets"
  type        = number
  default     = 365
  validation {
    condition     = var.data_retention_days >= 30 && var.data_retention_days <= 2555  # 7 years max
    error_message = "Data retention must be between 30 and 2555 days."
  }
}

variable "function_timeout_seconds" {
  description = "Timeout in seconds for the data processing Cloud Function"
  type        = number
  default     = 540  # 9 minutes
  validation {
    condition     = var.function_timeout_seconds >= 60 && var.function_timeout_seconds <= 3600
    error_message = "Function timeout must be between 60 and 3600 seconds."
  }
}

variable "function_memory" {
  description = "Memory allocation for Cloud Functions"
  type        = string
  default     = "1Gi"
  validation {
    condition = contains([
      "128Mi", "256Mi", "512Mi", "1Gi", "2Gi", "4Gi", "8Gi"
    ], var.function_memory)
    error_message = "Function memory must be one of: 128Mi, 256Mi, 512Mi, 1Gi, 2Gi, 4Gi, 8Gi."
  }
}

variable "enable_public_api_access" {
  description = "Whether to allow public access to the pipeline API function"
  type        = bool
  default     = true
}

variable "budget_alert_threshold" {
  description = "Budget alert threshold in USD"
  type        = number
  default     = 200
  validation {
    condition     = var.budget_alert_threshold > 0
    error_message = "Budget alert threshold must be greater than 0."
  }
}

variable "notification_email" {
  description = "Email address for budget and pipeline notifications"
  type        = string
  default     = ""
  validation {
    condition = var.notification_email == "" || can(regex("^[\\w\\.-]+@[\\w\\.-]+\\.[\\w]+$", var.notification_email))
    error_message = "Notification email must be a valid email address or empty."
  }
}

variable "labels" {
  description = "Labels to apply to all resources"
  type        = map(string)
  default = {
    project     = "georgian-budget"
    managed_by  = "terraform"
    environment = "prod"
  }
}
