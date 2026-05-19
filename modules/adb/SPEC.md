# Oracle Autonomous Database@Google Cloud Terraform Module Specification

## Table of Contents

- [Overview](#overview)
- [Compatibility](#compatibility)
- [Module Inputs](#module-inputs)
- [Autonomous Databases](#autonomous-databases)
- [Plan-time Validations](#plan-time-validations)
- [Module Outputs](#module-outputs)

## <a name="overview">Overview</a>

This document is the technical contract for the module. Use it when you need exact input shapes, reference rules, lifecycle behavior, or output names.

The README covers deployment guidance and examples. This specification focuses on the Terraform interface: keyed resource maps, networking mode validation, lifecycle drift policy, and outputs.

## <a name="compatibility">Compatibility</a>

This module requires Terraform `>= 1.4.0` and HashiCorp Google provider `>= 7.13.0, < 8.0.0`. The schema was validated against Google provider `7.32.0` on May 19, 2026.

Google Cloud project enablement, Oracle Database@Google Cloud entitlement, IAM permissions, and provider authentication are external prerequisites.

For v1, Autonomous Databases intentionally use ODB Network mode only. The Google provider still exposes legacy VPC/CIDR inputs (`network` and `cidr`), but those fields are outside this module's public contract for new environments.

Out of scope for this module: legacy VPC/CIDR mode, Autonomous Database clones, refreshable clones, and cross-region clones (the provider's `source_config` block on `google_oracle_database_autonomous_database` is not exposed). Use the Google provider directly or extend this module if these capabilities are required.

## <a name="module-inputs">Module Inputs</a>

The module accepts these input variables.

### General

* `module_name`: The module name. Defaults to `oracle-autonomous-database-at-gcp`. It must be compatible with Google Cloud label value syntax because it is included in the module label.
* `enable_output`: Whether Terraform should enable module outputs and JSON handoff file creation. Defaults to `true`.
* `output_path`: Optional producer-side directory where dependency JSON files are written for downstream stacks when outputs are enabled and matching resources exist.
* `default_project_id`: Default Google Cloud project ID used by resources when `project_id` is not set on the resource. If set, it must be non-empty.
* `default_location`: Default Google Cloud region used by resources when `location` is not set on the resource. If set, it must be non-empty.
* `default_labels`: Default labels merged into all resources. Resource-specific labels win on key collisions. Keys and values must follow Google Cloud label syntax: lowercase letters, numbers, underscores, and hyphens; keys must start with a lowercase letter; values may be empty.
* `default_deletion_protection`: Default deletion protection value. Defaults to `true`.
* `gcp_odb_networks_dependency`: Externally managed ODB Networks this module may consume by key. Accepts a map or a map wrapped under `gcp_odb_networks`.
* `gcp_odb_subnets_dependency`: Externally managed ODB Subnets this module may consume by key. Accepts a map or a map wrapped under `gcp_odb_subnets`.
* `gcp_autonomous_databases_admin_passwords`: Admin passwords for Autonomous Databases, keyed by the same keys as `gcp_autonomous_databases_configuration`. Sensitive. Do not store in committed files — use `TF_VAR_gcp_autonomous_databases_admin_passwords` instead. Each configured database must have a matching password entry unless `properties.secret_id` is set, and unknown password keys are rejected when databases are configured. Values must be 12–30 characters, include at least one uppercase letter, one lowercase letter, and one number, and must not contain double quotes or `admin` in any casing.

### Dependency Inputs

`gcp_odb_networks_dependency` and `gcp_odb_subnets_dependency` implement the OCI Landing Zones state-handoff pattern. A consumer stack passes dependency maps from Terragrunt `dependency` blocks, `terraform_remote_state` outputs, HCP Terraform workspace outputs, or CI/CD pipeline variables directly into these inputs. As an optional bridge for standalone stacks, a producer can set `enable_output = true` and `output_path` on the ODB networking module (`modules/odb-networking/`) to write JSON files; the consumer wrapper decodes those files and passes the resulting maps to this module. Remote-state, GCS, GitHub, Terraform Cloud, RMS, local file decoding, or other transport concerns belong outside this reusable module.

`gcp_odb_networks_dependency` entries:

* `id`: Required. Full resource name in `projects/{project}/locations/{location}/odbNetworks/{odb_network}` format.

`gcp_odb_subnets_dependency` entries:

* `id`: Required. Full resource name in `projects/{project}/locations/{location}/odbNetworks/{odb_network}/odbSubnets/{odb_subnet}` format.
* `purpose`: Required. `CLIENT_SUBNET` or `BACKUP_SUBNET`. The module validates this field is set on every dependency entry and additionally rejects subnets that resolve to a non-`CLIENT_SUBNET` purpose when referenced by an Autonomous Database via `odb_subnet_key`. The same map produced by `modules/odb-networking` already emits this field, so the handoff works without modification.

## <a name="autonomous-databases">Autonomous Databases</a>

* `gcp_autonomous_databases_configuration`: Map of Autonomous Databases to create.

Each map value has these attributes:

* `autonomous_database_id`: Required. The Autonomous Database ID. Must start with a lowercase letter, end with a lowercase letter or number, contain only lowercase letters, numbers, and hyphens, and be 1–63 characters long.
* `database`: Optional. Database name. If set, it must begin with a letter, contain only alphanumeric characters, and be at most 30 characters long. Provider/API uniqueness rules still apply at create time.
* `display_name`: Optional. Human-readable display name. Defaults to `autonomous_database_id` when omitted.
* `location`: Optional. The Google Cloud region. Overrides `default_location`. If set, it must be non-empty.
* `project_id`: Optional. The Google Cloud project ID. Overrides `default_project_id`. If set, it must be non-empty.
* `labels`: Optional. Labels for the database. Keys and values must follow the same Google Cloud label syntax as `default_labels`.
* `deletion_protection`: Optional. Whether deletion protection is enabled. Overrides `default_deletion_protection`.
* `timeouts`: Optional. Provider timeout overrides for `create`, `update`, and `delete`.

**Networking — ODB Network mode:**

* `odb_network`: Optional. ODB Network full resource name in `projects/{project}/locations/{location}/odbNetworks/{odb_network}` format.
* `odb_network_key`: Optional. Key of an ODB Network in `gcp_odb_networks_dependency`.
* `odb_subnet`: Optional. ODB Subnet full resource name in `projects/{project}/locations/{location}/odbNetworks/{odb_network}/odbSubnets/{odb_subnet}` format.
* `odb_subnet_key`: Optional. Key of an ODB Subnet in `gcp_odb_subnets_dependency`.

Each Autonomous Database must set exactly one ODB Network reference (`odb_network` or `odb_network_key`) and exactly one ODB Subnet reference (`odb_subnet` or `odb_subnet_key`).

The `properties` object has these attributes:

* `db_workload`: Required. `DB_WORKLOAD_UNSPECIFIED`, `OLTP`, `DW`, `AJD`, or `APEX`.
* `license_type`: Required. `LICENSE_TYPE_UNSPECIFIED`, `LICENSE_INCLUDED`, or `BRING_YOUR_OWN_LICENSE`.
* `compute_count`: Optional. Number of compute servers.
* `cpu_core_count`: Optional. Number of CPU cores.
* `data_storage_size_tb`: Optional. Storage size in terabytes.
* `data_storage_size_gb`: Optional. Storage size in gigabytes.
* `db_version`: Optional. Oracle Database version, for example `19c` or `23ai`. If set, it must be non-empty.
* `db_edition`: Optional. `DATABASE_EDITION_UNSPECIFIED`, `STANDARD_EDITION`, or `ENTERPRISE_EDITION`.
* `character_set`: Optional. Character set. Default: `AL32UTF8`. If set, it must be non-empty.
* `n_character_set`: Optional. National character set. Default: `AL16UTF16`. If set, it must be non-empty.
* `private_endpoint_ip`: Optional. Private endpoint IPv4 address without CIDR suffix.
* `private_endpoint_label`: Optional. Private endpoint label. If set, it must be non-empty.
* `is_auto_scaling_enabled`: Optional. Enable CPU auto-scaling.
* `is_storage_auto_scaling_enabled`: Optional. Enable storage auto-scaling.
* `backup_retention_period_days`: Optional. Backup retention days, 1–60.
* `maintenance_schedule_type`: Optional. `MAINTENANCE_SCHEDULE_TYPE_UNSPECIFIED`, `EARLY`, or `REGULAR`.
* `mtls_connection_required`: Optional. Whether mTLS is required.
* `operations_insights_state`: Optional. `OPERATIONS_INSIGHTS_STATE_UNSPECIFIED`, `ENABLING`, `ENABLED`, `DISABLING`, `NOT_ENABLED`, `FAILED_ENABLING`, or `FAILED_DISABLING`.
* `secret_id`: Optional. OCI vault secret ID for the admin password. If set, it must be non-empty.
* `vault_id`: Optional. OCI vault ID. If set, it must be non-empty.
* `customer_contacts`: Optional. List of `{ email = string }` objects for Oracle support notifications.

The module intentionally ignores Terraform drift for selected Autonomous Database fields. These values can change after Oracle-managed maintenance or after operations performed through the OCI control plane.

Ignored Autonomous Database fields:

* `labels`
* `admin_password`
* `properties[0].compute_count`
* `properties[0].cpu_core_count`
* `properties[0].data_storage_size_tb`
* `properties[0].data_storage_size_gb`
* `properties[0].db_version`
* `properties[0].db_edition`
* `properties[0].is_auto_scaling_enabled`
* `properties[0].is_storage_auto_scaling_enabled`
* `properties[0].backup_retention_period_days`
* `properties[0].operations_insights_state`

The policy follows Oracle's published guidance for the dual control-plane model (see [Modify an Autonomous Database](https://docs.oracle.com/en-us/iaas/Content/database-at-gcp/gcpmd-modify-autonomous-ai-database.html)), which recommends ignoring capacity, storage, version, edition, auto-scaling flags, and backup retention fields that change when Day-2 operations are performed through the OCI control plane. `operations_insights_state` is additionally ignored because the Google Cloud Oracle Database REST API marks it as output-only. Labels are also ignored after creation because the current Google provider plans replacement for label-only changes. Treat Autonomous Database labels as creation-time metadata. All other attributes remain visible to Terraform.

Provider resource: `google_oracle_database_autonomous_database`.

## <a name="plan-time-validations">Plan-time Validations</a>

The module enforces these checks at `terraform plan`, not at apply, to avoid late provider failures:

* **Reference requirement and mutex** — each entry must set exactly one of `odb_network` or `odb_network_key`, and exactly one of `odb_subnet` or `odb_subnet_key`.
* **Geographic coherence** — `odb_subnet` (literal or resolved through `odb_subnet_key`) must belong to the selected `odb_network` and share the same project, location, and parent ODB Network segment.
* **Subnet purpose** — when `odb_subnet_key` resolves through `gcp_odb_subnets_dependency`, the referenced subnet must have `purpose = "CLIENT_SUBNET"`. Backup subnets are rejected.
* **Admin password policy** — each configured database must have a matching entry in `gcp_autonomous_databases_admin_passwords` unless `properties.secret_id` is set, and password keys that do not match configured database keys are rejected. Each supplied admin password must satisfy the Oracle Autonomous Database password policy enforced by the module: length 12–30, at least one uppercase letter, one lowercase letter, one number, no double quotes, and no `admin` substring in any casing.
* **Database name format** — `database`, when set, must match the Google provider rule: starts with a letter, contains only alphanumeric characters, and is at most 30 characters long. Duplicate resource or database names are left to the Google provider/API, matching the OCI module style.
* **Google label syntax** — `default_labels` and per-resource `labels` are validated for Google Cloud label-compatible keys and values before planning resources.
* **Project and location hygiene** — `default_project_id`, `default_location`, per-resource `project_id`, and per-resource `location` can be omitted, but cannot be whitespace-only strings.
* **Provider enum coverage** — `operations_insights_state` is restricted to the values exposed by the Google provider schema.
* **Private endpoint IP format** — `private_endpoint_ip` must be a plain IPv4 address, not a CIDR range.
* **Non-empty optional strings** — exposed optional string fields that are passed directly to the provider (`character_set`, `n_character_set`, `db_version`, `private_endpoint_label`, `secret_id`, and `vault_id`) cannot be whitespace-only strings.

These checks fail with actionable error messages before any Google Cloud API call is made. They complement the variable-level format validations (resource name regex, enum values, numeric ranges) which run earlier as part of input parsing.

## <a name="module-outputs">Module Outputs</a>

The module returns these outputs:

* `module_name`: The module instance name.
* `gcp_autonomous_databases`: Created Autonomous Databases, keyed by input key.

Each database output includes:

* Google identifiers: `id`, `name`, `location`, and `project`.
* OCI identifiers: `ocid`, `oci_url`, `oci_region`, `oci_tenant`, and `oci_compartment_id`.
* Connectivity details: `connection_strings`, `connection_urls`, `private_endpoint`, `private_endpoint_ip`, `private_endpoint_label`, and `sql_web_developer_url`.
* Lifecycle and peer metadata: `state`, `role`, `peer_autonomous_databases`, `peer_db_ids`, `permission_level`, `is_local_data_guard_enabled`, `local_disaster_recovery_type`, `local_standby_db`, and `disaster_recovery_supported_locations`.

If `enable_output` is `false`, Terraform outputs return `null` and no JSON files are written.

When `enable_output = true` and `output_path` is set, the module writes `gcp_autonomous_databases_output.json` when matching resources exist. The JSON shape is wrapped under `gcp_autonomous_databases`, matching the dependency maps consumed by downstream wrappers.
