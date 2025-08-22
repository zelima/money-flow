# Variables for Networking Module

variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The GCP region for resources"
  type        = string
}

variable "domain_name" {
  description = "The domain name for SSL certificate (optional)"
  type        = string
  default     = ""
}

variable "force_https_redirect" {
  description = "Whether to force HTTPS redirect when domain is configured"
  type        = bool
  default     = true
}

variable "dns_provider" {
  description = "DNS provider to use (google_cloud, cloudflare, etc.)"
  type        = string
  default     = "google_cloud"
}

variable "required_apis" {
  description = "List of required APIs that should be enabled before creating resources"
  type        = any
  default     = []
}
