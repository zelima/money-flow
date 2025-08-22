# Variables for Storage Module

variable "region" {
  description = "The GCP region for storage buckets"
  type        = string
}

variable "data_bucket_name" {
  description = "Name of the main data bucket"
  type        = string
}

variable "function_source_bucket_name" {
  description = "Name of the function source bucket"
  type        = string
}

variable "labels" {
  description = "Labels to apply to storage resources"
  type        = map(string)
  default     = {}
}
