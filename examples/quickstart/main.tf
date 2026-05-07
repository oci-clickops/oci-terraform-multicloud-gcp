# Copyright (c) 2026, Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

provider "google" {
  project = var.project_id
  region  = var.location
}

module "oracle_database_at_gcp" {
  source = "../.."

  default_project_id          = var.project_id
  default_location            = var.location
  default_gcp_oracle_zone     = var.gcp_oracle_zone
  default_deletion_protection = var.deletion_protection
  default_labels              = var.labels

  default_cloud_exadata_maintenance_window = var.exadata_maintenance_window

  gcp_odb_networks_configuration = {
    primary = {
      odb_network_id      = var.odb_network_id
      network             = var.network
      location            = var.odb_network_location
      project_id          = var.odb_network_project_id
      gcp_oracle_zone     = var.odb_network_gcp_oracle_zone
      labels              = var.odb_network_labels
      deletion_protection = var.odb_network_deletion_protection
      timeouts            = var.odb_network_timeouts
    }
  }

  gcp_odb_subnets_configuration = {
    client = {
      odb_subnet_id       = var.client_odb_subnet_id
      odb_network_key     = "primary"
      cidr_range          = var.client_odb_subnet_cidr_range
      purpose             = "CLIENT_SUBNET"
      location            = var.client_odb_subnet_location
      project_id          = var.client_odb_subnet_project_id
      labels              = var.client_odb_subnet_labels
      deletion_protection = var.client_odb_subnet_deletion_protection
      timeouts            = var.client_odb_subnet_timeouts
    }
    backup = {
      odb_subnet_id       = var.backup_odb_subnet_id
      odb_network_key     = "primary"
      cidr_range          = var.backup_odb_subnet_cidr_range
      purpose             = "BACKUP_SUBNET"
      location            = var.backup_odb_subnet_location
      project_id          = var.backup_odb_subnet_project_id
      labels              = var.backup_odb_subnet_labels
      deletion_protection = var.backup_odb_subnet_deletion_protection
      timeouts            = var.backup_odb_subnet_timeouts
    }
  }

  gcp_cloud_exadata_infrastructures_configuration = {
    primary = {
      cloud_exadata_infrastructure_id = var.cloud_exadata_infrastructure_id
      display_name                    = coalesce(var.cloud_exadata_infrastructure_display_name, var.cloud_exadata_infrastructure_id)
      location                        = var.cloud_exadata_infrastructure_location
      project_id                      = var.cloud_exadata_infrastructure_project_id
      gcp_oracle_zone                 = var.cloud_exadata_infrastructure_gcp_oracle_zone
      labels                          = var.cloud_exadata_infrastructure_labels
      deletion_protection             = var.cloud_exadata_infrastructure_deletion_protection
      timeouts                        = var.cloud_exadata_infrastructure_timeouts
      properties = {
        shape                 = var.exadata_shape
        compute_count         = var.compute_count
        storage_count         = var.storage_count
        total_storage_size_gb = var.total_storage_size_gb
        customer_contacts     = var.customer_contacts
        maintenance_window    = var.exadata_maintenance_window
      }
    }
  }

  gcp_cloud_vm_clusters_configuration = {
    primary = {
      cloud_vm_cluster_id        = var.cloud_vm_cluster_id
      display_name               = coalesce(var.display_name, var.cloud_vm_cluster_id)
      exadata_infrastructure_key = "primary"
      odb_network_key            = "primary"
      odb_subnet_key             = "client"
      backup_odb_subnet_key      = "backup"
      labels                     = var.labels
      deletion_protection        = var.deletion_protection
      timeouts                   = var.timeouts
      properties = {
        license_type             = var.license_type
        cpu_core_count           = var.cpu_core_count
        node_count               = var.node_count
        ocpu_count               = var.ocpu_count
        memory_size_gb           = var.memory_size_gb
        db_node_storage_size_gb  = var.db_node_storage_size_gb
        data_storage_size_tb     = var.data_storage_size_tb
        disk_redundancy          = var.disk_redundancy
        local_backup_enabled     = var.local_backup_enabled
        sparse_diskgroup_enabled = var.sparse_diskgroup_enabled
        cluster_name             = var.cluster_name
        gi_version               = var.gi_version
        hostname_prefix          = var.hostname_prefix
        ssh_public_keys          = var.ssh_public_keys
        db_server_ocids          = var.db_server_ocids

        time_zone = var.time_zone_id == null ? null : {
          id      = var.time_zone_id
          version = var.time_zone_version
        }

        diagnostics_data_collection_options = {
          diagnostics_events_enabled = var.diagnostics_events_enabled
          health_monitoring_enabled  = var.health_monitoring_enabled
          incident_logs_enabled      = var.incident_logs_enabled
        }
      }
    }
  }
}
