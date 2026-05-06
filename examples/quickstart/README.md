# Quickstart

Use this example for a first end-to-end Oracle Database@Google Cloud deployment. It creates:

* One ODB network
* One client ODB subnet
* One backup ODB subnet
* One Cloud Exadata Infrastructure
* One Cloud VM Cluster

The example uses module keys to connect resources created in the same module call. It also sets a default maintenance window and explicit timeouts for long-running operations.

## Prerequisites

Before running it, confirm that:

* The Google Cloud project is enabled for Oracle Database@Google Cloud.
* The target region has the required entitlement and capacity.
* The VPC network already exists.
* Google provider authentication is configured.
* The caller has permissions to manage Oracle Database@Google Cloud resources and reference the VPC network.

## Usage

```sh
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` with your project, region, Oracle zone, VPC network, customer contact email, and SSH public key.

```sh
terraform init -backend=false
terraform validate
terraform plan
```

Review the plan carefully and stop there unless you are intentionally executing a real deployment. Pay particular attention to the Exadata Infrastructure and VM Cluster properties because those operations can take a long time and may involve service-side capacity checks.
