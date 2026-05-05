# Copyright (c) 2026, Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

resource "google_oracle_database_odb_subnet" "these" {
  for_each = var.gcp_odb_subnets_configuration

  odb_subnet_id = each.value.odb_subnet_id
  cidr_range    = each.value.cidr_range
  purpose       = each.value.purpose
  location      = try(coalesce(each.value.location, var.default_location), null)
  project       = try(coalesce(each.value.project_id, var.default_project_id), null)

  odbnetwork = try(coalesce(
    each.value.odbnetwork,
    each.value.odb_network_key == null ? null : google_oracle_database_odb_network.these[each.value.odb_network_key].odb_network_id
  ), null)

  labels              = merge(local.default_labels, each.value.labels)
  deletion_protection = try(coalesce(each.value.deletion_protection, var.default_deletion_protection), null)
}
