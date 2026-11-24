locals {
  github_repository_id = "1470619814" # KraftSQL/kraftsql-bigquery-itest-infrastructure; immutable, unlike the name
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
  attribute_condition = "assertion.repository_id == '${local.github_repository_id}'"
}

# Read-only service account for `tofu plan`, usable from any branch.
resource "google_service_account" "github_actions_plan" {
  account_id   = "github-actions-plan"
  display_name = "GitHub Actions: tofu plan"
}

resource "google_project_iam_member" "github_actions_plan" {
  for_each = toset([
    "roles/viewer",
    "roles/iam.securityReviewer", # read IAM policies
  ])
  project = google_storage_bucket.tf_state.project
  role    = each.value
  member  = google_service_account.github_actions_plan.member
}

# Read-only access to the state; hence, the plan has to be made with `-lock=false`.
resource "google_storage_bucket_iam_member" "github_actions_plan_tf_state" {
  bucket = google_storage_bucket.tf_state.name
  role   = "roles/storage.objectViewer"
  member = google_service_account.github_actions_plan.member
}

resource "google_service_account_iam_member" "github_actions_plan" {
  service_account_id = google_service_account.github_actions_plan.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github_actions.name}/attribute.repository_id/${local.github_repository_id}"
}

# Privileged service account for `tofu apply`, usable only from the default branch.
resource "google_service_account" "github_actions_apply" {
  account_id   = "github-actions-apply"
  display_name = "GitHub Actions: tofu apply"
}

# Owner, because the configuration manages IAM, including this account's own permissions.
resource "google_project_iam_member" "github_actions_apply" {
  project = google_storage_bucket.tf_state.project
  role    = "roles/owner"
  member  = google_service_account.github_actions_apply.member
}

resource "google_service_account_iam_member" "github_actions_apply" {
  service_account_id = google_service_account.github_actions_apply.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github_actions.name}/attribute.repository_id_ref/${local.github_repository_id}@refs/heads/main"
}

output "github_actions_workload_identity_provider" {
  value = google_iam_workload_identity_pool_provider.github_actions.name
}

output "github_actions_plan_service_account" {
  value = google_service_account.github_actions_plan.email
}

output "github_actions_apply_service_account" {
  value = google_service_account.github_actions_apply.email
}
