# Oracle Autonomous Database@Google Cloud Terraform Module

## Table of Contents

- [Overview](#overview)
- [Pre-requisites](#pre-requisites)
- [Getting Started](#getting-started)
- [Configuration Model](#configuration-model)
- [Operational Drift Policy](#operational-drift-policy)
- [Examples](#examples)
- [Module Outputs](#module-outputs)
- [License](#license)

## <a name="overview">Overview</a>

This module creates Oracle Autonomous Databases on Google Cloud using the `google_oracle_database_autonomous_database` resource.

It supports:

* Autonomous Databases in VPC networking mode (`network` + `cidr`)
* Autonomous Databases in ODB Network mode (`odb_network` + `odb_subnet`)

The module follows the OCI Landing Zones style. Databases are declared through keyed maps, created with `for_each`, and returned with the same keys in the outputs.

Use this README for deployment guidance. Use [SPEC.md](./SPEC.md) for the full input and output contract.

For the recommended Day-1 and Day-2 control plane model, which is shared across the Oracle Database@AWS, Oracle Database@Google Cloud, and Oracle Database@Azure modules, see the [oci-multicloud-control-plane-model](https://github.com/oci-clickops/oci-multicloud-control-plane-model) repository.

## <a name="pre-requisites">Pre-requisites</a>

Before running Terraform against real infrastructure, make sure these pieces are already in place:

* A Google Cloud project enabled for Oracle Database@Google Cloud.
* Google provider authentication for the Terraform caller.
* IAM permissions to manage Oracle Database@Google Cloud resources.
* Terraform `>= 1.3.0` and HashiCorp Google provider `>= 7.13.0, < 8.0.0`.
* For VPC mode: an existing Google Cloud VPC network and an available CIDR range.
* For ODB Network mode: an existing ODB Network and ODB Subnet, created by the root module or an equivalent stack.
* Oracle Database@Google Cloud entitlement and capacity in the target project and region.

The admin password is accepted as a separate sensitive input keyed by the same map key as the database. Do not store passwords in tfvars files committed to version control. Use the `TF_VAR_gcp_autonomous_databases_admin_passwords` environment variable instead.

## <a name="getting-started">Getting Started</a>

Start with [examples/vision](./examples/vision) for a complete VPC-mode deployment. It creates a single Autonomous Database with a full set of properties.

If you are using an ODB Network created by the root module, use [examples/existing-odb-network](./examples/existing-odb-network) instead.

## <a name="configuration-model">Configuration Model</a>

Two networking modes are supported. Each database in `gcp_autonomous_databases_configuration` must use exactly one:

* **VPC mode**: set `network` (full VPC resource name in `projects/{project}/global/networks/{network}` format) and `cidr` (CIDR block for the database subnet).
* **ODB Network mode**: set `odb_network` (full ODB Network resource name) or `odb_network_key` (logical key in `gcp_odb_networks_dependency`), plus `odb_subnet` or `odb_subnet_key`.

For ODB Network mode, pass existing ODB Network and ODB Subnet resource names or dependency maps through `gcp_odb_networks_dependency` and `gcp_odb_subnets_dependency`. These accept the same JSON dependency files produced by the root module when `output_path` is set.

Common defaults such as project, location, labels, and deletion protection are handled by module-level inputs. Resource-specific values override the defaults.

## <a name="operational-drift-policy">Operational Drift Policy</a>

Oracle Autonomous Database can be operated through both Google and OCI control planes. Several properties drift during Oracle-managed maintenance or OCI-side operations. The module ignores changes to:

* `admin_password` — not rotated by Terraform after initial provisioning.
* `properties[0].compute_count` and `properties[0].cpu_core_count` — may change through auto-scaling.
* `properties[0].data_storage_size_tb` and `properties[0].data_storage_size_gb` — may change through storage auto-scaling.
* `properties[0].db_version` — may change through Oracle-managed upgrades.
* `properties[0].is_auto_scaling_enabled` and `properties[0].is_storage_auto_scaling_enabled` — may change through OCI operations.
* `properties[0].operations_insights_state` — output-only in the Google Cloud Oracle Database API; the service controls it and Terraform cannot reliably reconcile it.

Labels and all other attributes remain visible to Terraform.

The exact ignored fields and rationale are documented in [SPEC.md](./SPEC.md).

## <a name="examples">Examples</a>

Available examples:

* [examples/vision](./examples/vision): recommended first deployment — complete Autonomous Database in VPC networking mode with a ready-to-rename `input.auto.tfvars.template`.
* [examples/existing-odb-network](./examples/existing-odb-network): creates an Autonomous Database using an existing ODB Network and ODB Subnet, passed as dependency inputs.

Each example includes an `input.auto.tfvars.template` file. Rename it to `<project-name>.auto.tfvars` and Terraform will load it automatically — no `terraform.tfvars` copy needed.

The examples deliberately do not declare a Terraform backend. For real deployments, configure a remote backend such as Google Cloud Storage, an OCI Object Storage bucket, Terraform Cloud, or any other supported backend in your own copy of the example.

## <a name="module-outputs">Module Outputs</a>

The module returns created resources with the same keys used in the input map:

* `gcp_autonomous_databases`

Each output includes stable identifiers, the OCI OCID, OCI console URL, connection strings, and lifecycle state. Set `enable_output = false` to suppress outputs.

When `output_path` is set, the module writes:

* `gcp_autonomous_databases_output.json`

## <a name="license">License</a>

Copyright (c) 2026, Oracle and/or its affiliates.

Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.
