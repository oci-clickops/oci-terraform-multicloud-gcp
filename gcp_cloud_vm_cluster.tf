# Copyright (c) 2026, Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
  cloud_vm_cluster_exadata_infrastructures = {
    for key, cluster in var.gcp_cloud_vm_clusters_configuration : key =>
    cluster.exadata_infrastructure != null ? cluster.exadata_infrastructure : (
      cluster.exadata_infrastructure_key == null ? null : (
        contains(keys(var.gcp_cloud_exadata_infrastructures_configuration), cluster.exadata_infrastructure_key) ? google_oracle_database_cloud_exadata_infrastructure.these[cluster.exadata_infrastructure_key].id : try(local.gcp_cloud_exadata_infrastructures_dependency[cluster.exadata_infrastructure_key].id, null)
      )
    )
  }

  cloud_vm_cluster_odb_networks = {
    for key, cluster in var.gcp_cloud_vm_clusters_configuration : key =>
    cluster.odb_network != null ? cluster.odb_network : (
      cluster.odb_network_key == null ? null : (
        contains(keys(var.gcp_odb_networks_configuration), cluster.odb_network_key) ? google_oracle_database_odb_network.these[cluster.odb_network_key].id : try(local.gcp_odb_networks_dependency[cluster.odb_network_key].id, null)
      )
    )
  }

  cloud_vm_cluster_odb_subnets = {
    for key, cluster in var.gcp_cloud_vm_clusters_configuration : key =>
    cluster.odb_subnet != null ? cluster.odb_subnet : (
      cluster.odb_subnet_key == null ? null : (
        contains(keys(var.gcp_odb_subnets_configuration), cluster.odb_subnet_key) ? google_oracle_database_odb_subnet.these[cluster.odb_subnet_key].id : try(local.gcp_odb_subnets_dependency[cluster.odb_subnet_key].id, null)
      )
    )
  }

  cloud_vm_cluster_backup_odb_subnets = {
    for key, cluster in var.gcp_cloud_vm_clusters_configuration : key =>
    cluster.backup_odb_subnet != null ? cluster.backup_odb_subnet : (
      cluster.backup_odb_subnet_key == null ? null : (
        contains(keys(var.gcp_odb_subnets_configuration), cluster.backup_odb_subnet_key) ? google_oracle_database_odb_subnet.these[cluster.backup_odb_subnet_key].id : try(local.gcp_odb_subnets_dependency[cluster.backup_odb_subnet_key].id, null)
      )
    )
  }

  cloud_vm_cluster_selected_odb_network_segments = {
    for key, cluster in var.gcp_cloud_vm_clusters_configuration : key => (
      cluster.odb_network != null ? {
        project  = try(split("/", cluster.odb_network)[1], null)
        location = try(split("/", cluster.odb_network)[3], null)
        segment  = try(split("/", cluster.odb_network)[5], null)
        } : (
        cluster.odb_network_key == null ? null : {
          project  = try(local.odb_network_project_ids[cluster.odb_network_key], null)
          location = try(local.odb_network_locations[cluster.odb_network_key], null)
          segment  = try(local.odb_network_id_segments[cluster.odb_network_key], null)
        }
      )
    )
  }

  cloud_vm_cluster_client_subnet_parent_segments = {
    for key, cluster in var.gcp_cloud_vm_clusters_configuration : key => (
      cluster.odb_subnet != null ? {
        project  = try(split("/", cluster.odb_subnet)[1], null)
        location = try(split("/", cluster.odb_subnet)[3], null)
        segment  = try(split("/", cluster.odb_subnet)[5], null)
        } : (
        cluster.odb_subnet_key == null ? null : {
          project  = try(local.odb_subnet_project_ids[cluster.odb_subnet_key], null)
          location = try(local.odb_subnet_locations[cluster.odb_subnet_key], null)
          segment  = try(local.odb_subnet_network_id_segments[cluster.odb_subnet_key], null)
        }
      )
    )
  }

  cloud_vm_cluster_backup_subnet_parent_segments = {
    for key, cluster in var.gcp_cloud_vm_clusters_configuration : key => (
      cluster.backup_odb_subnet != null ? {
        project  = try(split("/", cluster.backup_odb_subnet)[1], null)
        location = try(split("/", cluster.backup_odb_subnet)[3], null)
        segment  = try(split("/", cluster.backup_odb_subnet)[5], null)
        } : (
        cluster.backup_odb_subnet_key == null ? null : {
          project  = try(local.odb_subnet_project_ids[cluster.backup_odb_subnet_key], null)
          location = try(local.odb_subnet_locations[cluster.backup_odb_subnet_key], null)
          segment  = try(local.odb_subnet_network_id_segments[cluster.backup_odb_subnet_key], null)
        }
      )
    )
  }

  gcp_cloud_vm_clusters_output = {
    for key, cluster in google_oracle_database_cloud_vm_cluster.these : key => {
      id                         = cluster.id
      name                       = cluster.name
      cloud_vm_cluster_id        = cluster.cloud_vm_cluster_id
      location                   = cluster.location
      project                    = cluster.project
      gcp_oracle_zone            = cluster.gcp_oracle_zone
      ocid                       = try(cluster.properties[0].ocid, null)
      state                      = try(cluster.properties[0].state, null)
      shape                      = try(cluster.properties[0].shape, null)
      gi_version                 = try(cluster.properties[0].gi_version, null)
      cluster_name               = try(cluster.properties[0].cluster_name, null)
      hostname                   = try(cluster.properties[0].hostname, null)
      hostname_prefix            = try(cluster.properties[0].hostname_prefix, null)
      domain                     = try(cluster.properties[0].domain, null)
      scan_dns                   = try(cluster.properties[0].scan_dns, null)
      scan_ip_ids                = try(cluster.properties[0].scan_ip_ids, null)
      scan_listener_port_tcp     = try(cluster.properties[0].scan_listener_port_tcp, null)
      scan_listener_port_tcp_ssl = try(cluster.properties[0].scan_listener_port_tcp_ssl, null)
      scan_dns_record_id         = try(cluster.properties[0].scan_dns_record_id, null)
      dns_listener_ip            = try(cluster.properties[0].dns_listener_ip, null)
      system_version             = try(cluster.properties[0].system_version, null)
      license_type               = try(cluster.properties[0].license_type, null)
      cpu_core_count             = try(cluster.properties[0].cpu_core_count, null)
      ocpu_count                 = try(cluster.properties[0].ocpu_count, null)
      node_count                 = try(cluster.properties[0].node_count, null)
      memory_size_gb             = try(cluster.properties[0].memory_size_gb, null)
      db_node_storage_size_gb    = try(cluster.properties[0].db_node_storage_size_gb, null)
      data_storage_size_tb       = try(cluster.properties[0].data_storage_size_tb, null)
      storage_size_gb            = try(cluster.properties[0].storage_size_gb, null)
      db_server_ocids            = try(cluster.properties[0].db_server_ocids, null)
      disk_redundancy            = try(cluster.properties[0].disk_redundancy, null)
      local_backup_enabled       = try(cluster.properties[0].local_backup_enabled, null)
      sparse_diskgroup_enabled   = try(cluster.properties[0].sparse_diskgroup_enabled, null)
      compartment_id             = try(cluster.properties[0].compartment_id, null)
      oci_url                    = try(cluster.properties[0].oci_url, null)
    }
  }
}

resource "google_oracle_database_cloud_vm_cluster" "these" {
  for_each = var.gcp_cloud_vm_clusters_configuration

  cloud_vm_cluster_id = each.value.cloud_vm_cluster_id
  display_name        = each.value.display_name
  location            = each.value.location != null ? each.value.location : var.default_location
  project             = each.value.project_id != null ? each.value.project_id : var.default_project_id

  exadata_infrastructure = local.cloud_vm_cluster_exadata_infrastructures[each.key]

  odb_network       = local.cloud_vm_cluster_odb_networks[each.key]
  odb_subnet        = local.cloud_vm_cluster_odb_subnets[each.key]
  backup_odb_subnet = local.cloud_vm_cluster_backup_odb_subnets[each.key]

  labels              = merge(local.module_tag, local.default_labels, each.value.labels)
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
      condition = each.value.exadata_infrastructure_key == null ? true : (
        (contains(keys(var.gcp_cloud_exadata_infrastructures_configuration), each.value.exadata_infrastructure_key) ? 1 : 0) +
        (contains(keys(local.gcp_cloud_exadata_infrastructures_dependency), each.value.exadata_infrastructure_key) ? 1 : 0) == 1
      )
      error_message = "Each Cloud VM cluster exadata_infrastructure_key must reference exactly one key from gcp_cloud_exadata_infrastructures_configuration or gcp_cloud_exadata_infrastructures_dependency."
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
      condition = each.value.odb_network_key == null ? true : (
        (contains(keys(var.gcp_odb_networks_configuration), each.value.odb_network_key) ? 1 : 0) +
        (contains(keys(local.gcp_odb_networks_dependency), each.value.odb_network_key) ? 1 : 0) == 1
      )
      error_message = "Each Cloud VM cluster odb_network_key must reference exactly one key from gcp_odb_networks_configuration or gcp_odb_networks_dependency."
    }

    precondition {
      condition = each.value.odb_subnet_key == null ? true : (
        (contains(keys(var.gcp_odb_subnets_configuration), each.value.odb_subnet_key) ? 1 : 0) +
        (contains(keys(local.gcp_odb_subnets_dependency), each.value.odb_subnet_key) ? 1 : 0) == 1
      )
      error_message = "Each Cloud VM cluster odb_subnet_key must reference exactly one key from gcp_odb_subnets_configuration or gcp_odb_subnets_dependency."
    }

    precondition {
      condition = each.value.backup_odb_subnet_key == null ? true : (
        (contains(keys(var.gcp_odb_subnets_configuration), each.value.backup_odb_subnet_key) ? 1 : 0) +
        (contains(keys(local.gcp_odb_subnets_dependency), each.value.backup_odb_subnet_key) ? 1 : 0) == 1
      )
      error_message = "Each Cloud VM cluster backup_odb_subnet_key must reference exactly one key from gcp_odb_subnets_configuration or gcp_odb_subnets_dependency."
    }

    precondition {
      condition = (
        local.cloud_vm_cluster_selected_odb_network_segments[each.key] == null ||
        local.cloud_vm_cluster_client_subnet_parent_segments[each.key] == null ||
        (
          local.cloud_vm_cluster_selected_odb_network_segments[each.key].segment != null &&
          local.cloud_vm_cluster_client_subnet_parent_segments[each.key].segment != null &&
          local.cloud_vm_cluster_selected_odb_network_segments[each.key].project == local.cloud_vm_cluster_client_subnet_parent_segments[each.key].project &&
          local.cloud_vm_cluster_selected_odb_network_segments[each.key].location == local.cloud_vm_cluster_client_subnet_parent_segments[each.key].location &&
          local.cloud_vm_cluster_selected_odb_network_segments[each.key].segment == local.cloud_vm_cluster_client_subnet_parent_segments[each.key].segment
        )
      )
      error_message = "Each Cloud VM cluster client ODB subnet must resolve to a non-null parent ODB network and belong to the selected ODB network, including project and location."
    }

    precondition {
      condition = (
        local.cloud_vm_cluster_selected_odb_network_segments[each.key] == null ||
        local.cloud_vm_cluster_backup_subnet_parent_segments[each.key] == null ||
        (
          local.cloud_vm_cluster_selected_odb_network_segments[each.key].segment != null &&
          local.cloud_vm_cluster_backup_subnet_parent_segments[each.key].segment != null &&
          local.cloud_vm_cluster_selected_odb_network_segments[each.key].project == local.cloud_vm_cluster_backup_subnet_parent_segments[each.key].project &&
          local.cloud_vm_cluster_selected_odb_network_segments[each.key].location == local.cloud_vm_cluster_backup_subnet_parent_segments[each.key].location &&
          local.cloud_vm_cluster_selected_odb_network_segments[each.key].segment == local.cloud_vm_cluster_backup_subnet_parent_segments[each.key].segment
        )
      )
      error_message = "Each Cloud VM cluster backup ODB subnet must resolve to a non-null parent ODB network and belong to the selected ODB network, including project and location."
    }

    precondition {
      condition     = each.value.odb_subnet_key == null ? true : (contains(keys(var.gcp_odb_subnets_configuration), each.value.odb_subnet_key) ? var.gcp_odb_subnets_configuration[each.value.odb_subnet_key].purpose == "CLIENT_SUBNET" : true)
      error_message = "Each Cloud VM cluster odb_subnet_key must reference an ODB subnet with purpose CLIENT_SUBNET."
    }

    precondition {
      condition     = each.value.backup_odb_subnet_key == null ? true : (contains(keys(var.gcp_odb_subnets_configuration), each.value.backup_odb_subnet_key) ? var.gcp_odb_subnets_configuration[each.value.backup_odb_subnet_key].purpose == "BACKUP_SUBNET" : true)
      error_message = "Each Cloud VM cluster backup_odb_subnet_key must reference an ODB subnet with purpose BACKUP_SUBNET."
    }

    precondition {
      condition = each.value.odb_subnet_key == null ? true : (
        contains(keys(local.gcp_odb_subnets_dependency), each.value.odb_subnet_key) ? local.gcp_odb_subnets_dependency[each.value.odb_subnet_key].purpose == "CLIENT_SUBNET" : true
      )
      error_message = "Each Cloud VM cluster external odb_subnet_key dependency must have purpose CLIENT_SUBNET."
    }

    precondition {
      condition = each.value.backup_odb_subnet_key == null ? true : (
        contains(keys(local.gcp_odb_subnets_dependency), each.value.backup_odb_subnet_key) ? local.gcp_odb_subnets_dependency[each.value.backup_odb_subnet_key].purpose == "BACKUP_SUBNET" : true
      )
      error_message = "Each Cloud VM cluster external backup_odb_subnet_key dependency must have purpose BACKUP_SUBNET."
    }

    precondition {
      condition = each.value.properties.db_server_ocids == null ? true : (
        length(each.value.properties.db_server_ocids) >= coalesce(each.value.properties.node_count, 2)
      )
      error_message = "Each Cloud VM cluster db_server_ocids list must include at least one DB server OCID per node, with a minimum of two when node_count is left unset."
    }
  }
}
