# ---------------------------------------------------------
# API Services
# ---------------------------------------------------------

# Enables the Compute Engine API (Required for VPCs, Subnets, VMs)
resource "google_project_service" "compute" {
  service = "compute.googleapis.com"
  
  # Prevents Terraform from disabling the API if the resource is removed
  disable_on_destroy = false
}

# Enables the Service Networking API (Required for Private Services Access / VPC Peering)
resource "google_project_service" "servicenetworking" {
  service = "servicenetworking.googleapis.com"
  
  # Prevents Terraform from disabling the API if the resource is removed
  disable_on_destroy = false
}
