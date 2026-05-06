# Copyright (c) 2026, Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "project_id" {
  description = "Google Cloud project ID where the Oracle Database@Google Cloud resources exist."
  type        = string
}

variable "location" {
  description = "Google Cloud region for the existing infrastructure and ODB network."
  type        = string
}

variable "cloud_vm_cluster_id" {
  description = "ID to assign to the new Cloud VM Cluster."
  type        = string
}

variable "exadata_infrastructure" {
  description = "Existing Cloud Exadata Infrastructure full resource name."
  type        = string
}

variable "odb_network" {
  description = "Existing ODB network full resource name."
  type        = string
}

variable "odb_subnet" {
  description = "Existing client ODB subnet full resource name."
  type        = string
}

variable "backup_odb_subnet" {
  description = "Existing backup ODB subnet full resource name."
  type        = string
}

variable "license_type" {
  description = "Cloud VM Cluster license type."
  type        = string
  default     = "BRING_YOUR_OWN_LICENSE"

  validation {
    condition     = contains(["LICENSE_INCLUDED", "BRING_YOUR_OWN_LICENSE"], var.license_type)
    error_message = "license_type must be LICENSE_INCLUDED or BRING_YOUR_OWN_LICENSE."
  }
}

variable "cpu_core_count" {
  description = "Number of enabled CPU cores for the Cloud VM Cluster."
  type        = number
  default     = 2

  validation {
    condition     = var.cpu_core_count > 0
    error_message = "cpu_core_count must be greater than zero."
  }
}

variable "gi_version" {
  description = "Grid Infrastructure version for the Cloud VM Cluster."
  type        = string
  default     = "19.0.0.0"
}

variable "hostname_prefix" {
  description = "Hostname prefix for the Cloud VM Cluster."
  type        = string
  default     = "exa"
}

variable "ssh_public_keys" {
  description = "SSH public keys authorized for the Cloud VM Cluster."
  type        = list(string)

  validation {
    condition = alltrue([
      for key in var.ssh_public_keys : length(trimspace(key)) > 0
    ])
    error_message = "ssh_public_keys entries must be non-empty strings."
  }
}
