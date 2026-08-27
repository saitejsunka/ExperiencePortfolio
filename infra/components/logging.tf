# ---------------------------------------------------------
# Cloud Logging Configuration
# ---------------------------------------------------------

# Configure the default log bucket to retain logs for exactly 15 days
resource "google_logging_project_bucket_config" "default_log_bucket" {
  project        = "experienceportfolio"
  location       = "global"
  bucket_id      = "_Default"
  
  # Set retention to 15 days
  retention_days = 15
}
