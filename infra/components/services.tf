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

# Enables the Secret Manager API (Required for storing DB credentials securely)
resource "google_project_service" "secretmanager" {
  service = "secretmanager.googleapis.com"
  
  disable_on_destroy = false
}

# Enables the Cloud SQL Admin API (Required to create databases)
resource "google_project_service" "sqladmin" {
  service = "sqladmin.googleapis.com"
  
  disable_on_destroy = false
}

# Enables Cloud Logging API
resource "google_project_service" "logging" {
  service = "logging.googleapis.com"
  
  disable_on_destroy = false
}

# Enables Cloud Monitoring API
resource "google_project_service" "monitoring" {
  service = "monitoring.googleapis.com"
  
  disable_on_destroy = false
}

# Enables IAM API (Required for creating service accounts)
resource "google_project_service" "iam" {
  service = "iam.googleapis.com"
  
  disable_on_destroy = false
}
