# Integration-Test Infrastructure For **Kraft**SQL's BigQuery Connector

[OpenTofu](https://opentofu.org/) configuration to manage the required [GCP](https://cloud.google.com/gcp) resources to run the integration-tests of [**Kraft**SQL's BigQuery connector](https://github.com/KraftSQL/kraftsql-bigquery).

## Local development

Prerequisites:
- Make sure you have [OpenTofu](https://opentofu.org/) installed.

You can ues the usual OpeTofu commands:
- `tofu init` to initialize your local workspace, install providers and modules, etc.
- `tofu validate` to validate the OpenTofu configuration
- `tofu plan` to determine the changes to apply
- `tofu apply` to deploy the current configuration
