# Outputs for Networking Module

output "vpc_id" {
  description = "The ID of the VPC network"
  value       = google_compute_network.vpc.id
}

output "vpc_name" {
  description = "The name of the VPC network"
  value       = google_compute_network.vpc.name
}

output "vpc_self_link" {
  description = "The self-link of the VPC network"
  value       = google_compute_network.vpc.self_link
}

output "subnet_id" {
  description = "The ID of the subnet"
  value       = google_compute_subnetwork.subnet.id
}

output "subnet_name" {
  description = "The name of the subnet"
  value       = google_compute_subnetwork.subnet.name
}

output "subnet_ip_cidr_range" {
  description = "The IP CIDR range of the subnet"
  value       = google_compute_subnetwork.subnet.ip_cidr_range
}

output "vpc_connector_id" {
  description = "The ID of the VPC connector"
  value       = google_vpc_access_connector.connector.id
}

output "vpc_connector_name" {
  description = "The name of the VPC connector"
  value       = google_vpc_access_connector.connector.name
}

output "private_ip_address_name" {
  description = "The name of the private IP address for VPC peering"
  value       = google_compute_global_address.private_ip_address.name
}

output "load_balancer_ip" {
  description = "The external IP address of the load balancer"
  value       = google_compute_global_address.load_balancer_ip.address
}

output "load_balancer_sa_email" {
  description = "The email of the load balancer service account"
  value       = google_service_account.load_balancer_sa.email
}

output "frontend_backend_service_id" {
  description = "The ID of the frontend backend service"
  value       = google_compute_backend_service.frontend_backend.id
}

output "backend_api_service_id" {
  description = "The ID of the backend API service"
  value       = google_compute_backend_service.backend_api.id
}

output "frontend_neg_id" {
  description = "The ID of the frontend network endpoint group"
  value       = google_compute_region_network_endpoint_group.frontend_neg.id
}

output "backend_neg_id" {
  description = "The ID of the backend network endpoint group"
  value       = google_compute_region_network_endpoint_group.backend_neg.id
}

output "url_map_id" {
  description = "The ID of the URL map"
  value       = google_compute_url_map.url_map.id
}

output "http_proxy_id" {
  description = "The ID of the HTTP proxy"
  value       = google_compute_target_http_proxy.http_proxy.id
}

output "https_proxy_id" {
  description = "The ID of the HTTPS proxy (if created)"
  value       = var.domain_name != "" ? google_compute_target_https_proxy.https_proxy[0].id : null
}

output "ssl_certificate_id" {
  description = "The ID of the SSL certificate (if created)"
  value       = var.domain_name != "" ? google_compute_managed_ssl_certificate.ssl_cert[0].id : null
}

output "http_forwarding_rule_id" {
  description = "The ID of the HTTP forwarding rule"
  value       = google_compute_global_forwarding_rule.http.id
}

output "https_forwarding_rule_id" {
  description = "The ID of the HTTPS forwarding rule (if created)"
  value       = var.domain_name != "" ? google_compute_global_forwarding_rule.https[0].id : null
}
