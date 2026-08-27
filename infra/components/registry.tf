# ---------------------------------------------------------
# Artifact Registry for Docker Images
# ---------------------------------------------------------
# We need to enable the Artifact Registry API first
resource "google_project_service" "artifactregistry" {
  service            = "artifactregistry.googleapis.com"
  disable_on_destroy = false
}

# Create a Docker repository in us-west1 to host our backend images
resource "google_artifact_registry_repository" "expo_backend_repo" {
  location      = "us-west1"
  repository_id = "expo-backend-repo"
  description   = "Docker repository for the Experience Portfolio Backend"
  format        = "DOCKER"

  depends_on = [google_project_service.artifactregistry]
}
