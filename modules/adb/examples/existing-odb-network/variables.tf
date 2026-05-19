# Copyright (c) 2026, Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "project_id" { description = "GCP project ID enabled for Oracle Database@Google Cloud." }
variable "location" { description = "GCP region for Oracle Database@Google Cloud resources." }

variable "gcp_autonomous_databases_admin_passwords" {
  description = "Admin passwords for Autonomous Databases, keyed by the same keys as gcp_autonomous_databases_configuration."
  type        = map(string)
  sensitive   = true
  default     = {}
}

variable "default_labels" {
  type    = any
  default = {}
}

variable "default_deletion_protection" {
  type    = any
  default = false
}

variable "gcp_odb_networks_dependency" {
  type    = map(any)
  default = null
}

variable "gcp_odb_networks_dependency_file_path" {
  description = "Optional local JSON file path containing gcp_odb_networks dependency output from an upstream stack. Use only when gcp_odb_networks_dependency is not set."
  type        = string
  default     = null

  validation {
    condition     = var.gcp_odb_networks_dependency_file_path == null ? true : trimspace(var.gcp_odb_networks_dependency_file_path) != ""
    error_message = "gcp_odb_networks_dependency_file_path must be null or a non-empty file path."
  }
}

variable "gcp_odb_subnets_dependency" {
  type    = map(any)
  default = null
}

variable "gcp_odb_subnets_dependency_file_path" {
  description = "Optional local JSON file path containing gcp_odb_subnets dependency output from an upstream stack. Use only when gcp_odb_subnets_dependency is not set."
  type        = string
  default     = null

  validation {
    condition     = var.gcp_odb_subnets_dependency_file_path == null ? true : trimspace(var.gcp_odb_subnets_dependency_file_path) != ""
    error_message = "gcp_odb_subnets_dependency_file_path must be null or a non-empty file path."
  }
}

variable "gcp_autonomous_databases_configuration" {
  type    = any
  default = {}
}
