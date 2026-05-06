# Copyright (c) 2026, Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "module_name" {
  description = "Display name for this module instance."
  type        = string
  default     = "oracle-database-at-gcp"
  nullable    = false
}

variable "enable_output" {
  description = "Whether this module should emit resource outputs."
  type        = bool
  default     = true
  nullable    = false
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
  nullable    = false
}

variable "default_deletion_protection" {
  description = "Default deletion protection value for resources that support deletion_protection."
  type        = bool
  default     = true
  nullable    = false
}

variable "default_cloud_exadata_maintenance_window" {
  description = "Default maintenance window used by Cloud Exadata Infrastructure resources when properties.maintenance_window is not set."
  type = object({
    preference                       = optional(string)
    months                           = optional(list(string))
    weeks_of_month                   = optional(list(number))
    days_of_week                     = optional(list(string))
    hours_of_day                     = optional(list(number))
    lead_time_week                   = optional(number)
    patching_mode                    = optional(string)
    custom_action_timeout_mins       = optional(number)
    is_custom_action_timeout_enabled = optional(bool)
  })
  default = null

  validation {
    condition = var.default_cloud_exadata_maintenance_window == null ? true : (
      (var.default_cloud_exadata_maintenance_window.preference == null ? true : contains(["MAINTENANCE_WINDOW_PREFERENCE_UNSPECIFIED", "CUSTOM_PREFERENCE", "NO_PREFERENCE"], var.default_cloud_exadata_maintenance_window.preference)) &&
      (var.default_cloud_exadata_maintenance_window.months == null ? true : alltrue([
        for month in var.default_cloud_exadata_maintenance_window.months :
        contains(["MONTH_UNSPECIFIED", "JANUARY", "FEBRUARY", "MARCH", "APRIL", "MAY", "JUNE", "JULY", "AUGUST", "SEPTEMBER", "OCTOBER", "NOVEMBER", "DECEMBER"], month)
      ])) &&
      (var.default_cloud_exadata_maintenance_window.weeks_of_month == null ? true : alltrue([
        for week in var.default_cloud_exadata_maintenance_window.weeks_of_month :
        contains([1, 2, 3, 4], week)
      ])) &&
      (var.default_cloud_exadata_maintenance_window.days_of_week == null ? true : alltrue([
        for day in var.default_cloud_exadata_maintenance_window.days_of_week :
        contains(["DAY_OF_WEEK_UNSPECIFIED", "MONDAY", "TUESDAY", "WEDNESDAY", "THURSDAY", "FRIDAY", "SATURDAY", "SUNDAY"], day)
      ])) &&
      (var.default_cloud_exadata_maintenance_window.hours_of_day == null ? true : alltrue([
        for hour in var.default_cloud_exadata_maintenance_window.hours_of_day :
        contains([0, 4, 8, 12, 16, 20], hour)
      ])) &&
      (var.default_cloud_exadata_maintenance_window.lead_time_week == null ? true : var.default_cloud_exadata_maintenance_window.lead_time_week >= 1 && var.default_cloud_exadata_maintenance_window.lead_time_week <= 4) &&
      (var.default_cloud_exadata_maintenance_window.patching_mode == null ? true : contains(["PATCHING_MODE_UNSPECIFIED", "ROLLING", "NON_ROLLING"], var.default_cloud_exadata_maintenance_window.patching_mode)) &&
      (var.default_cloud_exadata_maintenance_window.custom_action_timeout_mins == null ? true : var.default_cloud_exadata_maintenance_window.custom_action_timeout_mins >= 15 && var.default_cloud_exadata_maintenance_window.custom_action_timeout_mins <= 120)
    )
    error_message = "default_cloud_exadata_maintenance_window values must use supported Oracle Database@Google Cloud enum values and documented ranges."
  }
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
    timeouts = optional(object({
      create = optional(string)
      update = optional(string)
      delete = optional(string)
    }))
  }))
  default  = {}
  nullable = false

  validation {
    condition = alltrue([
      for network in var.gcp_odb_networks_configuration :
      can(regex("^[a-z]([a-z0-9-]{0,61}[a-z0-9])?$", network.odb_network_id))
    ])
    error_message = "ODB network IDs must start with a lowercase letter, end with a lowercase letter or number, contain only lowercase letters, numbers, and hyphens, and be 1-63 characters long."
  }

  validation {
    condition = alltrue([
      for network in var.gcp_odb_networks_configuration :
      can(regex("^projects/[^/]+/global/networks/[^/]+$", network.network))
    ])
    error_message = "ODB network network values must use projects/{project}/global/networks/{network} format."
  }
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
    timeouts = optional(object({
      create = optional(string)
      update = optional(string)
      delete = optional(string)
    }))
  }))
  default  = {}
  nullable = false

  validation {
    condition = alltrue([
      for subnet in var.gcp_odb_subnets_configuration :
      can(regex("^[a-z]([a-z0-9-]{0,61}[a-z0-9])?$", subnet.odb_subnet_id))
    ])
    error_message = "ODB subnet IDs must start with a lowercase letter, end with a lowercase letter or number, contain only lowercase letters, numbers, and hyphens, and be 1-63 characters long."
  }

  validation {
    condition = alltrue([
      for subnet in var.gcp_odb_subnets_configuration :
      can(cidrnetmask(subnet.cidr_range))
    ])
    error_message = "ODB subnet cidr_range values must be valid CIDR blocks."
  }

  validation {
    condition = alltrue([
      for subnet in var.gcp_odb_subnets_configuration : contains(["CLIENT_SUBNET", "BACKUP_SUBNET"], subnet.purpose)
    ])
    error_message = "ODB subnet purpose must be either CLIENT_SUBNET or BACKUP_SUBNET."
  }

  validation {
    condition = alltrue([
      for subnet in var.gcp_odb_subnets_configuration :
      (subnet.odbnetwork != null ? 1 : 0) + (subnet.odb_network_key != null ? 1 : 0) == 1
    ])
    error_message = "Each ODB subnet must set exactly one of odbnetwork or odb_network_key."
  }

  validation {
    condition = alltrue([
      for subnet in var.gcp_odb_subnets_configuration :
      subnet.odbnetwork == null ? true : can(regex("^[a-z]([a-z0-9-]{0,61}[a-z0-9])?$", subnet.odbnetwork))
    ])
    error_message = "Direct ODB subnet odbnetwork values must be ODB network ID segments, for example my-odb-network."
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
    timeouts = optional(object({
      create = optional(string)
      update = optional(string)
      delete = optional(string)
    }))
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
  default  = {}
  nullable = false

  validation {
    condition = alltrue([
      for infrastructure in var.gcp_cloud_exadata_infrastructures_configuration :
      can(regex("^[a-z]([a-z0-9-]{0,61}[a-z0-9])?$", infrastructure.cloud_exadata_infrastructure_id))
    ])
    error_message = "Cloud Exadata Infrastructure IDs must start with a lowercase letter, end with a lowercase letter or number, contain only lowercase letters, numbers, and hyphens, and be 1-63 characters long."
  }

  validation {
    condition = alltrue([
      for infrastructure in var.gcp_cloud_exadata_infrastructures_configuration :
      (infrastructure.properties.compute_count == null ? true : infrastructure.properties.compute_count > 0) &&
      (infrastructure.properties.storage_count == null ? true : infrastructure.properties.storage_count > 0) &&
      (infrastructure.properties.total_storage_size_gb == null ? true : infrastructure.properties.total_storage_size_gb > 0)
    ])
    error_message = "Cloud Exadata Infrastructure numeric capacity values must be positive when set."
  }

  validation {
    condition = alltrue(flatten([
      for infrastructure in var.gcp_cloud_exadata_infrastructures_configuration : [
        for contact in coalesce(infrastructure.properties.customer_contacts, []) :
        can(regex("^[^@[:space:]]+@[^@[:space:]]+[.][^@[:space:]]+$", contact.email))
      ]
    ]))
    error_message = "Cloud Exadata Infrastructure customer contact email values must be valid email addresses."
  }

  validation {
    condition = alltrue([
      for infrastructure in var.gcp_cloud_exadata_infrastructures_configuration :
      infrastructure.properties.maintenance_window == null ? true : (
        (infrastructure.properties.maintenance_window.preference == null ? true : contains(["MAINTENANCE_WINDOW_PREFERENCE_UNSPECIFIED", "CUSTOM_PREFERENCE", "NO_PREFERENCE"], infrastructure.properties.maintenance_window.preference)) &&
        (infrastructure.properties.maintenance_window.months == null ? true : alltrue([
          for month in infrastructure.properties.maintenance_window.months :
          contains(["MONTH_UNSPECIFIED", "JANUARY", "FEBRUARY", "MARCH", "APRIL", "MAY", "JUNE", "JULY", "AUGUST", "SEPTEMBER", "OCTOBER", "NOVEMBER", "DECEMBER"], month)
        ])) &&
        (infrastructure.properties.maintenance_window.weeks_of_month == null ? true : alltrue([
          for week in infrastructure.properties.maintenance_window.weeks_of_month :
          contains([1, 2, 3, 4], week)
        ])) &&
        (infrastructure.properties.maintenance_window.days_of_week == null ? true : alltrue([
          for day in infrastructure.properties.maintenance_window.days_of_week :
          contains(["DAY_OF_WEEK_UNSPECIFIED", "MONDAY", "TUESDAY", "WEDNESDAY", "THURSDAY", "FRIDAY", "SATURDAY", "SUNDAY"], day)
        ])) &&
        (infrastructure.properties.maintenance_window.hours_of_day == null ? true : alltrue([
          for hour in infrastructure.properties.maintenance_window.hours_of_day :
          contains([0, 4, 8, 12, 16, 20], hour)
        ])) &&
        (infrastructure.properties.maintenance_window.lead_time_week == null ? true : infrastructure.properties.maintenance_window.lead_time_week >= 1 && infrastructure.properties.maintenance_window.lead_time_week <= 4) &&
        (infrastructure.properties.maintenance_window.patching_mode == null ? true : contains(["PATCHING_MODE_UNSPECIFIED", "ROLLING", "NON_ROLLING"], infrastructure.properties.maintenance_window.patching_mode)) &&
        (infrastructure.properties.maintenance_window.custom_action_timeout_mins == null ? true : infrastructure.properties.maintenance_window.custom_action_timeout_mins >= 15 && infrastructure.properties.maintenance_window.custom_action_timeout_mins <= 120)
      )
    ])
    error_message = "Cloud Exadata Infrastructure maintenance_window values must use supported Oracle Database@Google Cloud enum values and documented ranges."
  }
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
    timeouts = optional(object({
      create = optional(string)
      update = optional(string)
      delete = optional(string)
    }))

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
      license_type             = string
      gi_version               = optional(string)
      ssh_public_keys          = optional(list(string))
      node_count               = optional(number)
      ocpu_count               = optional(number)
      memory_size_gb           = optional(number)
      db_node_storage_size_gb  = optional(number)
      data_storage_size_tb     = optional(number)
      disk_redundancy          = optional(string)
      sparse_diskgroup_enabled = optional(bool)
      local_backup_enabled     = optional(bool)
      hostname_prefix          = optional(string)
      cpu_core_count           = number
      db_server_ocids          = optional(list(string))
      cluster_name             = optional(string)
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
  default  = {}
  nullable = false

  validation {
    condition = alltrue([
      for cluster in var.gcp_cloud_vm_clusters_configuration :
      can(regex("^[a-z]([a-z0-9-]{0,61}[a-z0-9])?$", cluster.cloud_vm_cluster_id))
    ])
    error_message = "Cloud VM cluster IDs must start with a lowercase letter, end with a lowercase letter or number, contain only lowercase letters, numbers, and hyphens, and be 1-63 characters long."
  }

  validation {
    condition = alltrue([
      for cluster in var.gcp_cloud_vm_clusters_configuration :
      (cluster.exadata_infrastructure != null ? 1 : 0) + (cluster.exadata_infrastructure_key != null ? 1 : 0) == 1
    ])
    error_message = "Each Cloud VM cluster must set exactly one of exadata_infrastructure or exadata_infrastructure_key."
  }

  validation {
    condition = alltrue([
      for cluster in var.gcp_cloud_vm_clusters_configuration :
      (
        (
          cluster.network != null &&
          cluster.cidr != null &&
          cluster.backup_subnet_cidr != null &&
          cluster.odb_network == null &&
          cluster.odb_network_key == null &&
          cluster.odb_subnet == null &&
          cluster.odb_subnet_key == null &&
          cluster.backup_odb_subnet == null &&
          cluster.backup_odb_subnet_key == null
        ) ||
        (
          cluster.network == null &&
          cluster.cidr == null &&
          cluster.backup_subnet_cidr == null &&
          (cluster.odb_network != null ? 1 : 0) + (cluster.odb_network_key != null ? 1 : 0) <= 1 &&
          (cluster.odb_subnet != null ? 1 : 0) + (cluster.odb_subnet_key != null ? 1 : 0) == 1 &&
          (cluster.backup_odb_subnet != null ? 1 : 0) + (cluster.backup_odb_subnet_key != null ? 1 : 0) == 1
        )
      )
    ])
    error_message = "Each Cloud VM cluster must use exactly one networking mode: either network/cidr/backup_subnet_cidr, or ODB subnet references."
  }

  validation {
    condition = alltrue([
      for cluster in var.gcp_cloud_vm_clusters_configuration :
      (cluster.cidr == null ? true : can(cidrnetmask(cluster.cidr))) &&
      (cluster.backup_subnet_cidr == null ? true : can(cidrnetmask(cluster.backup_subnet_cidr)))
    ])
    error_message = "Cloud VM cluster cidr and backup_subnet_cidr values must be valid CIDR blocks when set."
  }

  validation {
    condition = alltrue([
      for cluster in var.gcp_cloud_vm_clusters_configuration :
      (cluster.network == null ? true : can(regex("^projects/[^/]+/global/networks/[^/]+$", cluster.network))) &&
      (cluster.exadata_infrastructure == null ? true : can(regex("^projects/[^/]+/locations/[^/]+/cloudExadataInfrastructures/[^/]+$", cluster.exadata_infrastructure))) &&
      (cluster.odb_network == null ? true : can(regex("^projects/[^/]+/locations/[^/]+/odbNetworks/[^/]+$", cluster.odb_network))) &&
      (cluster.odb_subnet == null ? true : can(regex("^projects/[^/]+/locations/[^/]+/odbNetworks/[^/]+/odbSubnets/[^/]+$", cluster.odb_subnet))) &&
      (cluster.backup_odb_subnet == null ? true : can(regex("^projects/[^/]+/locations/[^/]+/odbNetworks/[^/]+/odbSubnets/[^/]+$", cluster.backup_odb_subnet)))
    ])
    error_message = "Direct Cloud VM cluster resource references must use the full resource name formats documented by the Google provider."
  }

  validation {
    condition = alltrue([
      for cluster in var.gcp_cloud_vm_clusters_configuration :
      contains(["LICENSE_TYPE_UNSPECIFIED", "LICENSE_INCLUDED", "BRING_YOUR_OWN_LICENSE"], cluster.properties.license_type)
    ])
    error_message = "Cloud VM cluster license_type must be LICENSE_TYPE_UNSPECIFIED, LICENSE_INCLUDED, or BRING_YOUR_OWN_LICENSE."
  }

  validation {
    condition = alltrue([
      for cluster in var.gcp_cloud_vm_clusters_configuration :
      cluster.properties.cpu_core_count > 0 &&
      (cluster.properties.node_count == null ? true : cluster.properties.node_count > 0) &&
      (cluster.properties.ocpu_count == null ? true : cluster.properties.ocpu_count >= 0.1) &&
      (cluster.properties.memory_size_gb == null ? true : cluster.properties.memory_size_gb > 0) &&
      (cluster.properties.db_node_storage_size_gb == null ? true : cluster.properties.db_node_storage_size_gb > 0) &&
      (cluster.properties.data_storage_size_tb == null ? true : cluster.properties.data_storage_size_tb > 0)
    ])
    error_message = "Cloud VM cluster capacity values must be positive when set; ocpu_count must be at least 0.1."
  }

  validation {
    condition = alltrue([
      for cluster in var.gcp_cloud_vm_clusters_configuration :
      cluster.properties.disk_redundancy == null ? true : contains(["DISK_REDUNDANCY_UNSPECIFIED", "HIGH", "NORMAL"], cluster.properties.disk_redundancy)
    ])
    error_message = "Cloud VM cluster disk_redundancy must be DISK_REDUNDANCY_UNSPECIFIED, HIGH, or NORMAL when set."
  }

  validation {
    condition = alltrue([
      for cluster in var.gcp_cloud_vm_clusters_configuration :
      cluster.properties.hostname_prefix == null ? true : can(regex("^[a-zA-Z][a-zA-Z0-9-]{0,11}$", cluster.properties.hostname_prefix))
    ])
    error_message = "Cloud VM cluster hostname_prefix must start with a letter, contain only letters, numbers, and hyphens, and be 1-12 characters long."
  }

  validation {
    condition = alltrue([
      for cluster in var.gcp_cloud_vm_clusters_configuration :
      cluster.properties.ssh_public_keys == null ? true : alltrue([
        for key in cluster.properties.ssh_public_keys : length(trimspace(key)) > 0
      ])
    ])
    error_message = "Cloud VM cluster ssh_public_keys entries must be non-empty strings."
  }
}
