# Oracle Database@Google Cloud ODB Networking Module Specification

## Overview

This module creates ODB Networks and ODB Subnets for Oracle Database@Google Cloud. It is the shared producer module for ExaDB and ADB stacks that need ODB Network mode.

The module is intentionally narrow: it does not create Google Cloud VPC networks and it does not consume JSON files or remote state. It creates resources from keyed maps and returns keyed dependency outputs.

## Compatibility

This module requires Terraform `>= 1.4.0` and HashiCorp Google provider `>= 7.13.0, < 8.0.0`. The schema was validated against Google provider `7.32.0` on May 19, 2026.

## Inputs

### General

* `module_name`: The module name. Defaults to `oracle-database-networking-at-gcp`.
* `enable_output`: Whether Terraform should enable module outputs and JSON handoff file creation. Defaults to `true`.
* `output_path`: Optional producer-side directory where dependency JSON files are written when outputs are enabled and matching resources exist.
* `default_project_id`: Default Google Cloud project ID used when `project_id` is not set on a resource. If set, it must be non-empty.
* `default_location`: Default Google Cloud region used when `location` is not set on a resource. If set, it must be non-empty.
* `default_gcp_oracle_zone`: Default GCP Oracle zone used when `gcp_oracle_zone` is not set on an ODB Network. If set, it must be non-empty.
* `default_labels`: Default labels merged into all resources. Keys and values must follow Google Cloud label syntax: lowercase letters, numbers, underscores, and hyphens; keys must start with a lowercase letter; values may be empty.
* `default_deletion_protection`: Default deletion protection value. Defaults to `true`.

### ODB Networks

`gcp_odb_networks_configuration` is a map keyed by logical name. Each value has:

* `odb_network_id`: Required. ODB Network ID segment.
* `network`: Required. Existing Google Cloud VPC network resource name in `projects/{project}/global/networks/{network}` format.
* `location`: Optional. Overrides `default_location`. If set, it must be non-empty.
* `project_id`: Optional. Overrides `default_project_id`. If set, it must be non-empty.
* `gcp_oracle_zone`: Optional. Overrides `default_gcp_oracle_zone`. If set, it must be non-empty.
* `labels`: Optional. Resource labels. Keys and values must follow the same Google Cloud label syntax as `default_labels`.
* `deletion_protection`: Optional. Overrides `default_deletion_protection`.
* `timeouts`: Optional provider timeout overrides.

Provider resource: `google_oracle_database_odb_network`.

### ODB Subnets

`gcp_odb_subnets_configuration` is a map keyed by logical name. Each value has:

* `odb_subnet_id`: Required. ODB Subnet ID segment.
* `cidr_range`: Required. CIDR range for the ODB Subnet.
* `purpose`: Required. `CLIENT_SUBNET` or `BACKUP_SUBNET`.
* `odbnetwork`: Optional. Parent ODB Network ID segment. Mutually exclusive with `odb_network_key`.
* `odb_network_key`: Optional. Key of an ODB Network in `gcp_odb_networks_configuration`. Mutually exclusive with `odbnetwork`.
* `location`: Optional. Overrides `default_location`. If set, it must be non-empty.
* `project_id`: Optional. Overrides `default_project_id`. If set, it must be non-empty.
* `labels`: Optional. Resource labels. Keys and values must follow the same Google Cloud label syntax as `default_labels`.
* `deletion_protection`: Optional. Overrides `default_deletion_protection`.
* `timeouts`: Optional provider timeout overrides.

Provider resource: `google_oracle_database_odb_subnet`.

## Validations

* ODB Network and ODB Subnet IDs must follow Google resource ID syntax.
* ODB Network `network` values must use `projects/{project}/global/networks/{network}` format.
* ODB Subnet CIDR ranges must be valid CIDR blocks.
* ODB Subnet purpose must be `CLIENT_SUBNET` or `BACKUP_SUBNET`.
* Each ODB Subnet must set exactly one of `odbnetwork` or `odb_network_key`.
* `odb_network_key` must reference an ODB Network created by this module.
* ODB Network resources must set `gcp_oracle_zone` or `default_gcp_oracle_zone`.
* Project, location, and GCP Oracle zone defaults and overrides can be omitted when another value supplies the setting, but cannot be whitespace-only strings.
* `default_labels`, ODB Network `labels`, and ODB Subnet `labels` must use Google Cloud label-compatible syntax.
* ODB Network and ODB Subnet ID uniqueness is enforced by the Google provider/API at create time.

## Operational Drift Policy

The module intentionally ignores Terraform drift for ODB Network and ODB Subnet `labels`.

The policy is intentionally narrow. The current Google provider plans replacement for label-only changes on `google_oracle_database_odb_network` and `google_oracle_database_odb_subnet`. Labels are therefore treated as creation-time tracking metadata to avoid accidental replacement of networking resources. All other ODB Networking attributes remain visible to Terraform.

## Outputs

* `module_name`: The module instance name.
* `gcp_odb_networks`: Created ODB Networks, keyed by input key.
* `gcp_odb_subnets`: Created ODB Subnets, keyed by input key.

When `enable_output = true` and `output_path` is set, the module writes files for matching resources:

* `gcp_odb_networks_output.json`
* `gcp_odb_subnets_output.json`

The JSON shape is wrapped under the output family name, matching the dependency maps consumed by `modules/exadb` and `modules/adb`.

If `enable_output` is `false`, Terraform outputs return `null` and no JSON files are written. The module never reads JSON files, remote state, object storage, or other transport-specific sources.
