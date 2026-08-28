# ---------------------------------------------------------
# Global External Application Load Balancer
# ---------------------------------------------------------

# 1. Reserve a static Global IP Address for the Load Balancer
resource "google_compute_global_address" "default" {
  name = "expo-lb-ip"
}

# 2. Create a Serverless Network Endpoint Group (NEG) for Cloud Run
resource "google_compute_region_network_endpoint_group" "serverless_neg" {
  name                  = "expo-serverless-neg"
  network_endpoint_type = "SERVERLESS"
  region                = "us-west1"
  
  cloud_run {
    service = google_cloud_run_v2_service.expo_backend.name
  }
}

# 3. Create the Backend Service
resource "google_compute_backend_service" "default" {
  name                  = "expo-backend-service"
  protocol              = "HTTP2" # Important for gRPC
  port_name             = "http"
  load_balancing_scheme = "EXTERNAL_MANAGED"

  backend {
    group = google_compute_region_network_endpoint_group.serverless_neg.id
  }
}

# 4. Create the URL Map (Routes traffic to the backend service)
resource "google_compute_url_map" "default" {
  name            = "expo-url-map"
  default_service = google_compute_backend_service.default.id
}

# 5. Create the HTTP Proxy (NOTE: For production gRPC, this MUST be upgraded to an HTTPS proxy with an SSL Cert and Domain)
resource "google_compute_target_http_proxy" "default" {
  name    = "expo-http-proxy"
  url_map = google_compute_url_map.default.id
}

# 6. Create the Global Forwarding Rule (The frontend listener)
resource "google_compute_global_forwarding_rule" "default" {
  name                  = "expo-forwarding-rule"
  target                = google_compute_target_http_proxy.default.id
  port_range            = "80"
  ip_address            = google_compute_global_address.default.address
  load_balancing_scheme = "EXTERNAL_MANAGED"
}
