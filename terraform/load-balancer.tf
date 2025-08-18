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

# Placeholder Backend Service (will be updated by Cloud Build with actual Cloud Run services)
resource "google_compute_backend_service" "default_backend" {
  name        = "georgian-budget-default-backend"
  protocol    = "HTTP"
  port_name   = "http"
  timeout_sec = 30
  
  # This will serve a 404 until Cloud Build deploys the actual services
  # Cloud Build will update this to point to the real Cloud Run services
  
  depends_on = [google_project_service.required_apis]
}

# URL Map for Load Balancer (will be updated by Cloud Build)
resource "google_compute_url_map" "url_map" {
  name            = "georgian-budget-url-map"
  default_service = google_compute_backend_service.default_backend.id
  
  # Cloud Build will update this with proper routing rules
  # pointing to actual Cloud Run services
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

# HTTP to HTTPS Redirect (if domain is provided)
resource "google_compute_url_map" "redirect" {
  count = var.domain_name != "" ? 1 : 0
  name  = "georgian-budget-http-to-https"
  
  default_url_redirect {
    https_redirect = true
    strip_query    = false
  }
}

# HTTP Proxy for Redirect (if domain is provided)
resource "google_compute_target_http_proxy" "redirect_proxy" {
  count   = var.domain_name != "" ? 1 : 0
  name    = "georgian-budget-redirect-proxy"
  url_map = google_compute_url_map.redirect[0].id
}

# Global Forwarding Rule for HTTP Redirect (if domain is provided)
resource "google_compute_global_forwarding_rule" "http_redirect" {
  count      = var.domain_name != "" ? 1 : 0
  name       = "georgian-budget-http-redirect"
  target     = google_compute_target_http_proxy.redirect_proxy[0].id
  port_range = "80"
  ip_address = google_compute_global_address.load_balancer_ip.address
}