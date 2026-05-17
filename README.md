# Oracle Database@Google Cloud Terraform Modules

This repository provides Terraform modules for Oracle Database@Google Cloud resources managed through the HashiCorp Google provider.

## Modules

* [modules/exadb](./modules/exadb/README.md) — Cloud Exadata Infrastructure and Cloud VM Clusters, including ODB Networks and ODB Subnets.
* [modules/adb](./modules/adb/README.md) — Oracle Autonomous Databases in VPC networking mode or ODB Network mode.

Both modules follow the OCI Landing Zones style. Resources are declared through keyed maps, created with `for_each`, and returned with the same keys in the outputs. ODB Network dependency outputs produced by the ExaDB module can be consumed directly by the ADB module through the dependency injection pattern.

For the recommended Day-1 and Day-2 control plane model, see the [oci-multicloud-control-plane-model](https://github.com/oci-clickops/oci-multicloud-control-plane-model) repository.

## License

Copyright (c) 2026, Oracle and/or its affiliates.

Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.
