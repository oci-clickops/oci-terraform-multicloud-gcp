# Copyright (c) 2026, Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
  gcp_odb_networks_dependency_json = concat(
    var.gcp_odb_networks_dependency != null ? [jsonencode(var.gcp_odb_networks_dependency)] : [],
    var.gcp_odb_networks_dependency == null && var.gcp_odb_networks_dependency_file_path != null ? [file(var.gcp_odb_networks_dependency_file_path)] : [],
    ["{}"]
  )[0]

  gcp_odb_subnets_dependency_json = concat(
    var.gcp_odb_subnets_dependency != null ? [jsonencode(var.gcp_odb_subnets_dependency)] : [],
    var.gcp_odb_subnets_dependency == null && var.gcp_odb_subnets_dependency_file_path != null ? [file(var.gcp_odb_subnets_dependency_file_path)] : [],
    ["{}"]
  )[0]

  gcp_cloud_exadata_infrastructures_dependency_json = concat(
    var.gcp_cloud_exadata_infrastructures_dependency != null ? [jsonencode(var.gcp_cloud_exadata_infrastructures_dependency)] : [],
    var.gcp_cloud_exadata_infrastructures_dependency == null && var.gcp_cloud_exadata_infrastructures_dependency_file_path != null ? [file(var.gcp_cloud_exadata_infrastructures_dependency_file_path)] : [],
    ["{}"]
  )[0]

  gcp_odb_networks_dependency                  = jsondecode(local.gcp_odb_networks_dependency_json)
  gcp_odb_subnets_dependency                   = jsondecode(local.gcp_odb_subnets_dependency_json)
  gcp_cloud_exadata_infrastructures_dependency = jsondecode(local.gcp_cloud_exadata_infrastructures_dependency_json)
}

resource "terraform_data" "validate_dependency_sources" {
  lifecycle {
    precondition {
      condition     = !(var.gcp_odb_networks_dependency != null && var.gcp_odb_networks_dependency_file_path != null)
      error_message = "Set only one of gcp_odb_networks_dependency or gcp_odb_networks_dependency_file_path."
    }

    precondition {
      condition     = !(var.gcp_odb_subnets_dependency != null && var.gcp_odb_subnets_dependency_file_path != null)
      error_message = "Set only one of gcp_odb_subnets_dependency or gcp_odb_subnets_dependency_file_path."
    }

    precondition {
      condition     = !(var.gcp_cloud_exadata_infrastructures_dependency != null && var.gcp_cloud_exadata_infrastructures_dependency_file_path != null)
      error_message = "Set only one of gcp_cloud_exadata_infrastructures_dependency or gcp_cloud_exadata_infrastructures_dependency_file_path."
    }
  }
}

module "oracle_database_at_gcp" {
  source = "../.."

  depends_on = [terraform_data.validate_dependency_sources]

  module_name                 = var.module_name
  enable_output               = var.enable_output
  default_project_id          = var.project_id
  default_location            = var.location
  default_deletion_protection = var.default_deletion_protection
  default_labels              = var.default_labels
  output_path                 = var.output_path
  ssh_public_keys_file_path   = var.ssh_public_keys_file_path

  gcp_cloud_exadata_infrastructures_configuration = {}

  gcp_odb_networks_dependency                  = local.gcp_odb_networks_dependency
  gcp_odb_subnets_dependency                   = local.gcp_odb_subnets_dependency
  gcp_cloud_exadata_infrastructures_dependency = local.gcp_cloud_exadata_infrastructures_dependency

  gcp_cloud_vm_clusters_configuration = var.gcp_cloud_vm_clusters_configuration
}
