# Frontend Infrastructure Definitions
# This state is completely separated from the backend state to ensure deployments
# to the frontend don't get blocked by or interfere with backend changes.

terraform {
  backend "gcs" {
    bucket = "experienceportfolio-tf-state"
    prefix = "terraform/state/frontend"
  }
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = "experienceportfolio"
  region  = "us-west1"
}
