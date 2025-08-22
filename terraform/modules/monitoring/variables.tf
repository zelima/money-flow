# Variables for Monitoring Module

variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "load_balancer_ip" {
  description = "IP address of the load balancer for uptime checks"
  type        = string
}

variable "pipeline_function_uri" {
  description = "URI of the pipeline function for uptime checks"
  type        = string
}

variable "notification_email" {
  description = "Email address for monitoring notifications"
  type        = string
  default     = ""
}

variable "required_apis" {
  description = "List of required APIs that should be enabled before creating resources"
  type        = any
  default     = []
}
