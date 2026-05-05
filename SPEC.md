# Oracle Database@Google Cloud Terraform Module Specification

## Table of Contents

1. Overview
2. Pre-requisites
3. Module Inputs
4. ODB Networks
5. ODB Subnets
6. Cloud Exadata Infrastructures
7. Cloud VM Clusters
8. Module Outputs
9. OCI Landing Zones Modules Collection
10. Contributing
11. License
12. Known Issues

## Overview

This repository contains a Terraform module for Oracle Database@Google Cloud resources managed through the HashiCorp Google provider.

The following resources are available:

* ODB Network
* ODB Subnet
* Cloud Exadata Infrastructure
* Cloud VM Cluster

This module follows the OCI Landing Zones module style. Callers provide keyed configuration maps, Terraform creates resources with `for_each`, and outputs are returned with the same keys so downstream stacks can consume created resource identifiers without copying generated values by hand.

The module supports two reference patterns for related resources:

* A literal provider resource name or ID can be passed directly.
* A key can be passed to reference another resource created by this module.

For example, a VM cluster can use `exadata_infrastructure_key` to reference an Exadata infrastructure created in `gcp_cloud_exadata_infrastructures_configuration`, and `odb_subnet_key` or `backup_odb_subnet_key` to reference subnets created in `gcp_odb_subnets_configuration`.

## Pre-requisites

Before deploying Oracle Database@Google Cloud resources, ensure the following prerequisites are met:

* Google Cloud project

  A Google Cloud project must exist and must be enabled for Oracle Database@Google Cloud.

* IAM permissions

  The caller must have permissions to create and manage Oracle Database@Google Cloud resources and to reference the target VPC network.

* Google provider authentication

  Google Cloud credentials must be configured for Terraform through one of the supported Google provider authentication methods.

* VPC network

  An existing Google Cloud VPC network is required for ODB network creation.

* ODB network and subnets

  VM clusters can use either Google VPC CIDR arguments or ODB network/subnet resource names. When using ODB subnets, provide both a client subnet and a backup subnet.

* Oracle Database@Google Cloud entitlement

  The target project and region must have the required Oracle Database@Google Cloud entitlement.

## Module Inputs

The module accepts the following input variables.

### General

* `module_name`: The module name. Defaults to `oracle-database-at-gcp`.
* `enable_output`: Whether Terraform should enable module output. Defaults to `true`.
* `default_project_id`: Default Google Cloud project ID used by resources when `project_id` is not set on the resource.
* `default_location`: Default Google Cloud region used by resources when `location` is not set on the resource.
* `default_gcp_oracle_zone`: Default GCP Oracle zone used by resources that support it.
* `default_labels`: Default labels merged into all resources. Resource-specific labels win on key collisions.
* `default_deletion_protection`: Default deletion protection value for resources that support `deletion_protection`. Defaults to `true`.

### ODB Networks

* `gcp_odb_networks_configuration`: ODB network configuration. This is a map of ODB network configurations.

Each ODB network configuration object has the following attributes:

* `odb_network_id`: Required. The ODB network ID.
* `network`: Required. The Google Cloud VPC network resource name.
* `location`: Optional. The Google Cloud region. Overrides `default_location`.
* `project_id`: Optional. The Google Cloud project ID. Overrides `default_project_id`.
* `gcp_oracle_zone`: Optional. The GCP Oracle zone. Overrides `default_gcp_oracle_zone`.
* `labels`: Optional. Labels for the ODB network.
* `deletion_protection`: Optional. Whether deletion protection is enabled. Overrides `default_deletion_protection`.

For more details on this resource, please see Google Terraform provider documentation for `google_oracle_database_odb_network`.

### ODB Subnets

* `gcp_odb_subnets_configuration`: ODB subnet configuration. This is a map of ODB subnet configurations.

Each ODB subnet configuration object has the following attributes:

* `odb_subnet_id`: Required. The ODB subnet ID.
* `cidr_range`: Required. The CIDR range for the ODB subnet.
* `purpose`: Required. The subnet purpose. Accepted values are `CLIENT_SUBNET` and `BACKUP_SUBNET`.
* `odbnetwork`: Optional. The ODB network name or ID.
* `odb_network_key`: Optional. Key of an ODB network created by this module.
* `location`: Optional. The Google Cloud region. Overrides `default_location`.
* `project_id`: Optional. The Google Cloud project ID. Overrides `default_project_id`.
* `labels`: Optional. Labels for the ODB subnet.
* `deletion_protection`: Optional. Whether deletion protection is enabled. Overrides `default_deletion_protection`.

For more details on this resource, please see Google Terraform provider documentation for `google_oracle_database_odb_subnet`.

### Cloud Exadata Infrastructures

* `gcp_cloud_exadata_infrastructures_configuration`: Exadata infrastructure configuration. This is a map of Exadata infrastructure configurations.

Each Cloud Exadata Infrastructure configuration object has the following attributes:

* `cloud_exadata_infrastructure_id`: Required. The Cloud Exadata Infrastructure ID.
* `display_name`: Optional. Display name of the Exadata infrastructure.
* `location`: Optional. The Google Cloud region. Overrides `default_location`.
* `project_id`: Optional. The Google Cloud project ID. Overrides `default_project_id`.
* `gcp_oracle_zone`: Optional. The GCP Oracle zone. Overrides `default_gcp_oracle_zone`.
* `labels`: Optional. Labels for the Exadata infrastructure.
* `deletion_protection`: Optional. Whether deletion protection is enabled. Overrides `default_deletion_protection`.
* `properties`: Required. Exadata infrastructure properties.

The `properties` object has the following attributes:

* `shape`: Required. Shape of the Exadata infrastructure.
* `compute_count`: Optional. Compute count of the Exadata infrastructure.
* `storage_count`: Optional. Storage count of the Exadata infrastructure.
* `total_storage_size_gb`: Optional. Total storage size in GB.
* `customer_contacts`: Optional. Customer contact information.
* `maintenance_window`: Optional. Maintenance window configuration.

Each `customer_contacts` object has the following attributes:

* `email`: Required. Customer contact email address.

The `maintenance_window` object has the following attributes:

* `preference`: Optional. Maintenance window preference.
* `months`: Optional. Maintenance months.
* `weeks_of_month`: Optional. Maintenance weeks of the month.
* `days_of_week`: Optional. Maintenance days of the week.
* `hours_of_day`: Optional. Maintenance hours of the day.
* `lead_time_week`: Optional. Lead time in weeks.
* `patching_mode`: Optional. Patching mode.
* `custom_action_timeout_mins`: Optional. Custom action timeout in minutes.
* `is_custom_action_timeout_enabled`: Optional. Whether custom action timeout is enabled.

For more details on this resource, please see Google Terraform provider documentation for `google_oracle_database_cloud_exadata_infrastructure`.

### Cloud VM Clusters

* `gcp_cloud_vm_clusters_configuration`: Cloud VM cluster configuration. This is a map of VM cluster configurations.

Each Cloud VM cluster configuration object has the following attributes:

* `cloud_vm_cluster_id`: Required. The Cloud VM Cluster ID.
* `display_name`: Optional. Display name of the VM cluster.
* `location`: Optional. The Google Cloud region. Overrides `default_location`.
* `project_id`: Optional. The Google Cloud project ID. Overrides `default_project_id`.
* `labels`: Optional. Labels for the VM cluster.
* `deletion_protection`: Optional. Whether deletion protection is enabled. Overrides `default_deletion_protection`.
* `exadata_infrastructure`: Optional. The Exadata infrastructure resource name or ID.
* `exadata_infrastructure_key`: Optional. Key of an Exadata infrastructure created by this module.
* `network`: Optional. The Google Cloud VPC network resource name.
* `cidr`: Optional. Client subnet CIDR when using VPC CIDR arguments.
* `backup_subnet_cidr`: Optional. Backup subnet CIDR when using VPC CIDR arguments.
* `odb_network`: Optional. The ODB network resource name or ID.
* `odb_network_key`: Optional. Key of an ODB network created by this module.
* `odb_subnet`: Optional. Client ODB subnet resource name or ID.
* `odb_subnet_key`: Optional. Key of a client ODB subnet created by this module.
* `backup_odb_subnet`: Optional. Backup ODB subnet resource name or ID.
* `backup_odb_subnet_key`: Optional. Key of a backup ODB subnet created by this module.
* `properties`: Required. VM cluster properties.

The `properties` object has the following attributes:

* `license_type`: Required. License type of the VM cluster.
* `cpu_core_count`: Required. CPU core count of the VM cluster.
* `gi_version`: Optional. Grid Infrastructure version.
* `ssh_public_keys`: Optional. SSH public keys for the VM cluster.
* `node_count`: Optional. Node count of the VM cluster.
* `ocpu_count`: Optional. OCPU count of the VM cluster.
* `memory_size_gb`: Optional. Memory size in GB.
* `db_node_storage_size_gb`: Optional. DB node storage size in GB.
* `data_storage_size_tb`: Optional. Data storage size in TB.
* `disk_redundancy`: Optional. Disk redundancy setting.
* `sparse_diskgroup_enabled`: Optional. Whether sparse diskgroup is enabled.
* `local_backup_enabled`: Optional. Whether local backup is enabled.
* `hostname_prefix`: Optional. Hostname prefix.
* `db_server_ocids`: Optional. Database server OCIDs.
* `cluster_name`: Optional. Cluster name.
* `scan_listener_port_tcp`: Optional. SCAN listener TCP port.
* `scan_listener_port_tcp_ssl`: Optional. SCAN listener TCP SSL port.
* `time_zone`: Optional. Time zone configuration.
* `diagnostics_data_collection_options`: Optional. Diagnostics data collection options.

The `time_zone` object has the following attributes:

* `id`: Optional. Time zone ID.
* `version`: Optional. Time zone version.

The `diagnostics_data_collection_options` object has the following attributes:

* `diagnostics_events_enabled`: Optional. Whether diagnostic events collection is enabled.
* `health_monitoring_enabled`: Optional. Whether health monitoring is enabled.
* `incident_logs_enabled`: Optional. Whether incident log collection is enabled.

For more details on this resource, please see Google Terraform provider documentation for `google_oracle_database_cloud_vm_cluster`.

## Module Outputs

The module provides the following outputs:

* `module_name`: The module instance name.
* `gcp_odb_networks`: Created ODB networks, keyed by input key.
* `gcp_odb_subnets`: Created ODB subnets, keyed by input key.
* `gcp_cloud_exadata_infrastructures`: Created Exadata infrastructures, keyed by input key.
* `gcp_cloud_vm_clusters`: Created Exadata VM clusters, keyed by input key.

Each resource output includes stable identifiers and selected computed attributes exported by the Google provider. Outputs are disabled when `enable_output` is set to `false`.

## OCI Landing Zones Modules Collection

This module follows the conventions used by OCI Landing Zones modules:

* Resource configuration is expressed as typed Terraform objects.
* Repeated resources are declared as maps and created with `for_each`.
* Resource outputs are keyed by the same logical keys provided in the input maps.
* Downstream stacks can consume module outputs instead of copying generated resource identifiers.

The same pattern can be used to compose Oracle Database@Google Cloud resources with other independently managed infrastructure stacks.

## Contributing

See `CONTRIBUTING.md` if present in this repository.

## License

Copyright (c) 2026, Oracle and/or its affiliates.

Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

See `LICENSE` for more details if present in this repository.

## Known Issues

1. Oracle Database@Google Cloud resources can take a long time to provision. If `terraform apply` is interrupted, run `terraform apply` again and Terraform will continue from the current state.
2. VM cluster creation requires valid networking inputs. When using ODB subnets, provide both client and backup subnet references through direct values or module keys.
3. Some resource attributes are service-managed and become available only after provisioning completes. Downstream stacks should consume outputs after the producing stack has completed successfully.
