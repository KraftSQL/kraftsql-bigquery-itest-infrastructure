terraform {
  backend "gcs" {
    bucket = "kraftsql-bigquery-itest-infrastructure-tfstate"
  }
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "8.12.0"
    }
  }
}

# The configuration manages the bucket for the state itself, after it was manually created and imported:
resource "google_storage_bucket" "tf_state" {
  name     = "kraftsql-bigquery-itest-infrastructure-tfstate"
  location = "europe-west4"
}
