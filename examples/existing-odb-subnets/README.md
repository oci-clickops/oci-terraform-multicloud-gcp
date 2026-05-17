# Existing ODB Subnets

Use this example when the ODB network and the client and backup ODB subnets already exist, and Terraform should create a new Cloud Exadata Infrastructure and a new Cloud VM Cluster on top of them.

The example passes existing ODB network and ODB subnet resource names directly to the module and leaves the ODB network and ODB subnet input maps empty.

## Prerequisites

Before running it, confirm that:

* The Google Cloud project is enabled for Oracle Database@Google Cloud.
* The target region has the required entitlement and capacity.
* The ODB network already exists, with a client ODB subnet and a backup ODB subnet provisioned under it.
* Google provider authentication is configured (e.g., Application Default Credentials via `gcloud auth application-default login`).
* The caller has permissions to create Oracle Database@Google Cloud Exadata infrastructures and VM clusters and to reference the existing ODB network and subnets.

## Usage

1. Rename `input.auto.tfvars.template` to a name of your choice, following the pattern `<project-name>.auto.tfvars`.
2. Edit the renamed file to provide GCP connectivity variables and adjust input variables — replace all `<REPLACE-BY-*>` placeholders with the full resource names of the existing ODB network and ODB subnets.
3. Run the standard Terraform commands:

```sh
terraform init
terraform plan -out plan.out
terraform apply plan.out
```

The plan should create `google_oracle_database_cloud_exadata_infrastructure.these["primary"]` and `google_oracle_database_cloud_vm_cluster.these["primary"]` and nothing else. Review the plan carefully before applying, as Cloud Exadata Infrastructure and VM Cluster operations can take a long time and may involve service-side capacity checks.

See the module [README](../../README.md) for full attribute documentation.
