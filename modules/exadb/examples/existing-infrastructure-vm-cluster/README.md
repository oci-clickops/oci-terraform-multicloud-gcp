# Existing Infrastructure VM Cluster

Use this example when the Cloud Exadata Infrastructure, ODB network, client ODB subnet, and backup ODB subnet already exist, and Terraform should create only a Cloud VM Cluster.

The example passes existing resource names directly to the module and leaves the ODB network, ODB subnet, and Cloud Exadata Infrastructure input maps empty.

## Prerequisites

Before running it, confirm that:

* The Google Cloud project is enabled for Oracle Database@Google Cloud.
* The existing Cloud Exadata Infrastructure is in the target region and GCP Oracle zone.
* The existing ODB network has a client ODB subnet and a backup ODB subnet.
* Google provider authentication is configured (e.g., Application Default Credentials via `gcloud auth application-default login`).
* The caller has permissions to create Oracle Database@Google Cloud VM clusters and read the referenced resources.

## Usage

1. Rename `input.auto.tfvars.template` to a name of your choice, following the pattern `<project-name>.auto.tfvars`.
2. Edit the renamed file to provide GCP connectivity variables and adjust input variables — replace all `<REPLACE-BY-*>` placeholders with the full resource names of the existing infrastructure.
3. Obtain DB server OCIDs from the existing Cloud Exadata Infrastructure:
   ```sh
   gcloud oracle-database cloud-exadata-infrastructures db-servers list \
     --location=<LOCATION> \
     --cloud-exadata-infrastructure=<EXADATA_INFRASTRUCTURE_NAME>
   ```
   Copy the `ocid` values from the output (one per VM node for distributed placement).
4. Set `db_server_ocids` to one validated DB server OCID per VM for controlled placement.

The VM Cluster GCP Oracle zone is derived from the existing Cloud Exadata Infrastructure by the service, so this example does not set it as an input.

4. Run the standard Terraform commands:

```sh
terraform init
terraform plan -out plan.out
terraform apply plan.out
```

The plan should create only `google_oracle_database_cloud_vm_cluster.these["primary"]`. Review the plan carefully before applying.

See the module [README](../../README.md) for full attribute documentation.
