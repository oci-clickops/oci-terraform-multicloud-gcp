# Existing ODB Network

Use this example to create an Oracle Autonomous Database@Google Cloud using an existing ODB Network and ODB Subnet. It creates:

* One Autonomous Database attached to an existing ODB Network and subnet

This is the recommended pattern when the networking stack is managed separately — for example, when the ODB Network was created by the root module in a different Terraform state.

## Prerequisites

Before running it, confirm that:

* The Google Cloud project is enabled for Oracle Database@Google Cloud.
* The target region has the required entitlement and capacity.
* An existing ODB Network and ODB Subnet are available. Their full resource names are required.
* Google provider authentication is configured, for example Application Default Credentials via `gcloud auth application-default login`.
* The caller has permissions to manage Oracle Database@Google Cloud resources.

## Usage

1. Rename `input.auto.tfvars.template` to a name of your choice, following the pattern `<project-name>.auto.tfvars`.
2. Edit the renamed file — replace all `<REPLACE-BY-*>` placeholders with the full resource names of the existing ODB Network and ODB Subnet.
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

See the module [README](../../README.md) for full attribute documentation.
