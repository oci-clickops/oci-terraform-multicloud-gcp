# Copyright (c) 2026, Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

resource "google_oracle_database_odb_network" "these" {
  for_each = var.gcp_odb_networks_configuration

  odb_network_id = each.value.odb_network_id
  network        = each.value.network
  location       = try(coalesce(each.value.location, var.default_location), null)
  project        = try(coalesce(each.value.project_id, var.default_project_id), null)

  gcp_oracle_zone     = try(coalesce(each.value.gcp_oracle_zone, var.default_gcp_oracle_zone), null)
  labels              = merge(local.default_labels, each.value.labels)
  deletion_protection = try(coalesce(each.value.deletion_protection, var.default_deletion_protection), null)
}
