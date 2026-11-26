# CI pipeline of this repository itself.
locals {
  github_repository_id = local.github_repository_ids.itest_infrastructure
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

output "github_actions_plan_service_account" {
  value = google_service_account.github_actions_plan.email
}

output "github_actions_apply_service_account" {
  value = google_service_account.github_actions_apply.email
}
