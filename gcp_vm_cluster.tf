# Copyright (c) 2026, Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

resource "google_oracle_database_cloud_vm_cluster" "these" {
  for_each = var.gcp_cloud_vm_clusters_configuration

  cloud_vm_cluster_id = each.value.cloud_vm_cluster_id
  display_name        = each.value.display_name
  location            = try(coalesce(each.value.location, var.default_location), null)
  project             = try(coalesce(each.value.project_id, var.default_project_id), null)

  exadata_infrastructure = try(coalesce(
    each.value.exadata_infrastructure,
    each.value.exadata_infrastructure_key == null ? null : google_oracle_database_cloud_exadata_infrastructure.these[each.value.exadata_infrastructure_key].id
  ), null)

  network            = each.value.network
  cidr               = each.value.cidr
  backup_subnet_cidr = each.value.backup_subnet_cidr

  odb_network = try(coalesce(
    each.value.odb_network,
    each.value.odb_network_key == null ? null : google_oracle_database_odb_network.these[each.value.odb_network_key].id
  ), null)
  odb_subnet = try(coalesce(
    each.value.odb_subnet,
    each.value.odb_subnet_key == null ? null : google_oracle_database_odb_subnet.these[each.value.odb_subnet_key].id
  ), null)
  backup_odb_subnet = try(coalesce(
    each.value.backup_odb_subnet,
    each.value.backup_odb_subnet_key == null ? null : google_oracle_database_odb_subnet.these[each.value.backup_odb_subnet_key].id
  ), null)

  labels              = merge(local.default_labels, each.value.labels)
  deletion_protection = try(coalesce(each.value.deletion_protection, var.default_deletion_protection), null)

  properties {
    license_type               = each.value.properties.license_type
    gi_version                 = each.value.properties.gi_version
    ssh_public_keys            = each.value.properties.ssh_public_keys
    node_count                 = each.value.properties.node_count
    ocpu_count                 = each.value.properties.ocpu_count
    memory_size_gb             = each.value.properties.memory_size_gb
    db_node_storage_size_gb    = each.value.properties.db_node_storage_size_gb
    data_storage_size_tb       = each.value.properties.data_storage_size_tb
    disk_redundancy            = each.value.properties.disk_redundancy
    sparse_diskgroup_enabled   = each.value.properties.sparse_diskgroup_enabled
    local_backup_enabled       = each.value.properties.local_backup_enabled
    hostname_prefix            = each.value.properties.hostname_prefix
    cpu_core_count             = each.value.properties.cpu_core_count
    db_server_ocids            = each.value.properties.db_server_ocids
    cluster_name               = each.value.properties.cluster_name
    scan_listener_port_tcp     = each.value.properties.scan_listener_port_tcp
    scan_listener_port_tcp_ssl = each.value.properties.scan_listener_port_tcp_ssl

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
}
