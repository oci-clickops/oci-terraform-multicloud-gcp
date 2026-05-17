# Copyright (c) 2026, Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

module "oracle_database_at_gcp" {
  source = "../.."

  default_project_id          = var.project_id
  default_location            = var.location
  default_deletion_protection = var.default_deletion_protection
  default_labels              = var.default_labels

  gcp_odb_networks_configuration                  = {}
  gcp_odb_subnets_configuration                   = {}
  gcp_cloud_exadata_infrastructures_configuration = {}

  gcp_cloud_vm_clusters_configuration = var.gcp_cloud_vm_clusters_configuration
}
