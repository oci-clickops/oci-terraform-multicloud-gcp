# Copyright (c) 2026, Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

resource "google_oracle_database_cloud_vm_cluster" "these" {
  for_each = var.gcp_cloud_vm_clusters_configuration

  cloud_vm_cluster_id = each.value.cloud_vm_cluster_id
  display_name        = each.value.display_name
  location            = each.value.location != null ? each.value.location : var.default_location
  project             = each.value.project_id != null ? each.value.project_id : var.default_project_id

  exadata_infrastructure = each.value.exadata_infrastructure != null ? each.value.exadata_infrastructure : (each.value.exadata_infrastructure_key != null ? google_oracle_database_cloud_exadata_infrastructure.these[each.value.exadata_infrastructure_key].id : null)

  odb_network       = each.value.odb_network != null ? each.value.odb_network : (each.value.odb_network_key != null ? google_oracle_database_odb_network.these[each.value.odb_network_key].id : null)
  odb_subnet        = each.value.odb_subnet != null ? each.value.odb_subnet : (each.value.odb_subnet_key != null ? google_oracle_database_odb_subnet.these[each.value.odb_subnet_key].id : null)
  backup_odb_subnet = each.value.backup_odb_subnet != null ? each.value.backup_odb_subnet : (each.value.backup_odb_subnet_key != null ? google_oracle_database_odb_subnet.these[each.value.backup_odb_subnet_key].id : null)

  labels              = merge(local.default_labels, each.value.labels)
  deletion_protection = each.value.deletion_protection != null ? each.value.deletion_protection : var.default_deletion_protection

  properties {
    license_type             = each.value.properties.license_type
    gi_version               = each.value.properties.gi_version
    ssh_public_keys          = each.value.properties.ssh_public_keys
    node_count               = each.value.properties.node_count
    ocpu_count               = each.value.properties.ocpu_count
    memory_size_gb           = each.value.properties.memory_size_gb
    db_node_storage_size_gb  = each.value.properties.db_node_storage_size_gb
    data_storage_size_tb     = each.value.properties.data_storage_size_tb
    disk_redundancy          = each.value.properties.disk_redundancy
    sparse_diskgroup_enabled = each.value.properties.sparse_diskgroup_enabled
    local_backup_enabled     = each.value.properties.local_backup_enabled
    hostname_prefix          = each.value.properties.hostname_prefix
    cpu_core_count           = each.value.properties.cpu_core_count
    db_server_ocids          = each.value.properties.db_server_ocids
    cluster_name             = each.value.properties.cluster_name

    dynamic "time_zone" {
      for_each = each.value.properties.time_zone == null ? [] : [each.value.properties.time_zone]

      content {
        id      = time_zone.value.id
        version = time_zone.value.version
      }
    }

    dynamic "diagnostics_data_collection_options" {
      for_each = each.value.properties.diagnostics_data_collection_options == null ? [] : [each.value.properties.diagnostics_data_collection_options]

      content {
        diagnostics_events_enabled = diagnostics_data_collection_options.value.diagnostics_events_enabled
        health_monitoring_enabled  = diagnostics_data_collection_options.value.health_monitoring_enabled
        incident_logs_enabled      = diagnostics_data_collection_options.value.incident_logs_enabled
      }
    }
  }

  dynamic "timeouts" {
    for_each = each.value.timeouts == null ? [] : [each.value.timeouts]

    content {
      create = timeouts.value.create
      update = timeouts.value.update
      delete = timeouts.value.delete
    }
  }

  lifecycle {
    ignore_changes = [
      properties[0].cpu_core_count,
      properties[0].data_storage_size_tb,
      properties[0].db_node_storage_size_gb,
      properties[0].db_server_ocids,
      properties[0].disk_redundancy,
      properties[0].gi_version,
      properties[0].local_backup_enabled,
      properties[0].memory_size_gb,
      properties[0].node_count,
      properties[0].ocpu_count,
      properties[0].sparse_diskgroup_enabled,
    ]

    precondition {
      condition     = each.value.location != null || var.default_location != null
      error_message = "Each Cloud VM cluster must set location or default_location."
    }

    precondition {
      condition     = (each.value.exadata_infrastructure != null ? 1 : 0) + (each.value.exadata_infrastructure_key != null ? 1 : 0) == 1
      error_message = "Each Cloud VM cluster must set exactly one Exadata infrastructure reference: exadata_infrastructure or exadata_infrastructure_key."
    }

    precondition {
      condition     = each.value.exadata_infrastructure_key == null || contains(keys(var.gcp_cloud_exadata_infrastructures_configuration), each.value.exadata_infrastructure_key)
      error_message = "Each Cloud VM cluster exadata_infrastructure_key must reference a key in gcp_cloud_exadata_infrastructures_configuration."
    }

    precondition {
      condition = (
        (each.value.odb_network != null ? 1 : 0) + (each.value.odb_network_key != null ? 1 : 0) == 1 &&
        (each.value.odb_subnet != null ? 1 : 0) + (each.value.odb_subnet_key != null ? 1 : 0) == 1 &&
        (each.value.backup_odb_subnet != null ? 1 : 0) + (each.value.backup_odb_subnet_key != null ? 1 : 0) == 1
      )
      error_message = "Each Cloud VM cluster must set exactly one ODB network reference, one client ODB subnet reference, and one backup ODB subnet reference."
    }

    precondition {
      condition     = each.value.odb_network_key == null || contains(keys(var.gcp_odb_networks_configuration), each.value.odb_network_key)
      error_message = "Each Cloud VM cluster odb_network_key must reference a key in gcp_odb_networks_configuration."
    }

    precondition {
      condition     = each.value.odb_subnet_key == null || contains(keys(var.gcp_odb_subnets_configuration), each.value.odb_subnet_key)
      error_message = "Each Cloud VM cluster odb_subnet_key must reference a key in gcp_odb_subnets_configuration."
    }

    precondition {
      condition     = each.value.backup_odb_subnet_key == null || contains(keys(var.gcp_odb_subnets_configuration), each.value.backup_odb_subnet_key)
      error_message = "Each Cloud VM cluster backup_odb_subnet_key must reference a key in gcp_odb_subnets_configuration."
    }

    precondition {
      condition = each.value.odb_network_key == null ? true : (
        each.value.odb_subnet_key == null ? true : (
          contains(keys(var.gcp_odb_networks_configuration), each.value.odb_network_key) ? (
            contains(keys(var.gcp_odb_subnets_configuration), each.value.odb_subnet_key) ? (
              var.gcp_odb_subnets_configuration[each.value.odb_subnet_key].odb_network_key == each.value.odb_network_key ||
              var.gcp_odb_subnets_configuration[each.value.odb_subnet_key].odbnetwork == var.gcp_odb_networks_configuration[each.value.odb_network_key].odb_network_id
            ) : true
          ) : true
        )
      )
      error_message = "Each Cloud VM cluster odb_subnet_key must belong to the ODB network selected by odb_network_key."
    }

    precondition {
      condition = each.value.odb_network_key == null ? true : (
        each.value.backup_odb_subnet_key == null ? true : (
          contains(keys(var.gcp_odb_networks_configuration), each.value.odb_network_key) ? (
            contains(keys(var.gcp_odb_subnets_configuration), each.value.backup_odb_subnet_key) ? (
              var.gcp_odb_subnets_configuration[each.value.backup_odb_subnet_key].odb_network_key == each.value.odb_network_key ||
              var.gcp_odb_subnets_configuration[each.value.backup_odb_subnet_key].odbnetwork == var.gcp_odb_networks_configuration[each.value.odb_network_key].odb_network_id
            ) : true
          ) : true
        )
      )
      error_message = "Each Cloud VM cluster backup_odb_subnet_key must belong to the ODB network selected by odb_network_key."
    }

    precondition {
      condition     = each.value.odb_subnet_key == null ? true : (contains(keys(var.gcp_odb_subnets_configuration), each.value.odb_subnet_key) ? var.gcp_odb_subnets_configuration[each.value.odb_subnet_key].purpose == "CLIENT_SUBNET" : true)
      error_message = "Each Cloud VM cluster odb_subnet_key must reference an ODB subnet with purpose CLIENT_SUBNET."
    }

    precondition {
      condition     = each.value.backup_odb_subnet_key == null ? true : (contains(keys(var.gcp_odb_subnets_configuration), each.value.backup_odb_subnet_key) ? var.gcp_odb_subnets_configuration[each.value.backup_odb_subnet_key].purpose == "BACKUP_SUBNET" : true)
      error_message = "Each Cloud VM cluster backup_odb_subnet_key must reference an ODB subnet with purpose BACKUP_SUBNET."
    }
  }
}
