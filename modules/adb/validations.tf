# Copyright (c) 2026, Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

# Cross-variable preconditions that cannot be expressed inside individual
# variable validation blocks (those only see var.<self>). The Autonomous
# Database module is downstream-only — it does not create ODB networks or
# subnets — so there is no key-uniqueness check between configuration and
# dependency. What this file does enforce is internal-ID and database-name
# uniqueness, so typos or copy-paste duplicates fail the plan instead of
# producing a 409 from the GCP API minutes into the apply.

locals {
  # Composite identity tuple: (project, location, autonomous_database_id).
  # The "_" sentinel keeps coalesce from erroring on null-null pairs and
  # ensures entries that share the same defaults still collide on the same
  # bucket.
  autonomous_database_identity = {
    for key, adb in var.gcp_autonomous_databases_configuration :
    key => format("%s|%s|%s",
      coalesce(adb.project_id, var.default_project_id, "_"),
      coalesce(adb.location, var.default_location, "_"),
      adb.autonomous_database_id
    )
  }

  autonomous_database_id_duplicates = {
    for tuple, keys_list in {
      for key, identity in local.autonomous_database_identity :
      identity => key...
    } : tuple => keys_list if length(keys_list) > 1
  }

  # Provider rule: database names are unique in the project.
  autonomous_database_name_identity = {
    for key, adb in var.gcp_autonomous_databases_configuration :
    key => adb.database == null ? null : format("%s|%s",
      coalesce(adb.project_id, var.default_project_id, "_"),
      lower(adb.database)
    )
  }

  autonomous_database_name_duplicates = {
    for tuple, keys_list in {
      for key, identity in local.autonomous_database_name_identity :
      identity => key... if identity != null
    } : tuple => keys_list if length(keys_list) > 1
  }
}

resource "terraform_data" "validate_uniqueness" {
  lifecycle {
    precondition {
      condition     = length(local.autonomous_database_id_duplicates) == 0
      error_message = "autonomous_database_id values must be unique within each (project, location). Duplicates: ${join("; ", [for tuple, keys_list in local.autonomous_database_id_duplicates : format("%s (keys: %s)", tuple, join(", ", keys_list))])}."
    }

    precondition {
      condition     = length(local.autonomous_database_name_duplicates) == 0
      error_message = "database values must be unique within each project. Duplicates: ${join("; ", [for tuple, keys_list in local.autonomous_database_name_duplicates : format("%s (keys: %s)", tuple, join(", ", keys_list))])}."
    }
  }
}
