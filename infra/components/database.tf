# ---------------------------------------------------------
# Database Layer (Cloud SQL - CQRS Pattern)
# ---------------------------------------------------------

# 1. Primary Write Database
resource "google_sql_database_instance" "primary" {
  name             = "expo-primary-write"
  database_version = "POSTGRES_15"
  region           = "us-west1"

  # FAANG Best Practice: Deletion protection should be TRUE for production.
  # Set to false here to allow easier teardown during learning/portfolio phase.
  deletion_protection = false 

  settings {
    tier = "db-f1-micro"

    ip_configuration {
      ipv4_enabled    = false # No public internet access
      private_network = google_compute_network.expo_vpc.id
    }
  }

  # Ensure the VPC peering is completely set up before trying to attach the DB
  depends_on = [google_service_networking_connection.default]
}

# 2. Read Replica Database
resource "google_sql_database_instance" "replica" {
  name                 = "expo-replica-read"
  master_instance_name = google_sql_database_instance.primary.name
  database_version     = "POSTGRES_15"
  region               = "us-west1"

  deletion_protection = false

  settings {
    tier = "db-f1-micro"

    ip_configuration {
      ipv4_enabled    = false
      private_network = google_compute_network.expo_vpc.id
    }
  }

  replica_configuration {
    failover_target = false
  }

  depends_on = [google_service_networking_connection.default]
}

# 3. Logical Database inside the instance
resource "google_sql_database" "database" {
  name     = var.db_name
  instance = google_sql_database_instance.primary.name
}

# 4. Database User (Basic Setup)
# Password securely injected from GitHub Actions Secrets
resource "google_sql_user" "users" {
  name     = "expo_admin"
  instance = google_sql_database_instance.primary.name
  password = var.db_password
}
