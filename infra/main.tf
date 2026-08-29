# ExperiencePortfolio Infrastructure Definitions

terraform {
  backend "gcs" {
    bucket = "experienceportfolio-tf-state"
    prefix = "terraform/state"
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

# We use a module block to tell Terraform to load and evaluate 
# all the .tf files located in the 'components' folder (like vpc.tf).
module "infrastructure_components" {
  source = "./components"

  # Pass variables into the components module
  db_name     = var.db_name
  db_password = var.db_password
  db_user     = var.db_user
}


