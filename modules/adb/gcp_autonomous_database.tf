# Copyright (c) 2026, Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
  gcp_odb_networks_dependency_raw = try(
    var.gcp_odb_networks_dependency.gcp_odb_networks,
    jsondecode(file(var.gcp_odb_networks_dependency)).gcp_odb_networks,
    var.gcp_odb_networks_dependency
  )

  gcp_odb_networks_dependency = {
    for key, network in local.gcp_odb_networks_dependency_raw : key => {
      id = network.id
    }
  }

  gcp_odb_subnets_dependency_raw = try(
    var.gcp_odb_subnets_dependency.gcp_odb_subnets,
    jsondecode(file(var.gcp_odb_subnets_dependency)).gcp_odb_subnets,
    var.gcp_odb_subnets_dependency
  )

  gcp_odb_subnets_dependency = {
    for key, subnet in local.gcp_odb_subnets_dependency_raw : key => {
      id = subnet.id
    }
  }

  autonomous_database_odb_networks = {
    for key, adb in var.gcp_autonomous_databases_configuration : key =>
    adb.odb_network != null ? adb.odb_network : (
      adb.odb_network_key == null ? null : try(local.gcp_odb_networks_dependency[adb.odb_network_key].id, null)
    )
  }

  autonomous_database_odb_subnets = {
    for key, adb in var.gcp_autonomous_databases_configuration : key =>
    adb.odb_subnet != null ? adb.odb_subnet : (
      adb.odb_subnet_key == null ? null : try(local.gcp_odb_subnets_dependency[adb.odb_subnet_key].id, null)
    )
  }

  gcp_autonomous_databases_output = {
    for key, adb in google_oracle_database_autonomous_database.these : key => {
      id                 = adb.id
      name               = adb.name
      location           = adb.location
      project            = adb.project
      ocid               = try(adb.properties[0].ocid, null)
      state              = try(adb.properties[0].state, null)
      oci_url            = try(adb.properties[0].oci_url, null)
      connection_strings = try(adb.properties[0].connection_strings, null)
    }
  }
}

resource "google_oracle_database_autonomous_database" "these" {
  for_each = var.gcp_autonomous_databases_configuration

  autonomous_database_id = each.value.autonomous_database_id
  location               = each.value.location != null ? each.value.location : var.default_location
  project                = each.value.project_id != null ? each.value.project_id : var.default_project_id
  display_name           = each.value.display_name
  database               = each.value.database
  admin_password         = try(var.gcp_autonomous_databases_admin_passwords[each.key], null)

  network = try(each.value.network, null)
  cidr    = try(each.value.cidr, null)

  odb_network = local.autonomous_database_odb_networks[each.key]
  odb_subnet  = local.autonomous_database_odb_subnets[each.key]

  labels              = merge(local.module_tag, local.default_labels, each.value.labels)
  deletion_protection = each.value.deletion_protection != null ? each.value.deletion_protection : var.default_deletion_protection

  dynamic "properties" {
    for_each = each.value.properties == null ? [] : [each.value.properties]
    content {
      db_workload                     = try(properties.value.db_workload, null)
      license_type                    = try(properties.value.license_type, null)
      compute_count                   = try(properties.value.compute_count, null)
      cpu_core_count                  = try(properties.value.cpu_core_count, null)
      data_storage_size_tb            = try(properties.value.data_storage_size_tb, null)
      data_storage_size_gb            = try(properties.value.data_storage_size_gb, null)
      db_version                      = try(properties.value.db_version, null)
      db_edition                      = try(properties.value.db_edition, null)
      character_set                   = try(properties.value.character_set, null)
      n_character_set                 = try(properties.value.n_character_set, null)
      private_endpoint_ip             = try(properties.value.private_endpoint_ip, null)
      private_endpoint_label          = try(properties.value.private_endpoint_label, null)
      is_auto_scaling_enabled         = try(properties.value.is_auto_scaling_enabled, null)
      is_storage_auto_scaling_enabled = try(properties.value.is_storage_auto_scaling_enabled, null)
      backup_retention_period_days    = try(properties.value.backup_retention_period_days, null)
      maintenance_schedule_type       = try(properties.value.maintenance_schedule_type, null)
      mtls_connection_required        = try(properties.value.mtls_connection_required, null)
      operations_insights_state       = try(properties.value.operations_insights_state, null)
      secret_id                       = try(properties.value.secret_id, null)
      vault_id                        = try(properties.value.vault_id, null)

      dynamic "customer_contacts" {
        for_each = try(properties.value.customer_contacts, [])
        content {
          email = customer_contacts.value.email
        }
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
      admin_password,
      properties[0].compute_count,
      properties[0].cpu_core_count,
      properties[0].data_storage_size_tb,
      properties[0].data_storage_size_gb,
      properties[0].db_version,
      properties[0].is_auto_scaling_enabled,
      properties[0].is_storage_auto_scaling_enabled,
    ]

    precondition {
      condition     = each.value.location != null || var.default_location != null
      error_message = "Each Autonomous Database must set location or default_location."
    }

    precondition {
      condition = !(
        (try(each.value.network, null) != null || try(each.value.cidr, null) != null) &&
        (try(each.value.odb_network, null) != null || try(each.value.odb_network_key, null) != null)
      )
      error_message = "Autonomous database '${each.key}': set either VPC mode (network + cidr) or ODB Network mode (odb_network/odb_network_key + odb_subnet/odb_subnet_key), not both."
    }

    precondition {
      condition = try(each.value.odb_network_key, null) == null ? true : (
        contains(keys(local.gcp_odb_networks_dependency), each.value.odb_network_key)
      )
      error_message = "Autonomous database '${each.key}' odb_network_key must reference a key in gcp_odb_networks_dependency."
    }

    precondition {
      condition = try(each.value.odb_subnet_key, null) == null ? true : (
        contains(keys(local.gcp_odb_subnets_dependency), each.value.odb_subnet_key)
      )
      error_message = "Autonomous database '${each.key}' odb_subnet_key must reference a key in gcp_odb_subnets_dependency."
    }
  }
}
