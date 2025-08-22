# Outputs for Storage Module

output "data_bucket_id" {
  description = "ID of the main data bucket"
  value       = google_storage_bucket.data_bucket.id
}

output "data_bucket_name" {
  description = "Name of the main data bucket"
  value       = google_storage_bucket.data_bucket.name
}

output "data_bucket_url" {
  description = "URL of the main data bucket"
  value       = google_storage_bucket.data_bucket.url
}

output "data_bucket_self_link" {
  description = "Self link of the main data bucket"
  value       = google_storage_bucket.data_bucket.self_link
}

output "function_source_bucket_id" {
  description = "ID of the function source bucket"
  value       = google_storage_bucket.function_source_bucket.id
}

output "function_source_bucket_name" {
  description = "Name of the function source bucket"
  value       = google_storage_bucket.function_source_bucket.name
}

output "function_source_bucket_url" {
  description = "URL of the function source bucket"
  value       = google_storage_bucket.function_source_bucket.url
}

output "function_source_bucket_self_link" {
  description = "Self link of the function source bucket"
  value       = google_storage_bucket.function_source_bucket.self_link
}

output "raw_folder_object_id" {
  description = "ID of the raw folder placeholder object"
  value       = google_storage_bucket_object.raw_folder.id
}

output "processed_folder_object_id" {
  description = "ID of the processed folder placeholder object"
  value       = google_storage_bucket_object.processed_folder.id
}
