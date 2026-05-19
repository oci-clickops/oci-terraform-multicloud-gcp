# Copyright (c) 2026, Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "project_id" { description = "GCP project ID enabled for Oracle Database@Google Cloud." }
variable "location" { description = "GCP region for Oracle Database@Google Cloud resources." }

variable "module_name" {
  type    = string
  default = "oracle-database-at-gcp"
}

variable "enable_output" {
  type    = bool
  default = true
}

variable "output_path" { default = null }

variable "ssh_public_keys_file_path" {
  description = "Path to SSH public key file for VM cluster access."
  type        = string
  default     = null
}

variable "default_labels" {
  type    = any
  default = null
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

variable "gcp_cloud_exadata_infrastructures_dependency" {
  type    = map(any)
  default = null
}

variable "gcp_cloud_exadata_infrastructures_dependency_file_path" {
  description = "Optional local JSON file path containing gcp_cloud_exadata_infrastructures dependency output from an upstream stack. Use only when gcp_cloud_exadata_infrastructures_dependency is not set."
  type        = string
  default     = null

  validation {
    condition     = var.gcp_cloud_exadata_infrastructures_dependency_file_path == null ? true : trimspace(var.gcp_cloud_exadata_infrastructures_dependency_file_path) != ""
    error_message = "gcp_cloud_exadata_infrastructures_dependency_file_path must be null or a non-empty file path."
  }
}

variable "gcp_cloud_vm_clusters_configuration" {
  type    = any
  default = null
}
