# Copyright (c) 2026, Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

resource "google_oracle_database_cloud_exadata_infrastructure" "these" {
  for_each = var.gcp_cloud_exadata_infrastructures_configuration

  cloud_exadata_infrastructure_id = each.value.cloud_exadata_infrastructure_id
  display_name                    = each.value.display_name
  location                        = each.value.location != null ? each.value.location : var.default_location
  project                         = each.value.project_id != null ? each.value.project_id : var.default_project_id
  gcp_oracle_zone                 = each.value.gcp_oracle_zone != null ? each.value.gcp_oracle_zone : var.default_gcp_oracle_zone
  labels                          = merge(local.default_labels, each.value.labels)
  deletion_protection             = each.value.deletion_protection != null ? each.value.deletion_protection : var.default_deletion_protection

  properties {
    shape                 = each.value.properties.shape
    compute_count         = each.value.properties.compute_count
    storage_count         = each.value.properties.storage_count
    total_storage_size_gb = each.value.properties.total_storage_size_gb

    dynamic "customer_contacts" {
      for_each = each.value.properties.customer_contacts == null ? [] : each.value.properties.customer_contacts

      content {
        email = customer_contacts.value.email
      }
    }

    dynamic "maintenance_window" {
      for_each = each.value.properties.maintenance_window != null ? [each.value.properties.maintenance_window] : (var.default_cloud_exadata_maintenance_window == null ? [] : [var.default_cloud_exadata_maintenance_window])

      content {
        preference                       = maintenance_window.value.preference
        months                           = maintenance_window.value.months
        weeks_of_month                   = maintenance_window.value.weeks_of_month
        days_of_week                     = maintenance_window.value.days_of_week
        hours_of_day                     = maintenance_window.value.hours_of_day
        lead_time_week                   = maintenance_window.value.lead_time_week
        patching_mode                    = maintenance_window.value.patching_mode
        custom_action_timeout_mins       = maintenance_window.value.custom_action_timeout_mins
        is_custom_action_timeout_enabled = maintenance_window.value.is_custom_action_timeout_enabled
      }
    }
  }

  dynamic "timeouts" {
    for_each = each.value.timeouts == null ? [] : [each.value.timeouts]

    content {
      create = timeouts.value.create
      update = timeouts.value.update
      delete = timeouts.value.delete
    }
  }

  lifecycle {
    ignore_changes = [
      properties[0].compute_count,
      properties[0].storage_count,
      properties[0].total_storage_size_gb,
    ]

    precondition {
      condition     = each.value.location != null || var.default_location != null
      error_message = "Each Cloud Exadata Infrastructure must set location or default_location."
    }
  }
}
