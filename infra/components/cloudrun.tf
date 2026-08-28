# ---------------------------------------------------------
# Cloud Run Configuration
# ---------------------------------------------------------
# We need to enable the Cloud Run API first
resource "google_project_service" "run" {
  service            = "run.googleapis.com"
  disable_on_destroy = false
}

# Define the Cloud Run Service
resource "google_cloud_run_v2_service" "expo_backend" {
  name     = "expo-backend"
  location = "us-west1"
  ingress  = "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER" # Lock down ingress to only accept traffic from our Global Load Balancer

  template {
    # Link to the service account created in iam.tf
    service_account = google_service_account.expo_backend_sa.email

    containers {
      # Use Google's public hello image for the VERY FIRST deployment so Terraform doesn't crash.
      # The CI/CD pipeline will immediately overwrite this with your real Go backend image.
      image = "us-docker.pkg.dev/cloudrun/container/hello"
      
      ports {
        name           = "h2c" # Required for gRPC
        container_port = 5080 # Needs to match what we listen to in Go
      }
      
      resources {
        limits = {
          cpu    = "1000m"
          memory = "512Mi"
        }
      }
    }

    # Direct VPC Egress - connect straight to the DB subnet
    vpc_access {
      network_interfaces {
        network    = google_compute_network.expo_vpc.id
        subnetwork = google_compute_subnetwork.expo_subnet_us_west1.id
      }
      # Send ALL outbound traffic through the VPC. Private IPs hit the DB, public IPs hit the Cloud NAT to reach the internet.
      egress = "ALL_TRAFFIC"
    }
  }

  depends_on = [
    google_project_service.run,
    google_artifact_registry_repository.expo_backend_repo,
    google_service_account.expo_backend_sa
  ]
  
  # Ignore changes to the image because CI/CD will update this outside of Terraform
  lifecycle {
    ignore_changes = [
      template[0].containers[0].image
    ]
  }
}
