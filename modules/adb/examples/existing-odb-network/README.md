# Existing ODB Network

Use this example for a multi-stack Oracle Autonomous Database@Google Cloud deployment using an existing ODB Network and ODB Subnet. It creates:

* One Autonomous Database attached to an existing ODB Network and subnet

This is the recommended pattern when the networking stack is managed separately — for example, when the ODB Network was created by `modules/odb-networking` in a different Terraform state.

The primary way to pass dependencies is as inline maps injected from Terragrunt `dependency` blocks, `terraform_remote_state` outputs, HCP Terraform workspace outputs, or CI/CD pipeline variables. For standalone stacks without external orchestration, set the `*_dependency_file_path` variables and this example will decode the JSON files before passing dependency maps to the reusable module.

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
3. If using JSON files from an upstream `output_path`, set the `*_dependency_file_path` variables instead of the inline dependency maps.
4. Set the admin password via environment variable to avoid storing credentials in files:

```sh
export TF_VAR_gcp_autonomous_databases_admin_passwords='{"primary":"<your-password>"}'
```

5. Run the standard Terraform commands:

```sh
terraform init
terraform plan -out plan.out
terraform apply plan.out
```

See the module [README](../../README.md) for full attribute documentation.
