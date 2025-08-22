# Variables for Database Module

variable "region" {
  description = "The GCP region for the Cloud SQL instance"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC network for private IP configuration"
  type        = string
}

variable "labels" {
  description = "Labels to apply to the Cloud SQL instance"
  type        = map(string)
  default     = {}
}

variable "required_apis" {
  description = "List of required APIs that should be enabled before creating resources"
  type        = any
  default     = []
}
