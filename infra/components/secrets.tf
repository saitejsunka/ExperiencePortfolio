# ---------------------------------------------------------
# Google Cloud Secret Manager
# ---------------------------------------------------------
# Stores the secrets that were injected by GitHub Actions 
# so that the backend application can read them later.

# 1. Database Name Secret
resource "google_secret_manager_secret" "db_name" {
  secret_id = "expo-db-name"

  replication {
    auto {}
  }

  depends_on = [google_project_service.secretmanager]
}

resource "google_secret_manager_secret_version" "db_name_version" {
  secret      = google_secret_manager_secret.db_name.id
  secret_data = var.db_name
}

# 2. Database Password Secret
resource "google_secret_manager_secret" "db_password" {
  secret_id = "expo-db-password"

  replication {
    auto {}
  }

  depends_on = [google_project_service.secretmanager]
}

resource "google_secret_manager_secret_version" "db_password_version" {
  secret      = google_secret_manager_secret.db_password.id
  secret_data = var.db_password
}

# 3. Database Primary Private IP Secret
# Dynamically stores the auto-generated private IP so the application can fetch it at runtime
resource "google_secret_manager_secret" "db_ip" {
  secret_id = "expo-db-ip"

  replication {
    auto {}
  }

  depends_on = [google_project_service.secretmanager]
}

resource "google_secret_manager_secret_version" "db_ip_version" {
  secret      = google_secret_manager_secret.db_ip.id
  secret_data = google_sql_database_instance.primary.private_ip_address
}
