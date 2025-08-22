# Outputs for Monitoring Module

output "frontend_uptime_check_id" {
  description = "ID of the frontend uptime check"
  value       = google_monitoring_uptime_check_config.frontend_uptime.id
}

output "frontend_uptime_check_name" {
  description = "Name of the frontend uptime check"
  value       = google_monitoring_uptime_check_config.frontend_uptime.display_name
}

output "backend_uptime_check_id" {
  description = "ID of the backend uptime check"
  value       = google_monitoring_uptime_check_config.backend_uptime.id
}

output "backend_uptime_check_name" {
  description = "Name of the backend uptime check"
  value       = google_monitoring_uptime_check_config.backend_uptime.display_name
}

output "pipeline_uptime_check_id" {
  description = "ID of the pipeline uptime check"
  value       = google_monitoring_uptime_check_config.pipeline_uptime.id
}

output "pipeline_uptime_check_name" {
  description = "Name of the pipeline uptime check"
  value       = google_monitoring_uptime_check_config.pipeline_uptime.display_name
}

output "frontend_downtime_alert_id" {
  description = "ID of the frontend downtime alert policy"
  value       = google_monitoring_alert_policy.frontend_downtime.id
}

output "backend_downtime_alert_id" {
  description = "ID of the backend downtime alert policy"
  value       = google_monitoring_alert_policy.backend_downtime.id
}

output "high_error_rate_alert_id" {
  description = "ID of the high error rate alert policy"
  value       = google_monitoring_alert_policy.high_error_rate.id
}

output "email_notification_channel_id" {
  description = "ID of the email notification channel (if created)"
  value       = var.notification_email != "" ? google_monitoring_notification_channel.email[0].id : null
}

output "email_notification_channel_name" {
  description = "Name of the email notification channel (if created)"
  value       = var.notification_email != "" ? google_monitoring_notification_channel.email[0].name : null
}

output "dashboard_id" {
  description = "ID of the monitoring dashboard"
  value       = google_monitoring_dashboard.georgian_budget_dashboard.id
}

output "dashboard_url" {
  description = "URL of the monitoring dashboard"
  value       = "https://console.cloud.google.com/monitoring/dashboards/custom/${google_monitoring_dashboard.georgian_budget_dashboard.id}?project=${var.project_id}"
}
