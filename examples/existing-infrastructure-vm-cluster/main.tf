# Copyright (c) 2026, Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

provider "google" {
  project = var.project_id
  region  = var.location
}

module "oracle_database_at_gcp" {
  source = "../.."

  default_project_id          = var.project_id
  default_location            = var.location
  default_deletion_protection = false
  default_labels = {
    terraform = "true"
    example   = "existing-infrastructure-vm-cluster"
  }

  gcp_odb_networks_configuration                  = {}
  gcp_odb_subnets_configuration                   = {}
  gcp_cloud_exadata_infrastructures_configuration = {}

  gcp_cloud_vm_clusters_configuration = {
    primary = {
      cloud_vm_cluster_id    = var.cloud_vm_cluster_id
      display_name           = var.cloud_vm_cluster_id
      exadata_infrastructure = var.exadata_infrastructure
      odb_network            = var.odb_network
      odb_subnet             = var.odb_subnet
      backup_odb_subnet      = var.backup_odb_subnet

      properties = {
        license_type    = var.license_type
        cpu_core_count  = var.cpu_core_count
        gi_version      = var.gi_version
        hostname_prefix = var.hostname_prefix
        ssh_public_keys = var.ssh_public_keys
      }
    }
  }
}
