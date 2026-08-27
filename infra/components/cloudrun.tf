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
  ingress  = "INGRESS_TRAFFIC_ALL" # Adjust based on frontend location later

  template {
    # Link to the service account created in iam.tf
    service_account = google_service_account.expo_backend_sa.email

    containers {
      # Use a placeholder image or the latest pushed image
      image = "us-west1-docker.pkg.dev/experienceportfolio/expo-backend-repo/expo-backend:latest"
      
      ports {
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
      # Send ALL traffic through the VPC so it reaches the private IP DB safely
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
