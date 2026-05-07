# Copyright (c) 2026, Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
  default_labels                = var.default_labels == null ? {} : var.default_labels
  valid_gcp_resource_id_pattern = "^[a-z]([a-z0-9-]{0,61}[a-z0-9])?$"

  gcp_odb_networks_dependency_raw = try(
    var.gcp_odb_networks_dependency.gcp_odb_networks,
    jsondecode(file(var.gcp_odb_networks_dependency)).gcp_odb_networks,
    var.gcp_odb_networks_dependency
  )

  gcp_odb_networks_dependency = {
    for key, network in local.gcp_odb_networks_dependency_raw : key => {
      id             = network.id
      odb_network_id = try(network.odb_network_id, null)
    }
  }

  gcp_odb_subnets_dependency_raw = try(
    var.gcp_odb_subnets_dependency.gcp_odb_subnets,
    jsondecode(file(var.gcp_odb_subnets_dependency)).gcp_odb_subnets,
    var.gcp_odb_subnets_dependency
  )

  gcp_odb_subnets_dependency = {
    for key, subnet in local.gcp_odb_subnets_dependency_raw : key => {
      id         = subnet.id
      purpose    = try(subnet.purpose, null)
      odbnetwork = try(subnet.odbnetwork, null)
    }
  }

  gcp_cloud_exadata_infrastructures_dependency_raw = try(
    var.gcp_cloud_exadata_infrastructures_dependency.gcp_cloud_exadata_infrastructures,
    jsondecode(file(var.gcp_cloud_exadata_infrastructures_dependency)).gcp_cloud_exadata_infrastructures,
    var.gcp_cloud_exadata_infrastructures_dependency
  )

  gcp_cloud_exadata_infrastructures_dependency = {
    for key, infrastructure in local.gcp_cloud_exadata_infrastructures_dependency_raw : key => {
      id = infrastructure.id
    }
  }

  odb_network_id_segments = merge(
    {
      for key, network in local.gcp_odb_networks_dependency : key =>
      network.odb_network_id != null ? network.odb_network_id : try(split("/", network.id)[5], null)
    },
    {
      for key, network in var.gcp_odb_networks_configuration : key =>
      network.odb_network_id
    }
  )

  odb_subnet_network_id_segments = merge(
    {
      for key, subnet in local.gcp_odb_subnets_dependency : key =>
      subnet.odbnetwork != null ? subnet.odbnetwork : try(split("/", subnet.id)[5], null)
    },
    {
      for key, subnet in var.gcp_odb_subnets_configuration : key =>
      subnet.odbnetwork != null ? subnet.odbnetwork : try(local.odb_network_id_segments[subnet.odb_network_key], null)
    }
  )

  odb_network_project_ids = merge(
    {
      for key, network in local.gcp_odb_networks_dependency : key =>
      try(split("/", network.id)[1], null)
    },
    {
      for key, network in var.gcp_odb_networks_configuration : key =>
      network.project_id != null ? network.project_id : var.default_project_id
    }
  )

  odb_network_locations = merge(
    {
      for key, network in local.gcp_odb_networks_dependency : key =>
      try(split("/", network.id)[3], null)
    },
    {
      for key, network in var.gcp_odb_networks_configuration : key =>
      network.location != null ? network.location : var.default_location
    }
  )

  odb_subnet_project_ids = merge(
    {
      for key, subnet in local.gcp_odb_subnets_dependency : key =>
      try(split("/", subnet.id)[1], null)
    },
    {
      for key, subnet in var.gcp_odb_subnets_configuration : key =>
      subnet.project_id != null ? subnet.project_id : var.default_project_id
    }
  )

  odb_subnet_locations = merge(
    {
      for key, subnet in local.gcp_odb_subnets_dependency : key =>
      try(split("/", subnet.id)[3], null)
    },
    {
      for key, subnet in var.gcp_odb_subnets_configuration : key =>
      subnet.location != null ? subnet.location : var.default_location
    }
  )
}
