# ---------------------------------------------------------
# Subnetworks
# ---------------------------------------------------------
# ARCHITECTURE NOTE: Subnet Scaling & Design
# 1. Regionality: Subnets are strictly regional. Expanding to a new region requires a new subnet.
# 2. IP Sizing: 10.0.1.0/24 provides 256 IPs (252 usable). Clean start for a primary subnet.
# 3. Future Scaling (Security Tiering): As AximBlue grows, create multiple subnets 
#    PER region based on purpose (e.g., 10.0.1.0/24 for Web, 10.0.2.0/24 for API Backend) 
#    to enforce strict firewall boundaries between application layers.
# ---------------------------------------------------------

resource "google_compute_subnetwork" "expo_subnet_us_west1" {
  name          = "expo-subnet-us-west1"
  network       = google_compute_network.expo_vpc.id
  region        = "us-west1"
  ip_cidr_range = "10.0.1.0/24"

  # Best Practice: 
  # Allows instances in this subnet that do NOT have public IP addresses 
  # to securely access Google APIs and services (like Cloud Storage or Cloud SQL).
  private_ip_google_access = true
}
