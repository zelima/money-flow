# Monitoring Module for Georgian Budget Application
# Includes uptime checks, alert policies, notification channels, and dashboards

# Uptime Check for Frontend
resource "google_monitoring_uptime_check_config" "frontend_uptime" {
  display_name = "Georgian Budget Frontend Uptime Check"

  http_check {
    port         = 80
    path         = "/"
    use_ssl      = false
  }

  monitored_resource {
    type = "uptime_url"
    labels = {
      project_id = var.project_id
      host       = var.load_balancer_ip
    }
  }

  timeout = "10s"

  depends_on = [var.required_apis]
}

# Uptime Check for Backend API
resource "google_monitoring_uptime_check_config" "backend_uptime" {
  display_name = "Georgian Budget Backend API Uptime Check"

  http_check {
    port         = 80
    path         = "/api/"
    use_ssl      = false
  }

  monitored_resource {
    type = "uptime_url"
    labels = {
      project_id = var.project_id
      host       = var.load_balancer_ip
    }
  }

  timeout = "10s"

  depends_on = [var.required_apis]
}

# Uptime Check for Data Pipeline Function
resource "google_monitoring_uptime_check_config" "pipeline_uptime" {
  display_name = "Georgian Budget Pipeline Function Uptime Check"

  http_check {
    port         = 443
    path         = "/"
    use_ssl      = true
  }

  monitored_resource {
    type = "uptime_url"
    labels = {
      project_id = var.project_id
      host       = replace(var.pipeline_function_uri, "https://", "")
    }
  }

  timeout = "30s"

  depends_on = [var.required_apis]
}

# Alerting Policy for Frontend Downtime
resource "google_monitoring_alert_policy" "frontend_downtime" {
  display_name = "Frontend Service Down"
  combiner     = "OR"

  conditions {
    display_name = "Frontend uptime check failed"

    condition_threshold {
      filter = "metric.type=\"monitoring.googleapis.com/uptime_check/check_passed\" AND resource.type=\"uptime_url\""

      comparison      = "COMPARISON_LT"
      threshold_value = 1.0
      duration        = "60s"

      aggregations {
        alignment_period   = "60s"
      }
    }
  }

  notification_channels = var.notification_email != "" ? [google_monitoring_notification_channel.email[0].name] : []

  depends_on = [var.required_apis]
}

# Alerting Policy for Backend API Downtime
resource "google_monitoring_alert_policy" "backend_downtime" {
  display_name = "Backend API Service Down"
  combiner     = "OR"

  conditions {
    display_name = "Backend API uptime check failed"

    condition_threshold {
      filter = "metric.type=\"monitoring.googleapis.com/uptime_check/check_passed\" AND resource.type=\"uptime_url\""

      comparison      = "COMPARISON_LT"
      threshold_value = 1.0
      duration        = "60s"

      aggregations {
        alignment_period   = "60s"
      }
    }
  }

  notification_channels = var.notification_email != "" ? [google_monitoring_notification_channel.email[0].name] : []

  depends_on = [var.required_apis]
}

# Alerting Policy for High Error Rate
resource "google_monitoring_alert_policy" "high_error_rate" {
  display_name = "High Error Rate on Load Balancer"
  combiner     = "OR"

  conditions {
    display_name = "Error rate > 5%"

    condition_threshold {
      filter = "metric.type=\"loadbalancing.googleapis.com/https/request_count\" AND resource.type=\"https_lb_rule\""

      comparison      = "COMPARISON_GT"
      threshold_value = 0.05
      duration        = "300s"

      aggregations {
        alignment_period   = "300s"
        per_series_aligner = "ALIGN_RATE"
        cross_series_reducer = "REDUCE_MEAN"
      }
    }
  }

  notification_channels = var.notification_email != "" ? [google_monitoring_notification_channel.email[0].name] : []

  depends_on = [var.required_apis]
}

# Email Notification Channel (only if email is provided)
resource "google_monitoring_notification_channel" "email" {
  count        = var.notification_email != "" ? 1 : 0
  display_name = "Email Notifications"
  type         = "email"

  labels = {
    email_address = var.notification_email
  }

  depends_on = [var.required_apis]
}

# Dashboard for Georgian Budget Application
resource "google_monitoring_dashboard" "georgian_budget_dashboard" {
  dashboard_json = jsonencode({
    displayName = "Georgian Budget Application Dashboard"
    gridLayout = {
      widgets = [
        {
          title = "Uptime Checks"
          xyChart = {
            dataSets = [{
              timeSeriesQuery = {
                timeSeriesFilter = {
                  filter = "metric.type=\"monitoring.googleapis.com/uptime_check/check_passed\""
                }
              }
            }]
          }
        },
        {
          title = "Load Balancer Requests"
          xyChart = {
            dataSets = [{
              timeSeriesQuery = {
                timeSeriesFilter = {
                  filter = "metric.type=\"loadbalancing.googleapis.com/https/request_count\""
                }
              }
            }]
          }
        }
      ]
    }
  })

  depends_on = [var.required_apis]
}
