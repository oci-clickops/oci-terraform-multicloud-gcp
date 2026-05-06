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
  default_gcp_oracle_zone     = var.gcp_oracle_zone
  default_deletion_protection = false
  default_labels = {
    terraform = "true"
    example   = "vpc-cidr"
  }

  default_cloud_exadata_maintenance_window = {
    preference     = "CUSTOM_PREFERENCE"
    days_of_week   = ["SUNDAY"]
    hours_of_day   = [4]
    weeks_of_month = [1]
    patching_mode  = "ROLLING"
  }

  gcp_cloud_exadata_infrastructures_configuration = {
    primary = {
      cloud_exadata_infrastructure_id = var.cloud_exadata_infrastructure_id
      display_name                    = var.cloud_exadata_infrastructure_id
      properties = {
        shape         = var.exadata_shape
        compute_count = var.compute_count
        storage_count = var.storage_count
        customer_contacts = [
          {
            email = var.customer_contact_email
          }
        ]
      }
    }
  }

  gcp_cloud_vm_clusters_configuration = {
    primary = {
      cloud_vm_cluster_id        = var.cloud_vm_cluster_id
      display_name               = var.cloud_vm_cluster_id
      exadata_infrastructure_key = "primary"
      network                    = var.network
      cidr                       = var.client_subnet_cidr
      backup_subnet_cidr         = var.backup_subnet_cidr
      timeouts = {
        create = "180m"
        update = "90m"
        delete = "90m"
      }
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
