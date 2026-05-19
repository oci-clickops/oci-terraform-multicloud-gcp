# Vision

Use this example for a complete Oracle Autonomous Database@Google Cloud deployment in ODB Network mode. It creates:

* One Autonomous Database connected to an existing ODB Network and client ODB Subnet

The example uses module defaults for project and region, references existing ODB networking directly, and shows the full set of commonly used properties.

## Prerequisites

Before running it, confirm that:

* The Google Cloud project is enabled for Oracle Database@Google Cloud.
* The target region has the required entitlement and capacity.
* The ODB Network and client ODB Subnet already exist. In production, these are usually supplied by an ExaDB networking stack or equivalent platform networking stack.
* Google provider authentication is configured, for example Application Default Credentials via `gcloud auth application-default login`.
* The caller has permissions to manage Oracle Database@Google Cloud resources and reference the ODB Network and ODB Subnet.

## Usage

1. Rename `input.auto.tfvars.template` to a name of your choice, following the pattern `<project-name>.auto.tfvars`.
2. Edit the renamed file to provide GCP connectivity variables and adjust input variables — replace all placeholder values with actual values.
3. Set the admin password via environment variable to avoid storing credentials in files:

```sh
export TF_VAR_gcp_autonomous_databases_admin_passwords='{"primary":"<your-password>"}'
```

4. Run the standard Terraform commands:

```sh
terraform init
terraform plan -out plan.out
terraform apply plan.out
```

Review the plan carefully before applying. Autonomous Database provisioning can take up to 40 minutes.

See the module [README](../../README.md) for full attribute documentation.
