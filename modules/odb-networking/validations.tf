# Copyright (c) 2026, Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

# Cross-variable preconditions that cannot be expressed inside individual
# variable validation blocks. Internal resource IDs must be unique within
# their provider scope so copy-paste errors fail at plan time.

locals {
  odb_network_identity = {
    for key, network in var.gcp_odb_networks_configuration :
    key => format("%s|%s|%s",
      coalesce(network.project_id, var.default_project_id, "_"),
      coalesce(network.location, var.default_location, "_"),
      network.odb_network_id
    )
  }

  odb_network_id_duplicates = {
    for tuple, keys_list in {
      for key, identity in local.odb_network_identity :
      identity => key...
    } : tuple => keys_list if length(keys_list) > 1
  }

  odb_subnet_identity = {
    for key, subnet in var.gcp_odb_subnets_configuration :
    key => format("%s|%s|%s|%s",
      coalesce(subnet.project_id, var.default_project_id, "_"),
      coalesce(subnet.location, var.default_location, "_"),
      subnet.odbnetwork != null ? subnet.odbnetwork : try(local.odb_network_id_segments[subnet.odb_network_key], "_"),
      subnet.odb_subnet_id
    )
    if subnet.odbnetwork != null || try(local.odb_network_id_segments[subnet.odb_network_key], null) != null
  }

  odb_subnet_id_duplicates = {
    for tuple, keys_list in {
      for key, identity in local.odb_subnet_identity :
      identity => key...
    } : tuple => keys_list if length(keys_list) > 1
  }
}

resource "terraform_data" "validate_resource_uniqueness" {
  lifecycle {
    precondition {
      condition     = length(local.odb_network_id_duplicates) == 0
      error_message = "odb_network_id values must be unique within each (project, location). Duplicates: ${join("; ", [for tuple, keys_list in local.odb_network_id_duplicates : format("%s (keys: %s)", tuple, join(", ", keys_list))])}."
    }

    precondition {
      condition     = length(local.odb_subnet_id_duplicates) == 0
      error_message = "odb_subnet_id values must be unique within each (project, location, parent_odb_network). Duplicates: ${join("; ", [for tuple, keys_list in local.odb_subnet_id_duplicates : format("%s (keys: %s)", tuple, join(", ", keys_list))])}."
    }
  }
}
