# ---------------------------------------------------------
# Cloud Router and Cloud NAT for Egress
# ---------------------------------------------------------

# 1. Cloud Router
# Required to house the Cloud NAT gateway. It runs in the same region and network.
resource "google_compute_router" "router" {
  name    = "expo-router"
  region  = "us-west1"
  network = google_compute_network.expo_vpc.id
}

# 2. Cloud NAT
# Allows resources in our private VPC (like Cloud Run with Direct VPC Egress)
# to access the public internet securely.
resource "google_compute_router_nat" "nat" {
  name                               = "expo-nat"
  router                             = google_compute_router.router.name
  region                             = google_compute_router.router.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}
