# Copyright (c) 2026, Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

provider "google" {
  project = var.project_id
  region  = var.location
}

data "google_oracle_database_db_servers" "available" {
  count = var.db_server_ocids == null ? 1 : 0

  project                      = var.project_id
  location                     = var.location
  cloud_exadata_infrastructure = basename(var.exadata_infrastructure)
}

locals {
  discovered_db_server_ocids = var.db_server_ocids == null ? [
    for server in data.google_oracle_database_db_servers.available[0].db_servers :
    server.properties[0].ocid
    if try(server.properties[0].state, null) == "AVAILABLE"
  ] : []

  resolved_db_server_ocids = var.db_server_ocids != null ? var.db_server_ocids : slice(
    local.discovered_db_server_ocids,
    0,
    min(length(local.discovered_db_server_ocids), var.node_count)
  )
}

module "oracle_database_at_gcp" {
  source = "../.."

  default_project_id          = var.project_id
  default_location            = var.location
  default_deletion_protection = var.deletion_protection
  default_labels              = var.labels

  gcp_odb_networks_configuration                  = {}
  gcp_odb_subnets_configuration                   = {}
  gcp_cloud_exadata_infrastructures_configuration = {}

  gcp_odb_networks_dependency = var.gcp_odb_networks_dependency
  gcp_odb_subnets_dependency  = var.gcp_odb_subnets_dependency
  gcp_cloud_exadata_infrastructures_dependency = {
    primary = {
      id = var.exadata_infrastructure
    }
  }

  gcp_cloud_vm_clusters_configuration = {
    primary = {
      cloud_vm_cluster_id        = var.cloud_vm_cluster_id
      display_name               = coalesce(var.display_name, var.cloud_vm_cluster_id)
      exadata_infrastructure_key = "primary"
      odb_network_key            = var.odb_network_key
      odb_subnet_key             = var.odb_subnet_key
      backup_odb_subnet_key      = var.backup_odb_subnet_key
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
        db_server_ocids          = local.resolved_db_server_ocids

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
