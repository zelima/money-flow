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
      private_network = google_compute_network.vpc.id
    }

    user_labels = var.labels
  }

  deletion_protection = false  # Allow deletion for development
  
  depends_on = [
    google_project_service.required_apis,
    google_compute_network.vpc,
    google_compute_subnetwork.subnet,
    google_service_networking_connection.private_vpc_connection
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

# VPC Network for Cloud SQL
resource "google_compute_network" "vpc" {
  name                    = "georgian-budget-vpc"
  auto_create_subnetworks = false
  
  depends_on = [google_project_service.required_apis]
}

# Subnet for Cloud SQL and Cloud Run
resource "google_compute_subnetwork" "subnet" {
  name          = "georgian-budget-subnet"
  ip_cidr_range = "10.0.0.0/24"
  region        = var.region
  network       = google_compute_network.vpc.id
  
  # Enable flow logs for monitoring
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling       = 0.5
    metadata            = "INCLUDE_ALL_METADATA"
  }
}

# VPC Connector for Cloud Run to access Cloud SQL
resource "google_vpc_access_connector" "connector" {
  name          = "gb-vpc-connector"
  ip_cidr_range = "10.8.0.0/28"
  network       = google_compute_network.vpc.name
  region        = var.region
  machine_type  = "e2-micro"
  
  depends_on = [
    google_project_service.required_apis,
    google_compute_network.vpc
  ]
}

# Private Services Connection for Cloud SQL
resource "google_compute_global_address" "private_ip_address" {
  name          = "georgian-budget-private-ip"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.vpc.id
  
  depends_on = [google_compute_network.vpc]
}

resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.vpc.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
  
  depends_on = [
    google_project_service.required_apis,
    google_compute_global_address.private_ip_address
  ]
}

# Firewall rule to allow Cloud Run to access Cloud SQL
resource "google_compute_firewall" "cloud_run_to_sql" {
  name    = "allow-cloud-run-to-sql"
  network = google_compute_network.vpc.name
  
  allow {
    protocol = "tcp"
    ports    = ["5432"]
  }
  
  source_ranges = [google_compute_subnetwork.subnet.ip_cidr_range]
  target_tags   = ["postgresql"]
  
  depends_on = [google_compute_network.vpc]
}


