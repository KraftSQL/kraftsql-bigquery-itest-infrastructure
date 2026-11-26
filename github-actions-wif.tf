# Workload Identity Federation for GitHub Actions, shared by the CI pipelines of all the repositories below.
locals {
  github_repository_ids = {
    itest_infrastructure = "1470619814" # KraftSQL/kraftsql-bigquery-itest-infrastructure
    bigquery_connector   = "1022627069" # KraftSQL/kraftsql-bigquery
  }
}

resource "google_project_service" "github_actions" {
  for_each = toset([
    "cloudresourcemanager.googleapis.com",
    "iam.googleapis.com",
    "iamcredentials.googleapis.com",
    "sts.googleapis.com",
  ])
  service            = each.value
  disable_on_destroy = false
}

resource "google_iam_workload_identity_pool" "github_actions" {
  workload_identity_pool_id = "github-actions"
  display_name              = "GitHub Actions"

  depends_on = [google_project_service.github_actions]
}

resource "google_iam_workload_identity_pool_provider" "github_actions" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.github_actions.workload_identity_pool_id
  workload_identity_pool_provider_id = "github-actions-oidc"
  display_name                       = "GitHub Actions OIDC"

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
  attribute_mapping = {
    "google.subject"              = "assertion.sub"
    "attribute.repository_id"     = "assertion.repository_id"
    "attribute.repository_id_ref" = "assertion.repository_id + '@' + assertion.ref"
  }
  attribute_condition = "assertion.repository_id in ${jsonencode(values(local.github_repository_ids))}"
}

output "github_actions_workload_identity_provider" {
  value = google_iam_workload_identity_pool_provider.github_actions.name
}
