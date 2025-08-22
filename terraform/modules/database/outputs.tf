# Outputs for Database Module

output "instance_id" {
  description = "The ID of the Cloud SQL instance"
  value       = google_sql_database_instance.instance.id
}

output "instance_name" {
  description = "The name of the Cloud SQL instance"
  value       = google_sql_database_instance.instance.name
}

output "instance_connection_name" {
  description = "The connection name of the Cloud SQL instance"
  value       = google_sql_database_instance.instance.connection_name
}

output "instance_first_ip_address" {
  description = "The first IP address of the Cloud SQL instance"
  value       = google_sql_database_instance.instance.first_ip_address
}

output "instance_private_ip_address" {
  description = "The private IP address of the Cloud SQL instance"
  value       = google_sql_database_instance.instance.private_ip_address
}

output "database_name" {
  description = "The name of the PostgreSQL database"
  value       = google_sql_database.database.name
}

output "database_user_name" {
  description = "The name of the database user"
  value       = google_sql_user.database_user.name
}

output "database_user_password" {
  description = "The password for the database user (sensitive)"
  value       = google_sql_user.database_user.password
  sensitive   = true
}

output "database_url" {
  description = "The database connection URL (sensitive)"
  value       = "postgresql://${google_sql_user.database_user.name}:${google_sql_user.database_user.password}@${google_sql_database_instance.instance.private_ip_address}:5432/${google_sql_database.database.name}"
  sensitive   = true
}
