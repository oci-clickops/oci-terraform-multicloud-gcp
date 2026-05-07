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
  default_deletion_protection = var.deletion_protection
  default_labels              = var.labels
  output_path                 = var.output_path

  gcp_odb_networks_configuration = {
    primary = {
      odb_network_id      = var.odb_network_id
      network             = var.network
      location            = var.odb_network_location
      project_id          = var.odb_network_project_id
      gcp_oracle_zone     = var.odb_network_gcp_oracle_zone
      labels              = var.odb_network_labels
      deletion_protection = var.odb_network_deletion_protection
      timeouts            = var.odb_network_timeouts
    }
  }

  gcp_odb_subnets_configuration = {
    client = {
      odb_subnet_id       = var.client_odb_subnet_id
      odb_network_key     = "primary"
      cidr_range          = var.client_odb_subnet_cidr_range
      purpose             = "CLIENT_SUBNET"
      location            = var.client_odb_subnet_location
      project_id          = var.client_odb_subnet_project_id
      labels              = var.client_odb_subnet_labels
      deletion_protection = var.client_odb_subnet_deletion_protection
      timeouts            = var.client_odb_subnet_timeouts
    }
    backup = {
      odb_subnet_id       = var.backup_odb_subnet_id
      odb_network_key     = "primary"
      cidr_range          = var.backup_odb_subnet_cidr_range
      purpose             = "BACKUP_SUBNET"
      location            = var.backup_odb_subnet_location
      project_id          = var.backup_odb_subnet_project_id
      labels              = var.backup_odb_subnet_labels
      deletion_protection = var.backup_odb_subnet_deletion_protection
      timeouts            = var.backup_odb_subnet_timeouts
    }
  }
}
