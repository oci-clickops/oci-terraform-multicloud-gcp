# Oracle Autonomous Database@Google Cloud Terraform Module Specification

## Table of Contents

- [Overview](#overview)
- [Compatibility](#compatibility)
- [Module Inputs](#module-inputs)
- [Autonomous Databases](#autonomous-databases)
- [Module Outputs](#module-outputs)

## <a name="overview">Overview</a>

This document is the technical contract for the module. Use it when you need exact input shapes, reference rules, lifecycle behavior, or output names.

The README covers deployment guidance and examples. This specification focuses on the Terraform interface: keyed resource maps, networking mode validation, lifecycle drift policy, and outputs.

## <a name="compatibility">Compatibility</a>

This module requires Terraform `>= 1.3.0` and HashiCorp Google provider `>= 7.13.0, < 8.0.0`. The schema was validated against Google provider `7.31.0` on May 6, 2026.

Google Cloud project enablement, Oracle Database@Google Cloud entitlement, IAM permissions, and provider authentication are external prerequisites.

## <a name="module-inputs">Module Inputs</a>

The module accepts these input variables.

### General

* `module_name`: The module name. Defaults to `oracle-autonomous-database-at-gcp`.
* `enable_output`: Whether Terraform should enable module output. Defaults to `true`.
* `output_path`: Optional directory where dependency JSON files are written for downstream stacks.
* `default_project_id`: Default Google Cloud project ID used by resources when `project_id` is not set on the resource.
* `default_location`: Default Google Cloud region used by resources when `location` is not set on the resource.
* `default_labels`: Default labels merged into all resources. Resource-specific labels win on key collisions.
* `default_deletion_protection`: Default deletion protection value. Defaults to `true`.
* `gcp_odb_networks_dependency`: Externally managed ODB Networks this module may consume by key. Accepts a map, a map wrapped under `gcp_odb_networks`, or a path to a JSON dependency file produced by the ExaDB module (`modules/exadb/`).
* `gcp_odb_subnets_dependency`: Externally managed ODB Subnets this module may consume by key. Accepts a map, a map wrapped under `gcp_odb_subnets`, or a path to a JSON dependency file produced by the ExaDB module (`modules/exadb/`).
* `gcp_autonomous_databases_admin_passwords`: Admin passwords for Autonomous Databases, keyed by the same keys as `gcp_autonomous_databases_configuration`. Sensitive. Do not store in committed files — use `TF_VAR_gcp_autonomous_databases_admin_passwords` instead.

### Dependency Inputs

`gcp_odb_networks_dependency` and `gcp_odb_subnets_dependency` implement the OCI Landing Zones state-handoff pattern. A producer stack sets `output_path` on the ExaDB module (`modules/exadb/`) to write JSON files, and a consumer stack passes those file paths into this module.

`gcp_odb_networks_dependency` entries:

* `id`: Required. Full resource name in `projects/{project}/locations/{location}/odbNetworks/{odb_network}` format.

`gcp_odb_subnets_dependency` entries:

* `id`: Required. Full resource name in `projects/{project}/locations/{location}/odbNetworks/{odb_network}/odbSubnets/{odb_subnet}` format.

## <a name="autonomous-databases">Autonomous Databases</a>

* `gcp_autonomous_databases_configuration`: Map of Autonomous Databases to create.

Each map value has these attributes:

* `autonomous_database_id`: Required. The Autonomous Database ID. Must start with a lowercase letter, end with a lowercase letter or number, contain only lowercase letters, numbers, and hyphens, and be 1–63 characters long.
* `database`: Optional. Database name.
* `display_name`: Optional. Human-readable display name.
* `location`: Optional. The Google Cloud region. Overrides `default_location`.
* `project_id`: Optional. The Google Cloud project ID. Overrides `default_project_id`.
* `labels`: Optional. Labels for the database.
* `deletion_protection`: Optional. Whether deletion protection is enabled. Overrides `default_deletion_protection`.
* `timeouts`: Optional. Provider timeout overrides for `create`, `update`, and `delete`.

**Networking — exactly one mode must be used:**

* `network`: Optional. VPC network full resource name in `projects/{project}/global/networks/{network}` format. Use with `cidr`.
* `cidr`: Optional. CIDR block for the Autonomous Database subnet in VPC mode.
* `odb_network`: Optional. ODB Network full resource name in `projects/{project}/locations/{location}/odbNetworks/{odb_network}` format. Mutually exclusive with `network`.
* `odb_network_key`: Optional. Key of an ODB Network in `gcp_odb_networks_dependency`. Mutually exclusive with `odb_network` and `network`.
* `odb_subnet`: Optional. ODB Subnet full resource name in `projects/{project}/locations/{location}/odbNetworks/{odb_network}/odbSubnets/{odb_subnet}` format. Mutually exclusive with `cidr`.
* `odb_subnet_key`: Optional. Key of an ODB Subnet in `gcp_odb_subnets_dependency`.

The `properties` object has these attributes:

* `db_workload`: Optional. `DB_WORKLOAD_UNSPECIFIED`, `OLTP`, `DW`, `AJD`, or `APEX`.
* `license_type`: Optional. `LICENSE_TYPE_UNSPECIFIED`, `LICENSE_INCLUDED`, or `BRING_YOUR_OWN_LICENSE`.
* `compute_count`: Optional. Number of compute servers.
* `cpu_core_count`: Optional. Number of CPU cores.
* `data_storage_size_tb`: Optional. Storage size in terabytes.
* `data_storage_size_gb`: Optional. Storage size in gigabytes.
* `db_version`: Optional. Oracle Database version, for example `19c` or `23ai`.
* `db_edition`: Optional. `DATABASE_EDITION_UNSPECIFIED`, `STANDARD_EDITION`, or `ENTERPRISE_EDITION`.
* `character_set`: Optional. Character set. Default: `AL32UTF8`.
* `n_character_set`: Optional. National character set. Default: `AL16UTF16`.
* `private_endpoint_ip`: Optional. Private endpoint IP address.
* `private_endpoint_label`: Optional. Private endpoint label.
* `is_auto_scaling_enabled`: Optional. Enable CPU auto-scaling.
* `is_storage_auto_scaling_enabled`: Optional. Enable storage auto-scaling.
* `backup_retention_period_days`: Optional. Backup retention days, 1–60.
* `maintenance_schedule_type`: Optional. `MAINTENANCE_SCHEDULE_TYPE_UNSPECIFIED`, `EARLY`, or `REGULAR`.
* `mtls_connection_required`: Optional. Whether mTLS is required.
* `operations_insights_state`: Optional. Operations Insights state.
* `secret_id`: Optional. OCI vault secret ID for the admin password.
* `vault_id`: Optional. OCI vault ID.
* `customer_contacts`: Optional. List of `{ email = string }` objects for Oracle support notifications.

The module intentionally ignores Terraform drift for selected Autonomous Database fields. These values can change after Oracle-managed maintenance or after operations performed through the OCI control plane.

Ignored Autonomous Database fields:

* `admin_password`
* `properties[0].compute_count`
* `properties[0].cpu_core_count`
* `properties[0].data_storage_size_tb`
* `properties[0].data_storage_size_gb`
* `properties[0].db_version`
* `properties[0].is_auto_scaling_enabled`
* `properties[0].is_storage_auto_scaling_enabled`

The policy is deliberately limited to operational and auto-scaling fields that are likely to drift when Google and OCI control planes are both used. Labels and all other attributes remain visible to Terraform.

Provider resource: `google_oracle_database_autonomous_database`.

## <a name="module-outputs">Module Outputs</a>

The module returns these outputs:

* `module_name`: The module instance name.
* `gcp_autonomous_databases`: Created Autonomous Databases, keyed by input key.

Each database output includes `id`, `name`, `location`, `project`, `ocid`, `state`, `oci_url`, and `connection_strings`. Outputs are disabled when `enable_output` is set to `false`.

When `output_path` is set, the module writes `gcp_autonomous_databases_output.json` when matching resources exist.
