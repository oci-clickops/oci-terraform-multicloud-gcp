# Basic ODB Networking

Use this example to create only the Oracle Database@Google Cloud networking layer on top of an existing Google Cloud VPC:

* One ODB network
* One client ODB subnet
* One backup ODB subnet

This example does not create Cloud Exadata Infrastructure or Cloud VM Clusters. Use it when the platform or landing zone owns the VPC and you want to validate Oracle Database@Google Cloud networking without consuming Exadata capacity.

It is also useful as a separate Terraform state boundary. One state can own the ODB Network and ODB Subnets, keep `enable_output = true`, set `output_path`, and publish dependency JSON files for a later Exadata/VM Cluster or Autonomous Database state. This mirrors the common split between platform networking and database infrastructure. See `../../../exadb/examples/cluster` and `../../../adb/examples/existing-odb-network` for consumer-side examples of this pattern.

## Prerequisites

Before running it, confirm that:

* The Google Cloud project is enabled for Oracle Database@Google Cloud.
* The target VPC network already exists.
* Google provider authentication is configured (e.g., Application Default Credentials via `gcloud auth application-default login`).
* The caller has permissions to manage Oracle Database@Google Cloud ODB networks and ODB subnets and to reference the VPC network.

## Usage

1. Rename `input.auto.tfvars.template` to a name of your choice, following the pattern `<project-name>.auto.tfvars`.
2. Edit the renamed file to provide GCP connectivity variables and adjust input variables — replace all `<your *>` placeholders with actual values.
3. Run the standard Terraform commands:

```sh
terraform init
terraform plan -out plan.out
terraform apply plan.out
```

Review the plan carefully before applying.

When `enable_output = true` and `output_path` is set, apply writes `gcp_odb_networks_output.json` and `gcp_odb_subnets_output.json` to that directory. A consumer stack such as `../../../exadb/examples/cluster` can receive the resource IDs as inline maps via Terragrunt, `terraform_remote_state`, or CI/CD. For standalone deployments, set the consumer example-level `*_dependency_file_path` variables so the wrapper decodes the JSON and passes maps to the reusable module. If `enable_output = false`, module outputs are `null` and JSON handoff files are not produced.

See the module [README](../../README.md) for full attribute documentation.
