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

# 4. Create the HTTP Proxy
resource "google_compute_target_http_proxy" "default_frontend" {
  name    = "expo-frontend-http-proxy"
  url_map = google_compute_url_map.default_frontend.id
}

# 5. Create the Global Forwarding Rule (The frontend listener)
resource "google_compute_global_forwarding_rule" "default_frontend" {
  name                  = "expo-frontend-forwarding-rule"
  target                = google_compute_target_http_proxy.default_frontend.id
  port_range            = "80"
  ip_address            = google_compute_global_address.default_frontend.address
  load_balancing_scheme = "EXTERNAL_MANAGED"
}
