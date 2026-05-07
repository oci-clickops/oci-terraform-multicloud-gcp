# Existing Infrastructure VM Cluster

Use this example when the Cloud Exadata Infrastructure, ODB network, client ODB subnet, and backup ODB subnet already exist, and Terraform should create only a Cloud VM Cluster.

The example passes existing resource names directly to the module and leaves the ODB network, ODB subnet, and Cloud Exadata Infrastructure input maps empty.

## Prerequisites

Before running it, confirm that:

* The Google Cloud project is enabled for Oracle Database@Google Cloud.
* The existing Cloud Exadata Infrastructure is in the target region and GCP Oracle zone.
* The existing ODB network has a client ODB subnet and a backup ODB subnet.
* Google provider authentication is configured with Application Default Credentials.
* The caller has permissions to create Oracle Database@Google Cloud VM clusters and read the referenced resources.

## Usage

```sh
gcloud auth application-default login
gcloud auth application-default set-quota-project <PROJECT_ID>
```

```sh
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` with your project, region, existing resource names, license type, CPU core count, Grid Infrastructure version, hostname prefix, and SSH public key.

The `terraform.tfvars.example` file uses explicit placeholder `db_server_ocids` so local plans do not need to read DB servers from a real Google Cloud project. Replace them with one validated DB server OCID per VM. Set `db_server_ocids = null` only when the target project, API, and existing Cloud Exadata Infrastructure are real and Terraform may discover `AVAILABLE` DB servers.

The VM Cluster GCP Oracle zone is derived from the existing Cloud Exadata Infrastructure by the service, so this example does not set it as an input.

```sh
terraform init -backend=false
terraform validate
terraform plan
```

The plan should create only `google_oracle_database_cloud_vm_cluster.these["primary"]`. Review the plan carefully and stop there unless you are intentionally executing a real deployment.
