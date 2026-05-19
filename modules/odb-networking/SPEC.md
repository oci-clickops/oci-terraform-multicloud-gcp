# Oracle Database@Google Cloud ODB Networking Module Specification

## Overview

This module creates ODB Networks and ODB Subnets for Oracle Database@Google Cloud. It is the shared producer module for ExaDB and ADB stacks that need ODB Network mode.

The module is intentionally narrow: it does not create Google Cloud VPC networks and it does not consume JSON files or remote state. It creates resources from keyed maps and returns keyed dependency outputs.

## Compatibility

This module requires Terraform `>= 1.4.0` and HashiCorp Google provider `>= 7.13.0, < 8.0.0`. The schema was validated against Google provider `7.32.0` on May 19, 2026.

## Inputs

### General

* `module_name`: The module name. Defaults to `oracle-database-networking-at-gcp`.
* `enable_output`: Whether Terraform should enable module outputs. Defaults to `true`.
* `output_path`: Optional directory where dependency JSON files are written.
* `default_project_id`: Default Google Cloud project ID used when `project_id` is not set on a resource.
* `default_location`: Default Google Cloud region used when `location` is not set on a resource.
* `default_gcp_oracle_zone`: Default GCP Oracle zone used when `gcp_oracle_zone` is not set on an ODB Network.
* `default_labels`: Default labels merged into all resources.
* `default_deletion_protection`: Default deletion protection value. Defaults to `true`.

### ODB Networks

`gcp_odb_networks_configuration` is a map keyed by logical name. Each value has:

* `odb_network_id`: Required. ODB Network ID segment.
* `network`: Required. Existing Google Cloud VPC network resource name in `projects/{project}/global/networks/{network}` format.
* `location`: Optional. Overrides `default_location`.
* `project_id`: Optional. Overrides `default_project_id`.
* `gcp_oracle_zone`: Optional. Overrides `default_gcp_oracle_zone`.
* `labels`: Optional. Resource labels.
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
* `location`: Optional. Overrides `default_location`.
* `project_id`: Optional. Overrides `default_project_id`.
* `labels`: Optional. Resource labels.
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
* ODB Network IDs are unique within each `(project, location)`.
* ODB Subnet IDs are unique within each `(project, location, parent_odb_network)`.

## Outputs

* `module_name`: The module instance name.
* `gcp_odb_networks`: Created ODB Networks, keyed by input key.
* `gcp_odb_subnets`: Created ODB Subnets, keyed by input key.

When `output_path` is set and outputs are enabled, the module writes:

* `gcp_odb_networks_output.json`
* `gcp_odb_subnets_output.json`

The JSON shape is wrapped under the output family name, matching the dependency maps consumed by `modules/exadb` and `modules/adb`.
