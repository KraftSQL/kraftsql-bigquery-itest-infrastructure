# Infrastructure to run the BigQuery connector's integration tests, especially from its CI pipeline.

resource "google_project_service" "bigquery" {
  service            = "bigquery.googleapis.com"
  disable_on_destroy = false
}

resource "google_service_account" "bigquery_connector_itest" {
  account_id   = "bigquery-connector-itest"
  display_name = "SA to run BigQuery connector integration tests"
}

resource "google_project_iam_member" "bigquery_connector_itest" {
  project = google_storage_bucket.tf_state.project
  role    = "roles/bigquery.user"
  member  = google_service_account.bigquery_connector_itest.member
}

resource "google_service_account_iam_member" "bigquery_connector_itest" {
  service_account_id = google_service_account.bigquery_connector_itest.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github_actions.name}/attribute.repository_id/${local.github_repository_ids.bigquery_connector}"
}

output "bigquery_connector_itest_service_account" {
  value = google_service_account.bigquery_connector_itest.email
}
