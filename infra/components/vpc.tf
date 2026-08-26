# ---------------------------------------------------------
# 1. VPC Network
# ---------------------------------------------------------
# A VPC is a global, logically isolated network. By default, 
# it blocks all inbound traffic from the public internet.
resource "google_compute_network" "expo_vpc" {
  name                    = "expo-vpc"
  auto_create_subnetworks = false
  routing_mode            = "GLOBAL"

  # Ensure Compute API is enabled before trying to create a VPC
  depends_on = [google_project_service.compute]
}

# ---------------------------------------------------------
# Private Services Access (For Private Cloud SQL, Redis, etc.)
# ---------------------------------------------------------

# 2. Allocate a private IP range for Google Managed Services
# We are carving out a /16 block of IPs and reserving it. 
# We are not using these for our VMs; we are giving this block
# to Google so they can host managed services inside our network boundary.
resource "google_compute_global_address" "private_ip_alloc" {
  name          = "expo-private-ip-alloc"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.expo_vpc.id
}

# 3. Create the private connection linking our VPC to Google's Service VPC
# Google-managed services (like Cloud SQL) live in Google's VPC.
# This creates a private tunnel (VPC Peering) between our VPC and theirs,
# allowing our VMs to talk to the database without hitting the public internet.
resource "google_service_networking_connection" "default" {
  network                 = google_compute_network.expo_vpc.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_alloc.name]

  # Ensure Service Networking API is enabled before creating peering
  depends_on = [google_project_service.servicenetworking]
}

# ARCHITECTURE NOTE: IaaS vs PaaS
# - IaaS (Compute Engine): VMs you manage. They live in YOUR subnets.
# - PaaS (Cloud SQL): Fully managed by Google. To guarantee SLAs (uptime/backups),
#   Google spins the DB up in a hidden, highly secure project THEY own.
# EXAMPLE:
# Your backend VM (10.2.0.5) lives in your subnet. Google spins up Cloud SQL 
# in their hidden project, and assigns it an IP from the /16 block we reserved 
# above (e.g., 10.1.0.10). 
# This `google_service_networking_connection` acts as the secure bridge (VPC Peering)
# between the two isolated networks. Your VM talks to 10.1.0.10 entirely privately.
