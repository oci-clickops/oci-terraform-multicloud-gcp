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

  gcp_odb_networks_dependency = jsondecode(local.gcp_odb_networks_dependency_json)
  gcp_odb_subnets_dependency  = jsondecode(local.gcp_odb_subnets_dependency_json)
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
  }
}

module "oracle_autonomous_database_at_gcp" {
  source = "../.."

  depends_on = [terraform_data.validate_dependency_sources]

  default_project_id          = var.project_id
  default_location            = var.location
  default_deletion_protection = var.default_deletion_protection
  default_labels              = var.default_labels

  gcp_odb_networks_dependency = local.gcp_odb_networks_dependency
  gcp_odb_subnets_dependency  = local.gcp_odb_subnets_dependency

  gcp_autonomous_databases_configuration   = var.gcp_autonomous_databases_configuration
  gcp_autonomous_databases_admin_passwords = var.gcp_autonomous_databases_admin_passwords
}
