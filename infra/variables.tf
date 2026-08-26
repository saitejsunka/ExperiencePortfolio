# ---------------------------------------------------------
# Root Variables
# ---------------------------------------------------------
variable "project_id" {
  description = "The ID of the GCP Project"
  type        = string
  default     = "experienceportfolio"
}

variable "region" {
  description = "The primary region for resources"
  type        = string
  default     = "us-west1"
}

# --- Database Credentials (Injected via CI/CD) ---
variable "db_name" {
  description = "The name of the primary logical database"
  type        = string
}

variable "db_password" {
  description = "The password for the expo_admin database user"
  type        = string
  sensitive   = true
}
