# Database Module for Georgian Budget Application
# Includes Cloud SQL instance, database, user, and related resources

# Cloud SQL Instance for PostgreSQL
resource "google_sql_database_instance" "instance" {
  name             = "georgian-budget-postgresql"
  database_version = "POSTGRES_15"
  region           = var.region

  settings {
    tier            = "db-f1-micro"
    availability_type = "ZONAL"
    disk_type       = "PD_SSD"

    backup_configuration {
      enabled                        = true
      start_time                     = "02:00"
      point_in_time_recovery_enabled = true
      transaction_log_retention_days = 7
      backup_retention_settings {
        retained_backups = 7
        retention_unit   = "COUNT"
      }
    }

    ip_configuration {
      ipv4_enabled    = false  # Private IP only for security
      private_network = var.vpc_id
    }

    user_labels = var.labels
  }

  deletion_protection = false  # Allow deletion for development

  depends_on = [
    var.required_apis,
    var.vpc_id
  ]
}

# PostgreSQL Database
resource "google_sql_database" "database" {
  name     = "georgian_budget"
  instance = google_sql_database_instance.instance.name

  depends_on = [google_sql_database_instance.instance]
}

# Database User
resource "google_sql_user" "database_user" {
  name     = "budget_user"
  instance = google_sql_database_instance.instance.name
  password = random_password.database_password.result

  depends_on = [google_sql_database_instance.instance]
}

# Random password for database user
resource "random_password" "database_password" {
  length  = 16
  special = true
}
