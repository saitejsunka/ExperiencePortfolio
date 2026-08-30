# ---------------------------------------------------------
# Global External Application Load Balancer for Frontend
# ---------------------------------------------------------

# 1. Reserve a static Global IP Address for the Load Balancer
resource "google_compute_global_address" "default_frontend" {
  name = "expo-frontend-lb-ip"
}

# 2. Create a Backend Bucket to wrap the GCS Bucket with Cloud CDN
resource "google_compute_backend_bucket" "default_frontend" {
  name        = "expo-frontend-backend-bucket"
  description = "Backend bucket for serving static frontend assets"
  bucket_name = google_storage_bucket.frontend_assets.name
  enable_cdn  = true

}

# 3. Create the URL Map (Routes traffic to the backend bucket)
resource "google_compute_url_map" "default_frontend" {
  name            = "expo-frontend-url-map"
  default_service = google_compute_backend_bucket.default_frontend.id
}

# 4. Create the URL Map for HTTP to HTTPS redirect
resource "google_compute_url_map" "http_redirect" {
  name = "expo-frontend-http-redirect"
  default_url_redirect {
    https_redirect         = true
    redirect_response_code = "MOVED_PERMANENTLY_DEFAULT"
    strip_query            = false
  }
}

# 4b. Create the HTTP Proxy (uses the redirect URL Map)
resource "google_compute_target_http_proxy" "default_frontend" {
  name    = "expo-frontend-http-proxy"
  url_map = google_compute_url_map.http_redirect.id
}

# 5. Create the Global Forwarding Rule (The frontend listener)
resource "google_compute_global_forwarding_rule" "default_frontend" {
  name                  = "expo-frontend-forwarding-rule"
  target                = google_compute_target_http_proxy.default_frontend.id
  port_range            = "80"
  ip_address            = google_compute_global_address.default_frontend.address
  load_balancing_scheme = "EXTERNAL_MANAGED"
}

# ---------------------------------------------------------
# HTTPS Configuration (SSL & Custom Domain)
# ---------------------------------------------------------

# 6. Create Google Managed SSL Certificate for Custom Domain
resource "google_compute_managed_ssl_certificate" "frontend_cert" {
  name = "expo-frontend-ssl-cert"
  managed {
    domains = ["saitejsunka.com"]
  }
  lifecycle {
    create_before_destroy = true
  }
}

# 7. Create the HTTPS Proxy
resource "google_compute_target_https_proxy" "frontend_https" {
  name             = "expo-frontend-https-proxy"
  url_map          = google_compute_url_map.default_frontend.id
  ssl_certificates = [google_compute_managed_ssl_certificate.frontend_cert.id]
}

# 8. Create the Global Forwarding Rule for HTTPS (port 443)
resource "google_compute_global_forwarding_rule" "frontend_https" {
  name                  = "expo-frontend-https-forwarding-rule"
  target                = google_compute_target_https_proxy.frontend_https.id
  port_range            = "443"
  ip_address            = google_compute_global_address.default_frontend.address
  load_balancing_scheme = "EXTERNAL_MANAGED"
}
