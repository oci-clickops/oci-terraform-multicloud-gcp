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
- [Known Issues](#known-issues)

## <a name="overview">Overview</a>

This module creates Oracle Autonomous Databases on Google Cloud using the `google_oracle_database_autonomous_database` resource.

For v1, new Autonomous Database deployments use ODB Network mode only: `odb_network` / `odb_subnet`, either directly or through module keys. The Google provider still exposes the older VPC/CIDR fields, but this module does not expose them as a public interface because new Oracle Database@Google Cloud environments should use ODB Networks and ODB Subnets.

The module follows the OCI Landing Zones style. Databases are declared through keyed maps, created with `for_each`, and returned with the same keys in the outputs.

Use this README for deployment guidance. Use [SPEC.md](./SPEC.md) for the full input and output contract.

For the recommended Day-1 and Day-2 control plane model, which is shared across the Oracle Database@AWS, Oracle Database@Google Cloud, and Oracle Database@Azure modules, see the [oci-multicloud-control-plane-model](https://github.com/oci-clickops/oci-multicloud-control-plane-model) repository.

## <a name="pre-requisites">Pre-requisites</a>

Before running Terraform against real infrastructure, make sure these pieces are already in place:

* A Google Cloud project enabled for Oracle Database@Google Cloud.
* Google provider authentication for the Terraform caller.
* IAM permissions to manage Oracle Database@Google Cloud resources.
* Terraform `>= 1.4.0` and HashiCorp Google provider `>= 7.13.0, < 8.0.0`.
* An existing ODB Network and client ODB Subnet, created by `modules/odb-networking` or an equivalent stack.
* Oracle Database@Google Cloud entitlement and capacity in the target project and region.

The admin password is accepted as a separate sensitive input keyed by the same map key as the database. Do not store passwords in tfvars files committed to version control. Use the `TF_VAR_gcp_autonomous_databases_admin_passwords` environment variable instead.

## <a name="getting-started">Getting Started</a>

Start with [examples/vision](./examples/vision) for a complete ODB Network mode deployment. It creates a single Autonomous Database with a full set of properties.

If you are using an ODB Network created by a separate networking stack, use [examples/existing-odb-network](./examples/existing-odb-network) instead.

## <a name="configuration-model">Configuration Model</a>

Each database in `gcp_autonomous_databases_configuration` must set exactly one ODB Network reference and one ODB Subnet reference. Each reference can be direct or key-based.

`*_key` form — recommended when the upstream ODB Network and Subnet come from dependency maps supplied by Terragrunt `dependency` blocks, `terraform_remote_state` outputs, HCP Terraform workspace outputs, or CI/CD pipeline variables:

```hcl
gcp_odb_networks_dependency = {
  prod-net = {
    id = "projects/my-project/locations/us-east4/odbNetworks/prod-net"
  }
}

gcp_odb_subnets_dependency = {
  prod-client = {
    id      = "projects/my-project/locations/us-east4/odbNetworks/prod-net/odbSubnets/prod-client"
    purpose = "CLIENT_SUBNET"
  }
}

gcp_autonomous_databases_configuration = {
  "txn" = {
    autonomous_database_id = "txn"
    odb_network_key        = "prod-net"     # logical key from the dependency file
    odb_subnet_key         = "prod-client"
    properties             = { db_workload = "OLTP", license_type = "LICENSE_INCLUDED" }
  }
}
```

As an optional bridge for local development, demos, or file-based orchestration, a producer can set `output_path` in `modules/odb-networking` to write JSON handoff files. Reusable module inputs still receive dependency maps; wrappers such as `examples/existing-odb-network` are responsible for reading JSON files with `jsondecode(file(...))` before passing those maps to this module.

Direct form — useful when the ODB Network and Subnet were created by `gcloud`, an OCI console operator, or a stack that does not produce a JSON handoff:

```hcl
gcp_autonomous_databases_configuration = {
  "txn" = {
    autonomous_database_id = "txn"
    odb_network            = "projects/my-project/locations/us-east4/odbNetworks/prod-net"
    odb_subnet             = "projects/my-project/locations/us-east4/odbNetworks/prod-net/odbSubnets/prod-client"
    properties             = { db_workload = "OLTP", license_type = "LICENSE_INCLUDED" }
  }
}
```

Set exactly one of `odb_network` or `odb_network_key`, and exactly one of `odb_subnet` or `odb_subnet_key`. The two forms are mutually exclusive on the same field pair and can be mixed across entries in the same map when ownership differs.

Common defaults such as project, location, labels, and deletion protection are handled by module-level inputs. Resource-specific values override the defaults. When `display_name` is omitted, Autonomous Database resources use `autonomous_database_id` as the display name. `module_name` is validated and the generated module label is sanitized for Google Cloud label rules.

The module performs strict validation at `terraform plan`: ODB Network and Subnet references must be geographically consistent (same project, location, and parent ODB Network segment), dependency-provided subnets must declare `purpose = "CLIENT_SUBNET"` to be usable, and `autonomous_database_id` must be unique within each `(project, location)`. Configuration errors fail the plan with actionable messages instead of producing a late Google Cloud API error during apply. See [SPEC.md](./SPEC.md#plan-time-validations) for the full list.

## <a name="operational-drift-policy">Operational Drift Policy</a>

Oracle Autonomous Database can be operated through both Google and OCI control planes. Several properties drift during Oracle-managed maintenance or OCI-side operations. The module ignores changes to:

* `admin_password` — not rotated by Terraform after initial provisioning.
* `properties[0].compute_count` and `properties[0].cpu_core_count` — may change through auto-scaling.
* `properties[0].data_storage_size_tb` and `properties[0].data_storage_size_gb` — may change through storage auto-scaling.
* `properties[0].db_version` — may change through Oracle-managed upgrades.
* `properties[0].db_edition` — may change through OCI Day-2 operations.
* `properties[0].is_auto_scaling_enabled` and `properties[0].is_storage_auto_scaling_enabled` — may change through OCI operations.
* `properties[0].backup_retention_period_days` — may be adjusted through OCI Day-2 operations.
* `properties[0].operations_insights_state` — output-only in the Google Cloud Oracle Database API; the service controls it and Terraform cannot reliably reconcile it.

The policy follows Oracle's published guidance for the dual control-plane model. Labels and all other attributes remain visible to Terraform.

The exact ignored fields and rationale are documented in [SPEC.md](./SPEC.md).

## <a name="examples">Examples</a>

Available examples:

* [examples/vision](./examples/vision): recommended first deployment — complete Autonomous Database in ODB Network mode with direct resource names and a ready-to-rename `input.auto.tfvars.template`.
* [examples/existing-odb-network](./examples/existing-odb-network): creates an Autonomous Database using an existing ODB Network and ODB Subnet, passed as dependency maps or, for local file handoff, example-level `*_dependency_file_path` variables.

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

## <a name="known-issues">Known Issues</a>

1. Oracle Autonomous Database resources can take a long time to provision. If a creation or update operation is interrupted, rerun Terraform from the same working directory so it can continue from the current state.
2. The admin password is accepted at creation time but is not read back by the Google provider. Manage password rotation outside Terraform.
3. Some resource attributes are service-managed and appear only after provisioning completes. Downstream stacks should consume outputs only after the producing stack has completed successfully.
4. Both `odb_network` and `odb_subnet` references must exist before the Autonomous Database can be created. Provision the networking stack first.
