# Copyright (c) 2026, Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "project_id" {
  description = "Google Cloud project ID enabled for Oracle Database@Google Cloud."
  type        = string
}

variable "location" {
  description = "Google Cloud region for Oracle Database@Google Cloud resources."
  type        = string
}

variable "gcp_oracle_zone" {
  description = "GCP Oracle zone for resources that require it."
  type        = string
}

variable "network" {
  description = "VPC network resource name in projects/{project}/global/networks/{network} format."
  type        = string
}

variable "labels" {
  description = "Labels to apply to resources."
  type        = map(string)
  default = {
    terraform = "true"
    example   = "basic"
  }
}

variable "deletion_protection" {
  description = "Whether deletion protection is enabled for resources."
  type        = bool
  default     = false
}

variable "output_path" {
  description = "Optional directory where dependency JSON files are written after apply."
  type        = string
  default     = null
}

variable "odb_network_id" {
  description = "ODB network ID to create."
  type        = string
  default     = "primary-odb-network"
}

variable "odb_network_location" {
  description = "Optional region override for the ODB network."
  type        = string
  default     = null
}

variable "odb_network_project_id" {
  description = "Optional project override for the ODB network."
  type        = string
  default     = null
}

variable "odb_network_gcp_oracle_zone" {
  description = "Optional GCP Oracle zone override for the ODB network."
  type        = string
  default     = null
}

variable "odb_network_labels" {
  description = "Labels for the ODB network."
  type        = map(string)
  default     = {}
}

variable "odb_network_deletion_protection" {
  description = "Whether deletion protection is enabled for the ODB network."
  type        = bool
  default     = false
}

variable "odb_network_timeouts" {
  description = "Provider operation timeouts for the ODB network."
  type = object({
    create = optional(string)
    update = optional(string)
    delete = optional(string)
  })
  default = {
    create = "90m"
    update = "60m"
    delete = "60m"
  }
}

variable "client_odb_subnet_id" {
  description = "Client ODB subnet ID to create."
  type        = string
  default     = "client-subnet"
}

variable "client_odb_subnet_cidr_range" {
  description = "CIDR range for the client ODB subnet."
  type        = string
  default     = "192.168.1.0/24"
}

variable "client_odb_subnet_location" {
  description = "Optional region override for the client ODB subnet."
  type        = string
  default     = null
}

variable "client_odb_subnet_project_id" {
  description = "Optional project override for the client ODB subnet."
  type        = string
  default     = null
}

variable "client_odb_subnet_labels" {
  description = "Labels for the client ODB subnet."
  type        = map(string)
  default     = {}
}

variable "client_odb_subnet_deletion_protection" {
  description = "Whether deletion protection is enabled for the client ODB subnet."
  type        = bool
  default     = false
}

variable "client_odb_subnet_timeouts" {
  description = "Provider operation timeouts for the client ODB subnet."
  type = object({
    create = optional(string)
    update = optional(string)
    delete = optional(string)
  })
  default = {
    create = "90m"
    update = "60m"
    delete = "60m"
  }
}

variable "backup_odb_subnet_id" {
  description = "Backup ODB subnet ID to create."
  type        = string
  default     = "backup-subnet"
}

variable "backup_odb_subnet_cidr_range" {
  description = "CIDR range for the backup ODB subnet."
  type        = string
  default     = "192.168.2.0/28"
}

variable "backup_odb_subnet_location" {
  description = "Optional region override for the backup ODB subnet."
  type        = string
  default     = null
}

variable "backup_odb_subnet_project_id" {
  description = "Optional project override for the backup ODB subnet."
  type        = string
  default     = null
}

variable "backup_odb_subnet_labels" {
  description = "Labels for the backup ODB subnet."
  type        = map(string)
  default     = {}
}

variable "backup_odb_subnet_deletion_protection" {
  description = "Whether deletion protection is enabled for the backup ODB subnet."
  type        = bool
  default     = false
}

variable "backup_odb_subnet_timeouts" {
  description = "Provider operation timeouts for the backup ODB subnet."
  type = object({
    create = optional(string)
    update = optional(string)
    delete = optional(string)
  })
  default = {
    create = "90m"
    update = "60m"
    delete = "60m"
  }
}
