# Copyright (c) 2026, Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
  odb_network_id_segments = {
    for key, network in var.gcp_odb_networks_configuration : key =>
    network.odb_network_id
  }

  odb_network_project_ids = {
    for key, network in var.gcp_odb_networks_configuration : key =>
    network.project_id != null ? network.project_id : var.default_project_id
  }

  odb_network_locations = {
    for key, network in var.gcp_odb_networks_configuration : key =>
    network.location != null ? network.location : var.default_location
  }

  odb_subnet_network_id_segments = {
    for key, subnet in var.gcp_odb_subnets_configuration : key =>
    subnet.odbnetwork != null ? subnet.odbnetwork : try(local.odb_network_id_segments[subnet.odb_network_key], null)
  }

  odb_subnet_project_ids = {
    for key, subnet in var.gcp_odb_subnets_configuration : key =>
    subnet.project_id != null ? subnet.project_id : var.default_project_id
  }

  odb_subnet_locations = {
    for key, subnet in var.gcp_odb_subnets_configuration : key =>
    subnet.location != null ? subnet.location : var.default_location
  }

  gcp_odb_subnets_output = {
    for key, subnet in google_oracle_database_odb_subnet.these : key => {
      id            = subnet.id
      name          = subnet.name
      odb_subnet_id = subnet.odb_subnet_id
      odbnetwork    = subnet.odbnetwork
      cidr_range    = subnet.cidr_range
      purpose       = subnet.purpose
      location      = subnet.location
      project       = subnet.project
      state         = subnet.state
    }
  }
}

resource "google_oracle_database_odb_subnet" "these" {
  for_each = var.gcp_odb_subnets_configuration

  odb_subnet_id = each.value.odb_subnet_id
  cidr_range    = each.value.cidr_range
  purpose       = each.value.purpose
  location      = each.value.location != null ? each.value.location : var.default_location
  project       = each.value.project_id != null ? each.value.project_id : var.default_project_id

  odbnetwork = each.value.odbnetwork != null ? each.value.odbnetwork : try(google_oracle_database_odb_network.these[each.value.odb_network_key].odb_network_id, null)

  labels              = merge(local.module_tag, local.default_labels, each.value.labels)
  deletion_protection = each.value.deletion_protection != null ? each.value.deletion_protection : var.default_deletion_protection

  dynamic "timeouts" {
    for_each = each.value.timeouts == null ? [] : [each.value.timeouts]

    content {
      create = timeouts.value.create
      update = timeouts.value.update
      delete = timeouts.value.delete
    }
  }

  lifecycle {
    precondition {
      condition     = each.value.location != null || var.default_location != null
      error_message = "Each ODB subnet must set location or default_location."
    }

    precondition {
      condition     = each.value.odb_network_key == null ? true : contains(keys(var.gcp_odb_networks_configuration), each.value.odb_network_key)
      error_message = "Each ODB subnet odb_network_key must reference an ODB network key from gcp_odb_networks_configuration."
    }

    precondition {
      condition = each.value.odb_network_key == null ? true : (
        local.odb_subnet_project_ids[each.key] == null ||
        try(local.odb_network_project_ids[each.value.odb_network_key], null) == null ||
        local.odb_subnet_project_ids[each.key] == local.odb_network_project_ids[each.value.odb_network_key]
      )
      error_message = "Each ODB subnet odb_network_key must reference an ODB network in the same project."
    }

    precondition {
      condition = each.value.odb_network_key == null ? true : (
        local.odb_subnet_locations[each.key] == null ||
        try(local.odb_network_locations[each.value.odb_network_key], null) == null ||
        local.odb_subnet_locations[each.key] == local.odb_network_locations[each.value.odb_network_key]
      )
      error_message = "Each ODB subnet odb_network_key must reference an ODB network in the same location."
    }
  }
}
