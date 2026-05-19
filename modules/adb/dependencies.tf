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
}
