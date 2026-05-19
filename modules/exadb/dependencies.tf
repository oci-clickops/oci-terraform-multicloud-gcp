# Copyright (c) 2026, Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
  gcp_odb_networks_dependency_raw = try(
    var.gcp_odb_networks_dependency.gcp_odb_networks,
    var.gcp_odb_networks_dependency
  )

  gcp_odb_networks_dependency = {
    for key, network in local.gcp_odb_networks_dependency_raw : key => {
      id = network.id
    }
  }

  odb_network_id_segments = {
    for key, network in local.gcp_odb_networks_dependency : key =>
    try(split("/", network.id)[5], null)
  }

  odb_network_project_ids = {
    for key, network in local.gcp_odb_networks_dependency : key =>
    try(split("/", network.id)[1], null)
  }

  odb_network_locations = {
    for key, network in local.gcp_odb_networks_dependency : key =>
    try(split("/", network.id)[3], null)
  }

  gcp_odb_subnets_dependency_raw = try(
    var.gcp_odb_subnets_dependency.gcp_odb_subnets,
    var.gcp_odb_subnets_dependency
  )

  gcp_odb_subnets_dependency = {
    for key, subnet in local.gcp_odb_subnets_dependency_raw : key => {
      id      = subnet.id
      purpose = try(subnet.purpose, null)
    }
  }

  odb_subnet_network_id_segments = {
    for key, subnet in local.gcp_odb_subnets_dependency : key =>
    try(split("/", subnet.id)[5], null)
  }

  odb_subnet_project_ids = {
    for key, subnet in local.gcp_odb_subnets_dependency : key =>
    try(split("/", subnet.id)[1], null)
  }

  odb_subnet_locations = {
    for key, subnet in local.gcp_odb_subnets_dependency : key =>
    try(split("/", subnet.id)[3], null)
  }

  gcp_cloud_exadata_infrastructures_dependency_raw = try(
    var.gcp_cloud_exadata_infrastructures_dependency.gcp_cloud_exadata_infrastructures,
    var.gcp_cloud_exadata_infrastructures_dependency
  )

  gcp_cloud_exadata_infrastructures_dependency = {
    for key, infrastructure in local.gcp_cloud_exadata_infrastructures_dependency_raw : key => {
      id = infrastructure.id
    }
  }
}
