# DNS Configuration for moneyflow.thelim.dev
# Supports multiple DNS providers via Terraform

# Option 1: Google Cloud DNS (if you use Cloud DNS)
# Note: Using existing zone "thelim-dev" that's already created
data "google_dns_managed_zone" "thelim_dev" {
  count = var.dns_provider == "google_cloud" ? 1 : 0
  
  name = "thelim-dev"
}

resource "google_dns_record_set" "moneyflow_cname" {
  count = var.dns_provider == "google_cloud" ? 1 : 0
  
  name         = "moneyflow.thelim.dev."
  managed_zone = data.google_dns_managed_zone.thelim_dev[0].name
  type         = "A"
  ttl          = 300
  rrdatas      = [google_compute_global_address.load_balancer_ip.address]
}

# Option 2: Cloudflare DNS (most common)
# Note: Cloudflare provider configuration removed to avoid conflicts
# If you need Cloudflare, uncomment and configure the provider below
# provider "cloudflare" {
#   # Configure via environment variables:
#   # CLOUDFLARE_API_TOKEN or CLOUDFLARE_EMAIL + CLOUDFLARE_API_KEY
# }

# Get the existing zone
# data "cloudflare_zone" "thelim_dev" {
#   count = var.dns_provider == "cloudflare" ? 1 : 0
#   name  = "thelim.dev"
# }

# Create the DNS record
# resource "cloudflare_record" "moneyflow" {
#   count = var.dns_provider == "cloudflare" ? 1 : 0
#   
#   zone_id = data.cloudflare_zone.thelim_dev[0].id
#   name    = "moneyflow"
#   value   = google_compute_global_address.load_balancer_ip.address
#   type    = "A"
#   ttl     = 300
#   
#   comment = "Georgian Budget Application Load Balancer"
#   
#   # Enable Cloudflare proxy (optional - provides DDoS protection)
#   proxied = var.cloudflare_proxied
# }

# Option 3: Generic External DNS (for other providers)
# This would require the external-dns controller or manual configuration
