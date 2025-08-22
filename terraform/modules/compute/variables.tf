# Variables for Compute Module

variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The GCP region for resources"
  type        = string
}

variable "environment" {
  description = "The environment (dev, staging, prod)"
  type        = string
}

variable "function_source_path" {
  description = "Path to the cloud function source code"
  type        = string
}

variable "data_pipeline_path" {
  description = "Path to the data pipeline source code"
  type        = string
}

variable "function_source_bucket_name" {
  description = "Name of the bucket to store function source code"
  type        = string
}

variable "data_bucket_name" {
  description = "Name of the data bucket"
  type        = string
}

variable "required_apis" {
  description = "List of required APIs that should be enabled before creating resources"
  type        = any
  default     = []
}
