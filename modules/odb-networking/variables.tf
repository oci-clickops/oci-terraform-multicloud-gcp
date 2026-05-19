# Copyright (c) 2026, Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "module_name" {
  description = "Display name for this module instance."
  type        = string
  default     = "oracle-database-networking-at-gcp"
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

variable "default_gcp_oracle_zone" {
  description = "Default GCP Oracle zone used by ODB Network resources when gcp_oracle_zone is not set."
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

  validation {
    condition = alltrue([
      for subnet in var.gcp_odb_subnets_configuration : (
        (subnet.odbnetwork == null || trimspace(subnet.odbnetwork) != "") &&
        (subnet.odb_network_key == null || trimspace(subnet.odb_network_key) != "")
      )
    ])
    error_message = "ODB subnet odbnetwork and odb_network_key must not be empty when set."
  }
}
