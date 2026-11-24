# Integration-Test Infrastructure For **Kraft**SQL's BigQuery Connector

[OpenTofu](https://opentofu.org/) configuration to manage the required [GCP](https://cloud.google.com/gcp) resources to run the integration-tests of [**Kraft**SQL's BigQuery connector](https://github.com/KraftSQL/kraftsql-bigquery).

This configuration deploys to the GCP project `kraftsql-bigquery`.
It is used to run the integration-tests in the BigQuery connector's CI pipeline, and can also be used by the maintainers who have access.

The project also contains the GCS bucket for the OpenTofu state.

## Local development

Prerequisites:
- Make sure you have [OpenTofu](https://opentofu.org/) installed.
- Make sure you are authenticated at the GCP and have write-access to the GCS bucket `kraftsql-bigquery-itest-infrastructure-tfstate` for the OpenTofu state.
  (Or configure a different backend, when you deploy your own infrastructure somewhere.)

You can ues the usual OpeTofu commands:
- `tofu init` to initialize your local workspace, install providers and modules, etc.
- `tofu validate` to validate the OpenTofu configuration
- `tofu plan` to determine the changes to apply
- `tofu apply` to deploy the current configuration
