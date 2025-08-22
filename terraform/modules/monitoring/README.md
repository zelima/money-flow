# Monitoring Module

This Terraform module manages all monitoring and alerting infrastructure for the Georgian Budget application, including uptime checks, alert policies, notification channels, and dashboards.

## Resources

- **Uptime Checks**: Frontend, backend API, and pipeline function monitoring
- **Alert Policies**: Service downtime and high error rate detection
- **Notification Channels**: Email notifications for alerts
- **Dashboards**: Comprehensive monitoring dashboard with key metrics

## Usage

```hcl
module "monitoring" {
  source = "../../modules/monitoring"

  project_id = "your-project-id"
  load_balancer_ip = "1.2.3.4"
  pipeline_function_uri = "https://your-function-uri.cloudfunctions.net"
  notification_email = "alerts@yourcompany.com"

  required_apis = [google_project_service.required_apis]
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| project_id | The GCP project ID | `string` | n/a | yes |
| load_balancer_ip | IP address of the load balancer for uptime checks | `string` | n/a | yes |
| pipeline_function_uri | URI of the pipeline function for uptime checks | `string` | n/a | yes |
| notification_email | Email address for monitoring notifications | `string` | `""` | no |
| required_apis | List of required APIs | `any` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| frontend_uptime_check_name | Name of the frontend uptime check |
| backend_uptime_check_name | Name of the backend uptime check |
| pipeline_uptime_check_name | Name of the pipeline uptime check |
| frontend_downtime_alert_id | ID of the frontend downtime alert policy |
| backend_downtime_alert_id | ID of the backend downtime alert policy |
| high_error_rate_alert_id | ID of the high error rate alert policy |
| dashboard_url | URL of the monitoring dashboard |

## Features

- **Comprehensive Uptime Monitoring**: Checks for frontend, backend API, and data pipeline function
- **Intelligent Alerting**: Configurable alert policies for service downtime and error rates
- **Email Notifications**: Optional email notifications for critical alerts
- **Visual Dashboard**: Pre-configured dashboard with key application metrics
- **Flexible Configuration**: Configurable thresholds and notification preferences

## Monitoring Targets

### Uptime Checks
- **Frontend**: HTTP check on load balancer IP (port 80, path "/")
- **Backend API**: HTTP check on load balancer IP (port 80, path "/api/")
- **Pipeline Function**: HTTPS check on Cloud Function URI (port 443, path "/")

### Alert Policies
- **Frontend Downtime**: Triggers when frontend uptime check fails for 60 seconds
- **Backend Downtime**: Triggers when backend API uptime check fails for 60 seconds
- **High Error Rate**: Triggers when load balancer error rate exceeds 5% for 5 minutes

### Dashboard Widgets
- **Uptime Checks**: Visual representation of all uptime check status
- **Load Balancer Requests**: Request volume and patterns over time

## Alert Configuration

All alerts can be configured to send notifications via email by providing the `notification_email` variable. If no email is provided, alerts will still be created but without notification channels.
