# Basic

Use this example to create only the Oracle Database@Google Cloud networking layer on top of an existing Google Cloud VPC:

* One ODB network
* One client ODB subnet
* One backup ODB subnet

This example does not create Cloud Exadata Infrastructure or Cloud VM Clusters. Use it when the platform or landing zone owns the VPC and you want to validate Oracle Database@Google Cloud networking without consuming Exadata capacity.

It is also useful as a separate Terraform state boundary. One state can own the ODB Network and ODB Subnets, set `output_path`, and publish dependency JSON files for a later Exadata/VM Cluster state. This mirrors the common split between platform networking and database infrastructure.

## Prerequisites

Before running it, confirm that:

* The Google Cloud project is enabled for Oracle Database@Google Cloud.
* The target VPC network already exists.
* Google provider authentication is configured.
* The caller has permissions to manage Oracle Database@Google Cloud ODB networks and ODB subnets and to reference the VPC network.

## Usage

```sh
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` with your project, region, Oracle zone, VPC network, ODB subnet CIDR ranges, and optional `output_path`.

```sh
terraform init -backend=false
terraform validate
terraform plan
```

Review the plan carefully and stop there unless you are intentionally creating the ODB Network and ODB Subnets.

When `output_path` is set, apply writes `gcp_odb_networks_output.json` and `gcp_odb_subnets_output.json` to that directory. Those files can be passed directly to `examples/state-handoff-vm-cluster`.
