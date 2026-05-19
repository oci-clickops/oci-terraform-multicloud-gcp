# Copyright (c) 2026, Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "module_name" {
  description = "Display name for this module instance."
  type        = string
  default     = "oracle-autonomous-database-at-gcp"
  nullable    = false

  validation {
    condition     = can(regex("^[a-z]([a-z0-9_-]{0,54})?$", var.module_name))
    error_message = "module_name must be 1-55 characters, start with a lowercase letter, and contain only lowercase letters, numbers, hyphens, or underscores so it can be used in Google Cloud labels."
  }
}

variable "enable_output" {
  description = "Whether this module should emit resource outputs."
  type        = bool
  default     = true
  nullable    = false
}

variable "output_path" {
  description = "Optional directory where OCI-style dependency JSON files are written for downstream stacks."
  type        = string
  default     = null

  validation {
    condition     = var.output_path == null ? true : trimspace(var.output_path) != ""
    error_message = "output_path must be null or a non-empty directory path."
  }
}

variable "default_project_id" {
  description = "Default Google Cloud project ID used by resources when project_id is not set on the resource."
  type        = string
  default     = null
}

variable "default_location" {
  description = "Default Google Cloud region used by resources when location is not set on the resource."
  type        = string
  default     = null
}

variable "default_labels" {
  description = "Default labels merged into all resources. Resource-specific labels win on key collisions."
  type        = map(string)
  default     = {}
  nullable    = false
}

variable "default_deletion_protection" {
  description = "Default deletion protection value for resources that support deletion_protection."
  type        = bool
  default     = true
  nullable    = false
}

variable "gcp_odb_networks_dependency" {
  description = "Externally managed ODB networks this module may depend on, keyed by logical name. Accepts a map or a wrapped map under gcp_odb_networks."
  type        = any
  default     = {}
  nullable    = false

  validation {
    condition = can(keys(try(
      var.gcp_odb_networks_dependency.gcp_odb_networks,
      var.gcp_odb_networks_dependency
    )))
    error_message = "gcp_odb_networks_dependency must be a map or a map with gcp_odb_networks."
  }

  validation {
    condition = try(alltrue([
      for network in try(
        var.gcp_odb_networks_dependency.gcp_odb_networks,
        var.gcp_odb_networks_dependency
      ) :
      can(regex("^projects/[^/]+/locations/[^/]+/odbNetworks/[^/]+$", network.id))
    ]), false)
    error_message = "ODB network dependency id values must use projects/{project}/locations/{location}/odbNetworks/{odb_network} format."
  }
}

variable "gcp_odb_subnets_dependency" {
  description = "Externally managed ODB subnets this module may depend on, keyed by logical name. Accepts a map or a wrapped map under gcp_odb_subnets."
  type        = any
  default     = {}
  nullable    = false

  validation {
    condition = can(keys(try(
      var.gcp_odb_subnets_dependency.gcp_odb_subnets,
      var.gcp_odb_subnets_dependency
    )))
    error_message = "gcp_odb_subnets_dependency must be a map or a map with gcp_odb_subnets."
  }

  validation {
    condition = try(alltrue([
      for subnet in try(
        var.gcp_odb_subnets_dependency.gcp_odb_subnets,
        var.gcp_odb_subnets_dependency
      ) :
      can(regex("^projects/[^/]+/locations/[^/]+/odbNetworks/[^/]+/odbSubnets/[^/]+$", subnet.id))
    ]), false)
    error_message = "ODB subnet dependency id values must use projects/{project}/locations/{location}/odbNetworks/{odb_network}/odbSubnets/{odb_subnet} format."
  }

  validation {
    condition = try(alltrue([
      for subnet in try(
        var.gcp_odb_subnets_dependency.gcp_odb_subnets,
        var.gcp_odb_subnets_dependency
      ) :
      contains(["CLIENT_SUBNET", "BACKUP_SUBNET"], try(subnet.purpose, ""))
    ]), false)
    error_message = "ODB subnet dependency purpose must be set to CLIENT_SUBNET or BACKUP_SUBNET on every entry."
  }
}

variable "gcp_autonomous_databases_configuration" {
  description = "Map of Oracle Autonomous Databases to create."
  type = map(object({
    autonomous_database_id = string
    database               = optional(string)
    display_name           = optional(string)
    location               = optional(string)
    project_id             = optional(string)
    labels                 = optional(map(string), {})
    deletion_protection    = optional(bool)

    odb_network     = optional(string)
    odb_network_key = optional(string)
    odb_subnet      = optional(string)
    odb_subnet_key  = optional(string)

    timeouts = optional(object({
      create = optional(string)
      update = optional(string)
      delete = optional(string)
    }))

    properties = optional(object({
      db_workload                     = optional(string)
      license_type                    = optional(string)
      compute_count                   = optional(number)
      cpu_core_count                  = optional(number)
      data_storage_size_tb            = optional(number)
      data_storage_size_gb            = optional(number)
      db_version                      = optional(string)
      db_edition                      = optional(string)
      character_set                   = optional(string)
      n_character_set                 = optional(string)
      private_endpoint_ip             = optional(string)
      private_endpoint_label          = optional(string)
      is_auto_scaling_enabled         = optional(bool)
      is_storage_auto_scaling_enabled = optional(bool)
      backup_retention_period_days    = optional(number)
      maintenance_schedule_type       = optional(string)
      mtls_connection_required        = optional(bool)
      operations_insights_state       = optional(string)
      secret_id                       = optional(string)
      vault_id                        = optional(string)
      customer_contacts = optional(list(object({
        email = string
      })), [])
    }))
  }))
  default  = {}
  nullable = false

  validation {
    condition = alltrue([
      for adb in var.gcp_autonomous_databases_configuration :
      can(regex("^[a-z]([a-z0-9-]{0,61}[a-z0-9])?$", adb.autonomous_database_id))
    ])
    error_message = "Autonomous database IDs must start with a lowercase letter, end with a lowercase letter or number, contain only lowercase letters, numbers, and hyphens, and be 1-63 characters long."
  }

  validation {
    condition = alltrue([
      for adb in var.gcp_autonomous_databases_configuration :
      (adb.odb_network != null ? 1 : 0) + (adb.odb_network_key != null ? 1 : 0) == 1 &&
      (adb.odb_subnet != null ? 1 : 0) + (adb.odb_subnet_key != null ? 1 : 0) == 1
    ])
    error_message = "Each Autonomous Database must set exactly one ODB network reference and one ODB subnet reference, using either direct values or keys."
  }

  validation {
    condition = alltrue([
      for adb in var.gcp_autonomous_databases_configuration :
      !((adb.odb_network != null && adb.odb_network_key != null) ||
      (adb.odb_subnet != null && adb.odb_subnet_key != null))
    ])
    error_message = "Each Autonomous Database must set at most one of (odb_network, odb_network_key) and at most one of (odb_subnet, odb_subnet_key)."
  }

  validation {
    condition = alltrue([
      for adb in var.gcp_autonomous_databases_configuration :
      adb.odb_network == null ? true : can(regex("^projects/[^/]+/locations/[^/]+/odbNetworks/[^/]+$", adb.odb_network))
    ])
    error_message = "Autonomous database odb_network values must use projects/{project}/locations/{location}/odbNetworks/{odb_network} format."
  }

  validation {
    condition = alltrue([
      for adb in var.gcp_autonomous_databases_configuration :
      adb.odb_subnet == null ? true : can(regex("^projects/[^/]+/locations/[^/]+/odbNetworks/[^/]+/odbSubnets/[^/]+$", adb.odb_subnet))
    ])
    error_message = "Autonomous database odb_subnet values must use projects/{project}/locations/{location}/odbNetworks/{odb_network}/odbSubnets/{odb_subnet} format."
  }

  validation {
    condition = alltrue([
      for adb in var.gcp_autonomous_databases_configuration :
      adb.properties == null ? true : (
        adb.properties.db_workload == null ? true : contains(["DB_WORKLOAD_UNSPECIFIED", "OLTP", "DW", "AJD", "APEX"], adb.properties.db_workload)
      )
    ])
    error_message = "Autonomous database db_workload must be DB_WORKLOAD_UNSPECIFIED, OLTP, DW, AJD, or APEX when set."
  }

  validation {
    condition = alltrue([
      for adb in var.gcp_autonomous_databases_configuration :
      adb.properties == null ? true : (
        adb.properties.license_type == null ? true : contains(["LICENSE_TYPE_UNSPECIFIED", "LICENSE_INCLUDED", "BRING_YOUR_OWN_LICENSE"], adb.properties.license_type)
      )
    ])
    error_message = "Autonomous database license_type must be LICENSE_TYPE_UNSPECIFIED, LICENSE_INCLUDED, or BRING_YOUR_OWN_LICENSE when set."
  }

  validation {
    condition = alltrue([
      for adb in var.gcp_autonomous_databases_configuration :
      adb.properties == null ? true : (
        adb.properties.db_edition == null ? true : contains(["DATABASE_EDITION_UNSPECIFIED", "STANDARD_EDITION", "ENTERPRISE_EDITION"], adb.properties.db_edition)
      )
    ])
    error_message = "Autonomous database db_edition must be DATABASE_EDITION_UNSPECIFIED, STANDARD_EDITION, or ENTERPRISE_EDITION when set."
  }

  validation {
    condition = alltrue([
      for adb in var.gcp_autonomous_databases_configuration :
      adb.properties == null ? true : (
        adb.properties.maintenance_schedule_type == null ? true : contains(["MAINTENANCE_SCHEDULE_TYPE_UNSPECIFIED", "EARLY", "REGULAR"], adb.properties.maintenance_schedule_type)
      )
    ])
    error_message = "Autonomous database maintenance_schedule_type must be MAINTENANCE_SCHEDULE_TYPE_UNSPECIFIED, EARLY, or REGULAR when set."
  }

  validation {
    condition = alltrue([
      for adb in var.gcp_autonomous_databases_configuration :
      adb.properties == null ? true : (
        adb.properties.backup_retention_period_days == null ? true : (
          adb.properties.backup_retention_period_days >= 1 && adb.properties.backup_retention_period_days <= 60
        )
      )
    ])
    error_message = "Autonomous database backup_retention_period_days must be between 1 and 60 when set."
  }

  validation {
    condition = alltrue(flatten([
      for adb in var.gcp_autonomous_databases_configuration :
      adb.properties == null ? [true] : (
        adb.properties.customer_contacts == null ? [true] : [
          for contact in adb.properties.customer_contacts :
          can(regex("^[^@[:space:]]+@[^@[:space:]]+[.][^@[:space:]]+$", contact.email))
        ]
      )
    ]))
    error_message = "Autonomous database customer contact email values must be valid email addresses."
  }
}

variable "gcp_autonomous_databases_admin_passwords" {
  description = "Admin passwords for Autonomous Databases, keyed by the same keys as gcp_autonomous_databases_configuration. Kept separate from the configuration map to preserve Terraform's sensitive marking. Consider passing via the TF_VAR_gcp_autonomous_databases_admin_passwords environment variable instead of storing in tfvars files."
  type        = map(string)
  sensitive   = true
  default     = {}
  nullable    = false
}
