# Copyright (c) 2026, Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
  gcp_cloud_vm_clusters_dependency_json = concat(
    var.gcp_cloud_vm_clusters_dependency != null ? [jsonencode(var.gcp_cloud_vm_clusters_dependency)] : [],
    var.gcp_cloud_vm_clusters_dependency == null && var.gcp_cloud_vm_clusters_dependency_file_path != null ? [file(var.gcp_cloud_vm_clusters_dependency_file_path)] : [],
    ["{}"]
  )[0]

  gcp_cloud_vm_clusters_dependency_decoded = jsondecode(local.gcp_cloud_vm_clusters_dependency_json)
  gcp_cloud_vm_clusters_dependency_raw = try(
    local.gcp_cloud_vm_clusters_dependency_decoded.gcp_cloud_vm_clusters,
    local.gcp_cloud_vm_clusters_dependency_decoded
  )

  gcp_cloud_vm_clusters_dependency = {
    for key, cluster in local.gcp_cloud_vm_clusters_dependency_raw : key => {
      id    = try(cluster.id, null)
      name  = try(cluster.name, null)
      ocid  = try(cluster.ocid, null)
      state = try(cluster.state, null)
    }
  }

  cloud_db_homes_configuration = {
    for key, db_home in coalesce(var.cloud_db_homes_configuration, {}) : key => merge(
      {
        for attribute, value in db_home : attribute => value
        if !contains(["vm_cluster_key", "vm_cluster_id"], attribute)
      },
      {
        vm_cluster_id = (
          try(db_home.vm_cluster_id, null) != null
          ? db_home.vm_cluster_id
          : try(local.gcp_cloud_vm_clusters_dependency[db_home.vm_cluster_key].ocid, null)
        )
      }
    )
  }

  db_home_reference_counts = {
    for key, db_home in coalesce(var.cloud_db_homes_configuration, {}) : key =>
    (try(db_home.vm_cluster_id, null) != null ? 1 : 0) + (try(db_home.vm_cluster_key, null) != null ? 1 : 0)
  }

  db_home_vm_cluster_keys = {
    for key, db_home in coalesce(var.cloud_db_homes_configuration, {}) : key => db_home.vm_cluster_key
    if try(db_home.vm_cluster_key, null) != null
  }

  db_home_vm_cluster_ids = {
    for key, db_home in coalesce(var.cloud_db_homes_configuration, {}) : key => db_home.vm_cluster_id
    if try(db_home.vm_cluster_id, null) != null
  }
}

resource "terraform_data" "validate_handoff" {
  lifecycle {
    precondition {
      condition     = !(var.gcp_cloud_vm_clusters_dependency != null && var.gcp_cloud_vm_clusters_dependency_file_path != null)
      error_message = "Set only one of gcp_cloud_vm_clusters_dependency or gcp_cloud_vm_clusters_dependency_file_path."
    }

    precondition {
      condition = alltrue([
        for key, count in local.db_home_reference_counts : count == 1
      ])
      error_message = "Each cloud_db_homes_configuration entry must set exactly one of vm_cluster_id or vm_cluster_key."
    }

    precondition {
      condition = alltrue([
        for key, vm_cluster_id in local.db_home_vm_cluster_ids :
        can(regex("^ocid1[.]cloudvmcluster[.]", trimspace(vm_cluster_id)))
      ])
      error_message = "Direct cloud_db_homes_configuration vm_cluster_id values must be OCI Cloud VM Cluster OCIDs."
    }

    precondition {
      condition = alltrue([
        for key, vm_cluster_key in local.db_home_vm_cluster_keys :
        contains(keys(local.gcp_cloud_vm_clusters_dependency), vm_cluster_key)
      ])
      error_message = "Each cloud_db_homes_configuration vm_cluster_key must reference a key from gcp_cloud_vm_clusters_dependency."
    }

    precondition {
      condition = alltrue([
        for key, vm_cluster_key in local.db_home_vm_cluster_keys :
        try(local.gcp_cloud_vm_clusters_dependency[vm_cluster_key].ocid, null) != null &&
        can(regex("^ocid1[.]cloudvmcluster[.]", trimspace(local.gcp_cloud_vm_clusters_dependency[vm_cluster_key].ocid)))
      ])
      error_message = "Each referenced GCP VM Cluster dependency must include a non-null OCI Cloud VM Cluster OCID in the ocid field."
    }

    precondition {
      condition = alltrue([
        for key, vm_cluster_key in local.db_home_vm_cluster_keys :
        try(local.gcp_cloud_vm_clusters_dependency[vm_cluster_key].state, null) == null ||
        local.gcp_cloud_vm_clusters_dependency[vm_cluster_key].state == "AVAILABLE"
      ])
      error_message = "Each referenced GCP VM Cluster dependency must be AVAILABLE before OCI DB Homes are created."
    }
  }
}

module "oci_exadata_database" {
  source = "git::https://github.com/oci-landing-zones/terraform-oci-modules-exadata.git//exadata-database?ref=v1.1.0"

  depends_on = [terraform_data.validate_handoff]

  compartments_dependency           = var.compartments_dependency
  subscription_dependency           = var.subscription_dependency
  network_dependency                = var.network_dependency
  default_compartment_id            = var.default_compartment_id
  default_defined_tags              = var.default_defined_tags
  default_freeform_tags             = var.default_freeform_tags
  cloud_db_homes_configuration      = local.cloud_db_homes_configuration
  databases_configuration           = var.databases_configuration
  pluggable_databases_configuration = var.pluggable_databases_configuration
}
