# Oracle Database@Google Cloud Terraform Module Specification

## Table of Contents

1. Overview
2. Compatibility
3. Module Inputs
4. ODB Networks
5. ODB Subnets
6. Cloud Exadata Infrastructures
7. Cloud VM Clusters
8. Module Outputs

## Overview

This document is the technical contract for the module. Use it when you need exact input shapes, reference rules, lifecycle behavior, or output names.

The README covers deployment guidance and examples. This specification focuses on the Terraform interface: keyed resource maps, module-key references, input validation behavior, lifecycle drift policy, and outputs.

## Compatibility

This module requires Terraform `>= 1.3.0` and HashiCorp Google provider `>= 7.13.0, < 8.0.0`. The schema was validated against Google provider `7.31.0` on May 6, 2026.

Google Cloud project enablement, Oracle Database@Google Cloud entitlement, IAM permissions, provider authentication, and VPC networking are external prerequisites. The module validates the Terraform-side input contract, but it cannot validate service entitlement or regional capacity before the provider calls the Google API.

The module intentionally does not create Google Cloud VPC networks. VPCs are expected to be provided by the platform foundation or Google Cloud landing zone, commonly through a Shared VPC or centrally governed networking stack. The module consumes the existing VPC resource name in `gcp_odb_networks_configuration[*].network` and owns the Oracle Database@Google Cloud resources layered on top of it.

## Module Inputs

The module accepts these input variables.

### General

* `module_name`: The module name. Defaults to `oracle-database-at-gcp`.
* `enable_output`: Whether Terraform should enable module output. Defaults to `true`.
* `default_project_id`: Default Google Cloud project ID used by resources when `project_id` is not set on the resource.
* `default_location`: Default Google Cloud region used by resources when `location` is not set on the resource.
* `default_gcp_oracle_zone`: Default GCP Oracle zone used by resources that support it.
* `default_labels`: Default labels merged into all resources. Resource-specific labels win on key collisions.
* `default_deletion_protection`: Default deletion protection value for resources that support `deletion_protection`. Defaults to `true`.
* `default_cloud_exadata_maintenance_window`: Default Cloud Exadata Infrastructure maintenance window used when a resource does not set `properties.maintenance_window`.
* `output_path`: Optional directory where dependency JSON files are written for downstream stacks.
* `gcp_odb_networks_dependency`: Externally managed ODB Networks that this module may consume by key. Accepts a map, a map wrapped under `gcp_odb_networks`, or a path to a JSON dependency file.
* `gcp_odb_subnets_dependency`: Externally managed ODB Subnets that this module may consume by key. Accepts a map, a map wrapped under `gcp_odb_subnets`, or a path to a JSON dependency file.
* `gcp_cloud_exadata_infrastructures_dependency`: Externally managed Cloud Exadata Infrastructures that this module may consume by key. Accepts a map, a map wrapped under `gcp_cloud_exadata_infrastructures`, or a path to a JSON dependency file.

### Dependency Inputs

Dependency inputs implement the OCI Landing Zones state-handoff pattern for Google resources. A producer stack can set `output_path` to write JSON files, and a consumer stack can pass those file paths or equivalent maps into this module. Remote-state, GCS, GitHub, Terraform Cloud, RMS, or other storage concerns belong outside this reusable module.

The module resolves `*_key` references against resources created in the same module call and against dependency inputs. A consumed key must exist in exactly one place. If the same logical key exists in both the local configuration map and the matching dependency map when it is consumed by a `*_key`, the module fails fast because the reference is ambiguous.

When `output_path` is set, these files are written when matching resources exist:

* `gcp_odb_networks_output.json`
* `gcp_odb_subnets_output.json`
* `gcp_cloud_exadata_infrastructures_output.json`

`gcp_odb_networks_dependency` is a map keyed by logical name. Each value has these attributes:

* `id`: Required. ODB Network full resource name in `projects/{project}/locations/{location}/odbNetworks/{odb_network}` format.
* `odb_network_id`: Optional. ODB Network ID segment. If omitted, the module derives it from `id` when an ODB Subnet needs the parent network segment. If provided, it must match the final ODB Network segment in `id`.

`gcp_odb_subnets_dependency` is a map keyed by logical name. Each value has these attributes:

* `id`: Required. ODB Subnet full resource name in `projects/{project}/locations/{location}/odbNetworks/{odb_network}/odbSubnets/{odb_subnet}` format.
* `purpose`: Optional. Accepted values are `CLIENT_SUBNET` and `BACKUP_SUBNET`. When provided, VM Cluster keys are validated against it.
* `odbnetwork`: Optional. Parent ODB Network ID segment. If omitted, the module derives it from `id`. If provided, it must match the parent ODB Network segment in `id`. VM Cluster networking references are validated so client and backup subnets belong to the selected ODB Network.

`gcp_cloud_exadata_infrastructures_dependency` is a map keyed by logical name. Each value has these attributes:

* `id`: Required. Cloud Exadata Infrastructure full resource name in `projects/{project}/locations/{region}/cloudExadataInfrastructures/{cloud_exadata_infrastructure}` format.

### ODB Networks

* `gcp_odb_networks_configuration`: Map of ODB networks to create.

Each map value has these attributes:

* `odb_network_id`: Required. The ODB network ID.
* `network`: Required. The existing Google Cloud VPC network resource name in `projects/{project}/global/networks/{network}` format. The VPC itself is not created by this module.
* `location`: Optional. The Google Cloud region. Overrides `default_location`.
* `project_id`: Optional. The Google Cloud project ID. Overrides `default_project_id`.
* `gcp_oracle_zone`: Optional. The GCP Oracle zone. Overrides `default_gcp_oracle_zone`.
* `labels`: Optional. Labels for the ODB network.
* `deletion_protection`: Optional. Whether deletion protection is enabled. Overrides `default_deletion_protection`.
* `timeouts`: Optional. Provider timeout overrides for `create`, `update`, and `delete`.

Provider resource: `google_oracle_database_odb_network`.

### ODB Subnets

* `gcp_odb_subnets_configuration`: Map of ODB subnets to create.

Each map value has these attributes:

* `odb_subnet_id`: Required. The ODB subnet ID.
* `cidr_range`: Required. The CIDR range for the ODB subnet.
* `purpose`: Required. The subnet purpose. Accepted values are `CLIENT_SUBNET` and `BACKUP_SUBNET`.
* `odbnetwork`: Optional. The ODB network ID segment, for example `my-odb-network`. Mutually exclusive with `odb_network_key`.
* `odb_network_key`: Optional. Key of an ODB network created by this module or supplied in `gcp_odb_networks_dependency`. Mutually exclusive with `odbnetwork`.
* `location`: Optional. The Google Cloud region. Overrides `default_location`.
* `project_id`: Optional. The Google Cloud project ID. Overrides `default_project_id`.
* `labels`: Optional. Labels for the ODB subnet.
* `deletion_protection`: Optional. Whether deletion protection is enabled. Overrides `default_deletion_protection`.
* `timeouts`: Optional. Provider timeout overrides for `create`, `update`, and `delete`.

Provider resource: `google_oracle_database_odb_subnet`.

### Cloud Exadata Infrastructures

* `gcp_cloud_exadata_infrastructures_configuration`: Map of Cloud Exadata Infrastructures to create.

Each map value has these attributes:

* `cloud_exadata_infrastructure_id`: Required. The Cloud Exadata Infrastructure ID.
* `display_name`: Optional. Display name of the Exadata infrastructure.
* `location`: Optional. The Google Cloud region. Overrides `default_location`.
* `project_id`: Optional. The Google Cloud project ID. Overrides `default_project_id`.
* `gcp_oracle_zone`: Optional. The GCP Oracle zone. Overrides `default_gcp_oracle_zone`.
* `labels`: Optional. Labels for the Exadata infrastructure.
* `deletion_protection`: Optional. Whether deletion protection is enabled. Overrides `default_deletion_protection`.
* `timeouts`: Optional. Provider timeout overrides for `create`, `update`, and `delete`.
* `properties`: Required. Exadata infrastructure properties.

The `properties` object has these attributes:

* `shape`: Required. Shape of the Exadata infrastructure.
* `compute_count`: Optional. Compute count of the Exadata infrastructure.
* `storage_count`: Optional. Storage count of the Exadata infrastructure.
* `total_storage_size_gb`: Optional. Total storage size in GB.
* `customer_contacts`: Optional. Customer contact information.
* `maintenance_window`: Optional. Maintenance window configuration.

If `maintenance_window` is not set, the module uses `default_cloud_exadata_maintenance_window` when provided.

Each `customer_contacts` object has these attributes:

* `email`: Required. Customer contact email address.

The `maintenance_window` object has these attributes:

* `preference`: Optional. Maintenance window preference.
* `months`: Optional. Maintenance months.
* `weeks_of_month`: Optional. Maintenance weeks of the month.
* `days_of_week`: Optional. Maintenance days of the week.
* `hours_of_day`: Optional. Maintenance hours of the day.
* `lead_time_week`: Optional. Lead time in weeks.
* `patching_mode`: Optional. Patching mode.
* `custom_action_timeout_mins`: Optional. Custom action timeout in minutes.
* `is_custom_action_timeout_enabled`: Optional. Whether custom action timeout is enabled.

The module intentionally ignores Terraform drift for selected Cloud Exadata Infrastructure capacity fields. These values can change after Oracle-managed maintenance or after operations performed through the OCI control plane in dual control-plane deployments. Ignoring them prevents a later Google provider plan from rolling back capacity or storage changes made outside this module.

Ignored Cloud Exadata Infrastructure fields:

* `properties[0].compute_count`
* `properties[0].storage_count`
* `properties[0].total_storage_size_gb`

The policy is deliberately limited to capacity and storage fields that are likely to drift when Google and OCI control planes are both used. Maintenance windows, customer contacts, labels, and computed-only version/status fields remain visible to Terraform.

Provider resource: `google_oracle_database_cloud_exadata_infrastructure`.

### Cloud VM Clusters

* `gcp_cloud_vm_clusters_configuration`: Map of Cloud VM Clusters to create.

Each map value has these attributes:

* `cloud_vm_cluster_id`: Required. The Cloud VM Cluster ID.
* `display_name`: Optional. Display name of the VM cluster.
* `location`: Optional. The Google Cloud region. Overrides `default_location`.
* `project_id`: Optional. The Google Cloud project ID. Overrides `default_project_id`.
* `labels`: Optional. Labels for the VM cluster.
* `deletion_protection`: Optional. Whether deletion protection is enabled. Overrides `default_deletion_protection`.
* `timeouts`: Optional. Provider timeout overrides for `create`, `update`, and `delete`.
* `exadata_infrastructure`: Optional. The Exadata infrastructure full resource name in `projects/{project}/locations/{region}/cloudExadataInfrastructures/{cloud_exadata_infrastructure}` format.
* `exadata_infrastructure_key`: Optional. Key of an Exadata infrastructure created by this module or supplied in `gcp_cloud_exadata_infrastructures_dependency`.
* `odb_network`: Optional. The ODB network full resource name in `projects/{project}/locations/{location}/odbNetworks/{odb_network}` format.
* `odb_network_key`: Optional. Key of an ODB network created by this module or supplied in `gcp_odb_networks_dependency`.
* `odb_subnet`: Optional. Client ODB subnet full resource name in `projects/{project}/locations/{location}/odbNetworks/{odb_network}/odbSubnets/{odb_subnet}` format.
* `odb_subnet_key`: Optional. Key of a client ODB subnet created by this module or supplied in `gcp_odb_subnets_dependency`.
* `backup_odb_subnet`: Optional. Backup ODB subnet full resource name in `projects/{project}/locations/{location}/odbNetworks/{odb_network}/odbSubnets/{odb_subnet}` format.
* `backup_odb_subnet_key`: Optional. Key of a backup ODB subnet created by this module or supplied in `gcp_odb_subnets_dependency`.
* `properties`: Required. VM cluster properties.

Each VM cluster must set exactly one Exadata reference: `exadata_infrastructure` or `exadata_infrastructure_key`. It must also set exactly one ODB network reference, one client ODB subnet reference, and one backup ODB subnet reference through direct values or keys. This module intentionally exposes only ODB subnet mode for new environments. When using keys, `odb_subnet_key` must point to a subnet with purpose `CLIENT_SUBNET`, and `backup_odb_subnet_key` must point to a subnet with purpose `BACKUP_SUBNET` when purpose is known. When the parent ODB Network segment is known, both subnet keys must belong to the selected ODB Network.

The module intentionally ignores Terraform drift for selected VM cluster fields that can change during Oracle-managed maintenance or during operations performed through the OCI control plane in dual control-plane deployments. This prevents a later Google provider plan from trying to roll back patch, shape, capacity, storage, backup, or database server placement changes made outside this module.

Ignored VM cluster fields:

* `properties[0].gi_version`
* `properties[0].db_server_ocids`
* `properties[0].cpu_core_count`
* `properties[0].node_count`
* `properties[0].ocpu_count`
* `properties[0].memory_size_gb`
* `properties[0].db_node_storage_size_gb`
* `properties[0].data_storage_size_tb`
* `properties[0].local_backup_enabled`
* `properties[0].sparse_diskgroup_enabled`
* `properties[0].disk_redundancy`

The policy is deliberately limited to operational fields that are likely to drift when Google and OCI control planes are both used. Labels remain managed by Terraform. Computed-only system attributes such as `system_version`, `scan_listener_port_tcp`, and `scan_listener_port_tcp_ssl` are also not ignored because they are not Terraform inputs.

The `properties` object has these attributes:

* `license_type`: Required. License type of the VM cluster.
* `cpu_core_count`: Required. CPU core count of the VM cluster. Must be at least 4.
* `gi_version`: Optional. Grid Infrastructure version.
* `ssh_public_keys`: Optional. RSA SSH public keys for the VM cluster in OpenSSH format, for example `ssh-rsa <base64> user@example.com`.
* `node_count`: Optional. Node count of the VM cluster. Must be at least 2 when set.
* `ocpu_count`: Optional. OCPU count of the VM cluster.
* `memory_size_gb`: Optional. Memory size in GB. Must be at least 60 when set.
* `db_node_storage_size_gb`: Optional. DB node storage size in GB. Must be at least 120 when set.
* `data_storage_size_tb`: Optional. Data storage size in TB. Must be at least 2 when set.
* `disk_redundancy`: Optional. Disk redundancy setting.
* `sparse_diskgroup_enabled`: Optional. Whether sparse diskgroup is enabled.
* `local_backup_enabled`: Optional. Whether local backup is enabled.
* `hostname_prefix`: Optional. Hostname prefix.
* `db_server_ocids`: Optional. Database server OCIDs for explicit VM placement. When set, values must be DB server OCIDs and the list must include at least one OCID per requested `node_count`; some service configurations require this field instead of accepting server-side placement.
* `cluster_name`: Optional. Cluster name.
* `time_zone`: Optional. Time zone configuration.
* `diagnostics_data_collection_options`: Optional. Diagnostics data collection options.

The `time_zone` object has these attributes:

* `id`: Optional. Time zone ID.
* `version`: Optional. Time zone version.

The `diagnostics_data_collection_options` object has these attributes:

* `diagnostics_events_enabled`: Optional. Whether diagnostic events collection is enabled.
* `health_monitoring_enabled`: Optional. Whether health monitoring is enabled.
* `incident_logs_enabled`: Optional. Whether incident log collection is enabled.

Provider resource: `google_oracle_database_cloud_vm_cluster`.

## Module Outputs

The module returns these outputs:

* `module_name`: The module instance name.
* `gcp_odb_networks`: Created ODB networks, keyed by input key.
* `gcp_odb_subnets`: Created ODB subnets, keyed by input key.
* `gcp_cloud_exadata_infrastructures`: Created Exadata infrastructures, keyed by input key.
* `gcp_cloud_vm_clusters`: Created Exadata VM clusters, keyed by input key.

Each resource output includes stable identifiers and selected computed attributes exported by the Google provider. Exadata Infrastructure outputs include server versions and storage activation counts. VM Cluster outputs include Grid Infrastructure version, cluster identity, placement, capacity, SCAN details, backup and disk redundancy settings, OCI metadata, and lifecycle state. Outputs are disabled when `enable_output` is set to `false`.
