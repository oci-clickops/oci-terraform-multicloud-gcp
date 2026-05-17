# Copyright (c) 2026, Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

module "oracle_autonomous_database_at_gcp" {
  source = "../.."

  default_project_id          = var.project_id
  default_location            = var.location
  default_deletion_protection = var.default_deletion_protection
  default_labels              = var.default_labels

  gcp_autonomous_databases_configuration   = var.gcp_autonomous_databases_configuration
  gcp_autonomous_databases_admin_passwords = var.gcp_autonomous_databases_admin_passwords
}
