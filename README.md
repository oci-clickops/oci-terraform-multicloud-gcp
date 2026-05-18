# Oracle Database@Google Cloud Terraform Modules

This repository provides Terraform modules for Oracle Database@Google Cloud resources managed through the HashiCorp Google provider.

## Modules

* [modules/exadb](./modules/exadb/README.md) — Cloud Exadata Infrastructure and Cloud VM Clusters, including ODB Networks and ODB Subnets.
* [modules/adb](./modules/adb/README.md) — Oracle Autonomous Databases in VPC networking mode or ODB Network mode.

Both modules follow the OCI Landing Zones style. Resources are declared through keyed maps, created with `for_each`, and returned with the same keys in the outputs. ODB Network dependency outputs produced by the ExaDB module can be consumed directly by the ADB module through the dependency injection pattern.

For the recommended Day-1 and Day-2 control plane model, see [Oracle Database@Google Cloud Operations Best Practices](https://github.com/oracle-devrel/technology-engineering/blob/OA-OD%40GCP-Operations/operations-advisory/customer-operations/oracle-database/Oracle%20Database%20%40%20Google%20Cloud%20Operations/Oracle%20Database%20%40%20Google%20Operations%20Best%20Practices/README.md).

## Requirements

* Terraform `>= 1.3.0`
* HashiCorp Google provider `>= 7.13.0, < 8.0.0`
* Google Cloud CLI authenticated for the target project (`gcloud auth application-default login`)
* OCI CLI configured when operating through the OCI control plane in dual control-plane deployments
* A Google Cloud project enabled for Oracle Database@Google Cloud with the required entitlement and regional capacity

## Getting Started

For Cloud Exadata Infrastructure and VM Cluster deployments, start with [modules/exadb/examples/vision](./modules/exadb/examples/vision). It creates an ODB network, client and backup ODB subnets, a Cloud Exadata Infrastructure, and a Cloud VM Cluster end to end.

For Autonomous Database deployments, start with [modules/adb/examples/vision](./modules/adb/examples/vision). It creates a single Autonomous Database in VPC networking mode with a full set of properties.

Each example includes an `input.auto.tfvars.template` file. Rename it to `<project-name>.auto.tfvars` and Terraform will load it automatically.

## License

Copyright (c) 2026, Oracle and/or its affiliates.

Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.
