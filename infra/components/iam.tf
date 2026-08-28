# ---------------------------------------------------------
# IAM and Service Accounts
# ---------------------------------------------------------

# Create the Service Account for Cloud Run
resource "google_service_account" "expo_backend_sa" {
  account_id   = "expo-backend-sa"
  display_name = "Expo Backend Service Account"
  description  = "Identity for the Cloud Run Expo Backend Service"

  depends_on = [google_project_service.iam]
}

# Grant Cloud SQL Client role so it can connect to the database via mTLS
resource "google_project_iam_member" "sql_client" {
  project = "experienceportfolio"
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${google_service_account.expo_backend_sa.email}"
}

# Grant Secret Accessor role so it can fetch passwords and IP addresses
resource "google_project_iam_member" "secret_accessor" {
  project = "experienceportfolio"
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${google_service_account.expo_backend_sa.email}"
}

# Grant Logs Writer role for Telemetry
resource "google_project_iam_member" "log_writer" {
  project = "experienceportfolio"
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.expo_backend_sa.email}"
}

# Grant Metric Writer role for Telemetry
resource "google_project_iam_member" "metric_writer" {
  project = "experienceportfolio"
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${google_service_account.expo_backend_sa.email}"
}

# Allow public invocation of the Cloud Run service (Ingress will be restricted to the Load Balancer at the network level)
resource "google_cloud_run_service_iam_member" "public_invoker" {
  project  = "experienceportfolio"
  location = google_cloud_run_v2_service.expo_backend.location
  service  = google_cloud_run_v2_service.expo_backend.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}
