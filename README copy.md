# Oracle Database@Google Cloud Terraform Module

## Table of Contents

1. [Early Preview Disclaimer](#early-preview-disclaimer)
2. [Overview](#overview)
3. [Pre-requisites](#pre-requisites)
4. [Module Inputs](#module-inputs)
5. [ODB Networks](#odb-networks)
6. [ODB Subnets](#odb-subnets)
7. [Cloud Exadata Infrastructures](#cloud-exadata-infrastructures)
8. [Cloud VM Clusters](#cloud-vm-clusters)
9. [Example](#example)
10. [Module Outputs](#module-outputs)
11. [OCI Landing Zones Modules Collection](#oci-landing-zones-modules-collection)
12. [Contributing](#contributing)
13. [License](#license)
14. [Known Issues](#known-issues)

## Early Preview Disclaimer

This module is an early implementation for Oracle Database@Google Cloud resources. Review the generated plan carefully before applying it in production environments.

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

For the complete input contract, see [SPEC.md](./SPEC.md).

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

The module accepts the following input variables:

### General

* `module_name`: The module name. Defaults to `oracle-database-at-gcp`.
* `enable_output`: Whether Terraform should enable module output. Defaults to `true`.
* `default_project_id`: Default Google Cloud project ID used by resources when `project_id` is not set on the resource.
* `default_location`: Default Google Cloud region used by resources when `location` is not set on the resource.
* `default_gcp_oracle_zone`: Default GCP Oracle zone used by resources that support it.
* `default_labels`: Default labels merged into all resources. Resource-specific labels win on key collisions.
* `default_deletion_protection`: Default deletion protection value for resources that support `deletion_protection`. Defaults to `true`.

## ODB Networks

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

## ODB Subnets

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

## Cloud Exadata Infrastructures

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

For more details on this resource, please see Google Terraform provider documentation for `google_oracle_database_cloud_exadata_infrastructure`.

## Cloud VM Clusters

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

For more details on this resource, please see Google Terraform provider documentation for `google_oracle_database_cloud_vm_cluster`.

## Example

Within the module you can find an `examples` folder. Each example is intended to be a runnable Terraform configuration that can be adapted by changing the input data for your environment.

The basic example creates:

* One ODB network
* One client ODB subnet
* One backup ODB subnet
* One Cloud Exadata Infrastructure
* One Cloud VM Cluster

```hcl
provider "google" {
  project = var.project_id
  region  = var.location
}

module "oracle_database_at_gcp" {
  source = "../.."

  default_project_id          = var.project_id
  default_location            = var.location
  default_gcp_oracle_zone     = var.gcp_oracle_zone
  default_deletion_protection = false

  gcp_odb_networks_configuration = {
    primary = {
      odb_network_id = "primary-odb-network"
      network        = "projects/my-project/global/networks/database-vpc"
    }
  }

  gcp_odb_subnets_configuration = {
    client = {
      odb_subnet_id   = "client-subnet"
      odb_network_key = "primary"
      cidr_range      = "192.168.1.0/24"
      purpose         = "CLIENT_SUBNET"
    }
    backup = {
      odb_subnet_id   = "backup-subnet"
      odb_network_key = "primary"
      cidr_range      = "192.168.2.0/28"
      purpose         = "BACKUP_SUBNET"
    }
  }

  gcp_cloud_exadata_infrastructures_configuration = {
    primary = {
      cloud_exadata_infrastructure_id = "primary-exadata"
      display_name                    = "primary-exadata"
      properties = {
        shape         = "Exadata.X11M"
        compute_count = 2
        storage_count = 3
        customer_contacts = [
          {
            email = "dba@example.com"
          }
        ]
      }
    }
  }

  gcp_cloud_vm_clusters_configuration = {
    primary = {
      cloud_vm_cluster_id        = "primary-vm-cluster"
      display_name               = "primary-vm-cluster"
      exadata_infrastructure_key = "primary"
      odb_network_key            = "primary"
      odb_subnet_key             = "client"
      backup_odb_subnet_key      = "backup"
      properties = {
        license_type    = "LICENSE_INCLUDED"
        cpu_core_count  = 4
        gi_version      = "19.0.0.0"
        hostname_prefix = "exa"
        ssh_public_keys = [
          "ssh-rsa AAAA..."
        ]
      }
    }
  }
}
```

VM clusters can also use Google VPC CIDR arguments instead of ODB subnet resource names by setting `network`, `cidr`, and `backup_subnet_cidr`.

When using existing ODB subnets, pass `odb_subnet` and `backup_odb_subnet` directly. When creating subnets in this module, set `odb_subnet_key` and `backup_odb_subnet_key`.

## Module Outputs

The module provides the following outputs:

* `module_name`: The module instance name.
* `gcp_odb_networks`: Created ODB networks, keyed by input key.
* `gcp_odb_subnets`: Created ODB subnets, keyed by input key.
* `gcp_cloud_exadata_infrastructures`: Created Exadata infrastructures, keyed by input key.
* `gcp_cloud_vm_clusters`: Created Exadata VM clusters, keyed by input key.

Each resource output includes stable identifiers and selected computed attributes exported by the Google provider. Outputs are disabled when `enable_output` is set to `false`.

## OCI Landing Zones Modules Collection

This repository follows conventions used by the broader OCI Landing Zones module collection:

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
