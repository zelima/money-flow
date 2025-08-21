# Global HTTP(S) Load Balancer for Georgian Budget Application
# Phase 2: Production Load Balancing Infrastructure
# Note: Cloud Run services will be deployed by Cloud Build

# Service Account for Load Balancer
resource "google_service_account" "load_balancer_sa" {
  account_id   = "georgian-budget-lb-sa"
  display_name = "Georgian Budget Load Balancer Service Account"
  description  = "Service account for the global load balancer"
}

# IAM binding for Load Balancer Service Account
resource "google_project_iam_member" "load_balancer_roles" {
  for_each = toset([
    "roles/compute.networkViewer",
    "roles/compute.securityAdmin",
    "roles/run.invoker"
  ])
  
  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.load_balancer_sa.email}"
}

# Global IP Address for Load Balancer
resource "google_compute_global_address" "load_balancer_ip" {
  name         = "georgian-budget-lb-ip"
  address_type = "EXTERNAL"
  ip_version   = "IPV4"
  
  depends_on = [google_project_service.required_apis]
}

# Backend Service for Frontend (Cloud Run)
resource "google_compute_backend_service" "frontend_backend" {
  name        = "georgian-budget-frontend-backend"
  protocol    = "HTTP"
  port_name   = "http"
  timeout_sec = 30
  
  backend {
    group = google_compute_region_network_endpoint_group.frontend_neg.id
  }
  
  # Enable Cloud CDN for frontend assets
  enable_cdn = true
  
  # CDN cache key policy
  cdn_policy {
    cache_mode        = "CACHE_ALL_STATIC"
    client_ttl        = 3600  # 1 hour
    default_ttl       = 86400 # 24 hours
    max_ttl           = 604800 # 7 days
    
    # Cache static assets longer
    cache_key_policy {
      include_host         = true
      include_protocol     = true
      include_query_string = false
    }
  }
  
  depends_on = [google_project_service.required_apis]
}

# Backend Service for Backend API (Cloud Run)
resource "google_compute_backend_service" "backend_api" {
  name        = "georgian-budget-backend-api"
  protocol    = "HTTP"
  port_name   = "http"
  timeout_sec = 30
  
  backend {
    group = google_compute_region_network_endpoint_group.backend_neg.id
  }
  
  # No CDN for API endpoints
  enable_cdn = false
  
  depends_on = [google_project_service.required_apis]
}



# Network Endpoint Group for Frontend (Cloud Run)
resource "google_compute_region_network_endpoint_group" "frontend_neg" {
  name                  = "georgian-budget-frontend-neg"
  region               = var.region
  network_endpoint_type = "SERVERLESS"
  
  cloud_run {
    service = "georgian-budget-frontend"
  }
}

# Network Endpoint Group for Backend API (Cloud Run)
resource "google_compute_region_network_endpoint_group" "backend_neg" {
  name                  = "georgian-budget-backend-neg"
  region               = var.region
  network_endpoint_type = "SERVERLESS"
  
  cloud_run {
    service = "georgian-budget-backend-api"
  }
}

# URL Map for Load Balancer with proper routing
resource "google_compute_url_map" "url_map" {
  name            = "georgian-budget-url-map"
  default_service = google_compute_backend_service.frontend_backend.id
  
  # Route API requests to backend
  host_rule {
    hosts        = ["*"]
    path_matcher = "api-routes"
  }
  
  path_matcher {
    name            = "api-routes"
    default_service = google_compute_backend_service.frontend_backend.id
    
    # Route /api/* to backend API
    path_rule {
      paths   = ["/api/*"]
      service = google_compute_backend_service.backend_api.id
    }
    
    # Route /api to backend API
    path_rule {
      paths   = ["/api"]
      service = google_compute_backend_service.backend_api.id
    }
  }
}

# HTTP Proxy for Load Balancer
resource "google_compute_target_http_proxy" "http_proxy" {
  name    = "georgian-budget-http-proxy"
  url_map = google_compute_url_map.url_map.id
}

# HTTPS Proxy for Load Balancer (only if domain is provided)
resource "google_compute_target_https_proxy" "https_proxy" {
  count            = var.domain_name != "" ? 1 : 0
  name             = "georgian-budget-https-proxy"
  url_map          = google_compute_url_map.url_map.id
  ssl_certificates = [google_compute_managed_ssl_certificate.ssl_cert[0].id]
}

# Managed SSL Certificate (only if domain is provided)
resource "google_compute_managed_ssl_certificate" "ssl_cert" {
  count = var.domain_name != "" ? 1 : 0
  name  = "georgian-budget-ssl-cert"
  
  managed {
    domains = [var.domain_name]
  }
  
  lifecycle {
    create_before_destroy = true
  }
}

# Global Forwarding Rule for HTTP
resource "google_compute_global_forwarding_rule" "http" {
  name       = "georgian-budget-http"
  target     = google_compute_target_http_proxy.http_proxy.id
  port_range = "80"
  ip_address = google_compute_global_address.load_balancer_ip.address
}

# Global Forwarding Rule for HTTPS (only if domain is provided)
resource "google_compute_global_forwarding_rule" "https" {
  count      = var.domain_name != "" ? 1 : 0
  name       = "georgian-budget-https"
  target     = google_compute_target_https_proxy.https_proxy[0].id
  port_range = "443"
  ip_address = google_compute_global_address.load_balancer_ip.address
}

# HTTP to HTTPS Redirect (if domain is provided and redirect is enabled)
resource "google_compute_url_map" "redirect" {
  count = var.domain_name != "" && var.force_https_redirect ? 1 : 0
  name  = "georgian-budget-http-to-https"
  
  default_url_redirect {
    https_redirect = true
    strip_query    = false
  }
}

# Update HTTP proxy to use redirect when domain is configured
resource "google_compute_target_http_proxy" "http_proxy_updated" {
  count   = var.domain_name != "" && var.force_https_redirect ? 1 : 0
  name    = "georgian-budget-http-redirect-proxy"
  url_map = google_compute_url_map.redirect[0].id
}

# Global Forwarding Rule for HTTP Redirect (if domain is provided)
resource "google_compute_global_forwarding_rule" "http_redirect" {
  count      = var.domain_name != "" && var.force_https_redirect ? 1 : 0
  name       = "georgian-budget-http-redirect"
  target     = var.force_https_redirect ? google_compute_target_http_proxy.http_proxy_updated[0].id : google_compute_target_http_proxy.http_proxy.id
  port_range = "80"
  ip_address = google_compute_global_address.load_balancer_ip.address
}