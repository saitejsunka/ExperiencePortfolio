# ---------------------------------------------------------
# Static Website Storage Bucket
# ---------------------------------------------------------

resource "google_storage_bucket" "frontend_assets" {
  # Naming convention: project_id + standard suffix
  name          = "experienceportfolio-frontend-assets"
  location      = "US" # Multi-region for better availability via CDN
  force_destroy = true # Only for dev; in production remove this

  uniform_bucket_level_access = true

  website {
    main_page_suffix = "index.html"
    not_found_page   = "index.html" # Helpful for SPAs or generic 404s
  }

  cors {
    origin          = ["*"]
    method          = ["GET", "HEAD", "OPTIONS"]
    response_header = ["*"]
    max_age_seconds = 3600
  }
}

# Make the bucket publicly readable
resource "google_storage_bucket_iam_member" "public_read" {
  bucket = google_storage_bucket.frontend_assets.name
  role   = "roles/storage.objectViewer"
  member = "allUsers"
}
