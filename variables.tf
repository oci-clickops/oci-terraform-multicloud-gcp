# Copyright (c) 2026, Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "module_name" {
  description = "Display name for this module instance."
  type        = string
  default     = "oracle-database-at-gcp"
}

variable "enable_output" {
  description = "Whether this module should emit resource outputs."
  type        = bool
  default     = true
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

variable "default_gcp_oracle_zone" {
  description = "Default GCP Oracle zone used by resources that support it."
  type        = string
  default     = null
}

variable "default_labels" {
  description = "Default labels merged into all resources. Resource-specific labels win on key collisions."
  type        = map(string)
  default     = {}
}

variable "default_deletion_protection" {
  description = "Default deletion protection value for resources that support deletion_protection."
  type        = bool
  default     = true
}

variable "gcp_odb_networks_configuration" {
  description = "Map of Oracle Database@Google Cloud ODB networks to create."
  type = map(object({
    odb_network_id      = string
    network             = string
    location            = optional(string)
    project_id          = optional(string)
    gcp_oracle_zone     = optional(string)
    labels              = optional(map(string), {})
    deletion_protection = optional(bool)
  }))
  default = {}
}

variable "gcp_odb_subnets_configuration" {
  description = "Map of Oracle Database@Google Cloud ODB subnets to create."
  type = map(object({
    odb_subnet_id       = string
    cidr_range          = string
    purpose             = string
    odbnetwork          = optional(string)
    odb_network_key     = optional(string)
    location            = optional(string)
    project_id          = optional(string)
    labels              = optional(map(string), {})
    deletion_protection = optional(bool)
  }))
  default = {}

  validation {
    condition = alltrue([
      for subnet in var.gcp_odb_subnets_configuration : contains(["CLIENT_SUBNET", "BACKUP_SUBNET"], subnet.purpose)
    ])
    error_message = "ODB subnet purpose must be either CLIENT_SUBNET or BACKUP_SUBNET."
  }
}

variable "gcp_cloud_exadata_infrastructures_configuration" {
  description = "Map of Oracle Database@Google Cloud Exadata infrastructures to create."
  type = map(object({
    cloud_exadata_infrastructure_id = string
    display_name                    = optional(string)
    location                        = optional(string)
    project_id                      = optional(string)
    gcp_oracle_zone                 = optional(string)
    labels                          = optional(map(string), {})
    deletion_protection             = optional(bool)
    properties = object({
      shape                 = string
      compute_count         = optional(number)
      storage_count         = optional(number)
      total_storage_size_gb = optional(number)
      customer_contacts = optional(list(object({
        email = string
      })), [])
      maintenance_window = optional(object({
        preference                       = optional(string)
        months                           = optional(list(string))
        weeks_of_month                   = optional(list(number))
        days_of_week                     = optional(list(string))
        hours_of_day                     = optional(list(number))
        lead_time_week                   = optional(number)
        patching_mode                    = optional(string)
        custom_action_timeout_mins       = optional(number)
        is_custom_action_timeout_enabled = optional(bool)
      }))
    })
  }))
  default = {}
}

variable "gcp_cloud_vm_clusters_configuration" {
  description = "Map of Oracle Database@Google Cloud VM clusters to create."
  type = map(object({
    cloud_vm_cluster_id = string
    display_name        = optional(string)
    location            = optional(string)
    project_id          = optional(string)
    labels              = optional(map(string), {})
    deletion_protection = optional(bool)

    exadata_infrastructure     = optional(string)
    exadata_infrastructure_key = optional(string)

    network            = optional(string)
    cidr               = optional(string)
    backup_subnet_cidr = optional(string)

    odb_network           = optional(string)
    odb_network_key       = optional(string)
    odb_subnet            = optional(string)
    odb_subnet_key        = optional(string)
    backup_odb_subnet     = optional(string)
    backup_odb_subnet_key = optional(string)

    properties = object({
      license_type               = string
      gi_version                 = optional(string)
      ssh_public_keys            = optional(list(string))
      node_count                 = optional(number)
      ocpu_count                 = optional(number)
      memory_size_gb             = optional(number)
      db_node_storage_size_gb    = optional(number)
      data_storage_size_tb       = optional(number)
      disk_redundancy            = optional(string)
      sparse_diskgroup_enabled   = optional(bool)
      local_backup_enabled       = optional(bool)
      hostname_prefix            = optional(string)
      cpu_core_count             = number
      db_server_ocids            = optional(list(string))
      cluster_name               = optional(string)
      scan_listener_port_tcp     = optional(number)
      scan_listener_port_tcp_ssl = optional(number)
      time_zone = optional(object({
        id      = optional(string)
        version = optional(string)
      }))
      diagnostics_data_collection_options = optional(object({
        diagnostics_events_enabled = optional(bool)
        health_monitoring_enabled  = optional(bool)
        incident_logs_enabled      = optional(bool)
      }))
    })
  }))
  default = {}
}
