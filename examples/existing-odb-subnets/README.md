# Existing ODB Subnets

Use this example when the ODB network and the client and backup ODB subnets already exist, and Terraform should create a new Cloud Exadata Infrastructure and a new Cloud VM Cluster on top of them.

The example passes existing ODB network and ODB subnet resource names directly to the module and leaves the ODB network and ODB subnet input maps empty.

## Prerequisites

Before running it, confirm that:

* The Google Cloud project is enabled for Oracle Database@Google Cloud.
* The target region has the required entitlement and capacity.
* The ODB network already exists, with a client ODB subnet and a backup ODB subnet provisioned under it.
* Google provider authentication is configured with Application Default Credentials.
* The caller has permissions to create Oracle Database@Google Cloud Exadata infrastructures and VM clusters and to reference the existing ODB network and subnets.

## Usage

```sh
gcloud auth application-default login
gcloud auth application-default set-quota-project <PROJECT_ID>
```

```sh
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` with your project, region, GCP Oracle zone, the existing ODB network and ODB subnet resource names, the Exadata shape and capacity, the customer contact email, the maintenance window, the license type, the CPU core count, the Grid Infrastructure version, the hostname prefix, and the SSH public key.

```sh
terraform init -backend=false
terraform validate
terraform plan
```

The plan should create `google_oracle_database_cloud_exadata_infrastructure.these["primary"]` and `google_oracle_database_cloud_vm_cluster.these["primary"]` and nothing else. Review the plan carefully and stop there unless you are intentionally executing a real deployment. Cloud Exadata Infrastructure and VM Cluster operations can take a long time and may involve service-side capacity checks.
