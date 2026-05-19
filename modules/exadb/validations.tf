# Copyright (c) 2026, Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

# Cross-variable preconditions that cannot be expressed inside individual
# variable validation blocks (those only see var.<self>). Two families:
#  (a) map-key uniqueness between *_configuration and *_dependency
#  (b) internal-ID uniqueness within each (project, location) scope, so a
#      typo or copy-paste duplicate fails the plan instead of producing a
#      409 from the GCP API minutes into the apply.

locals {
  # Composite identity tuples used for (b). The "_" sentinel keeps coalesce
  # from erroring on null-null pairs and ensures entries that share the same
  # defaults still collide on the same bucket.
  cloud_exadata_infrastructure_identity = {
    for key, infrastructure in var.gcp_cloud_exadata_infrastructures_configuration :
    key => format("%s|%s|%s",
      coalesce(infrastructure.project_id, var.default_project_id, "_"),
      coalesce(infrastructure.location, var.default_location, "_"),
      infrastructure.cloud_exadata_infrastructure_id
    )
  }

  cloud_exadata_infrastructure_id_duplicates = {
    for tuple, keys_list in {
      for key, identity in local.cloud_exadata_infrastructure_identity :
      identity => key...
    } : tuple => keys_list if length(keys_list) > 1
  }

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

  # ODB subnet IDs scope by (project, location, parent_odb_network).
  # Entries whose parent network cannot be resolved are skipped — the
  # resource-level precondition in gcp_odb_subnet.tf reports that case with a
  # clearer message, so we avoid emitting confusing "false duplicate" errors.
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

  cloud_vm_cluster_identity = {
    for key, cluster in var.gcp_cloud_vm_clusters_configuration :
    key => format("%s|%s|%s",
      coalesce(cluster.project_id, var.default_project_id, "_"),
      coalesce(cluster.location, var.default_location, "_"),
      cluster.cloud_vm_cluster_id
    )
  }

  cloud_vm_cluster_id_duplicates = {
    for tuple, keys_list in {
      for key, identity in local.cloud_vm_cluster_identity :
      identity => key...
    } : tuple => keys_list if length(keys_list) > 1
  }
}

resource "terraform_data" "validate_key_uniqueness" {
  lifecycle {
    precondition {
      condition = length(setintersection(
        keys(var.gcp_odb_networks_configuration),
        keys(local.gcp_odb_networks_dependency)
      )) == 0
      error_message = "Keys must be unique across gcp_odb_networks_configuration and gcp_odb_networks_dependency. Colliding keys: ${join(", ", setintersection(keys(var.gcp_odb_networks_configuration), keys(local.gcp_odb_networks_dependency)))}."
    }

    precondition {
      condition = length(setintersection(
        keys(var.gcp_odb_subnets_configuration),
        keys(local.gcp_odb_subnets_dependency)
      )) == 0
      error_message = "Keys must be unique across gcp_odb_subnets_configuration and gcp_odb_subnets_dependency. Colliding keys: ${join(", ", setintersection(keys(var.gcp_odb_subnets_configuration), keys(local.gcp_odb_subnets_dependency)))}."
    }

    precondition {
      condition = length(setintersection(
        keys(var.gcp_cloud_exadata_infrastructures_configuration),
        keys(local.gcp_cloud_exadata_infrastructures_dependency)
      )) == 0
      error_message = "Keys must be unique across gcp_cloud_exadata_infrastructures_configuration and gcp_cloud_exadata_infrastructures_dependency. Colliding keys: ${join(", ", setintersection(keys(var.gcp_cloud_exadata_infrastructures_configuration), keys(local.gcp_cloud_exadata_infrastructures_dependency)))}."
    }

    precondition {
      condition     = length(local.cloud_exadata_infrastructure_id_duplicates) == 0
      error_message = "cloud_exadata_infrastructure_id values must be unique within each (project, location). Duplicates: ${join("; ", [for tuple, keys_list in local.cloud_exadata_infrastructure_id_duplicates : format("%s (keys: %s)", tuple, join(", ", keys_list))])}."
    }

    precondition {
      condition     = length(local.odb_network_id_duplicates) == 0
      error_message = "odb_network_id values must be unique within each (project, location). Duplicates: ${join("; ", [for tuple, keys_list in local.odb_network_id_duplicates : format("%s (keys: %s)", tuple, join(", ", keys_list))])}."
    }

    precondition {
      condition     = length(local.odb_subnet_id_duplicates) == 0
      error_message = "odb_subnet_id values must be unique within each (project, location, parent_odb_network). Duplicates: ${join("; ", [for tuple, keys_list in local.odb_subnet_id_duplicates : format("%s (keys: %s)", tuple, join(", ", keys_list))])}."
    }

    precondition {
      condition     = length(local.cloud_vm_cluster_id_duplicates) == 0
      error_message = "cloud_vm_cluster_id values must be unique within each (project, location). Duplicates: ${join("; ", [for tuple, keys_list in local.cloud_vm_cluster_id_duplicates : format("%s (keys: %s)", tuple, join(", ", keys_list))])}."
    }
  }
}
