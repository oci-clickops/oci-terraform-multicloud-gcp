# Copyright (c) 2026, Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "project_id" { description = "GCP project ID enabled for Oracle Database@Google Cloud." }
variable "location"   { description = "GCP region for Oracle Database@Google Cloud resources." }

variable "gcp_oracle_zone" {
  type    = any
  default = null
}

variable "default_labels" {
  type    = any
  default = null
}

variable "default_deletion_protection" {
  type    = any
  default = false
}

variable "output_path" { default = null }

variable "ssh_public_keys_file_path" {
  description = "Path to SSH public key file for VM cluster access."
  type        = string
  default     = null
}

variable "default_cloud_exadata_maintenance_window" {
  type    = any
  default = null
}

variable "gcp_odb_networks_configuration" {
  type    = any
  default = null
}

variable "gcp_odb_subnets_configuration" {
  type    = any
  default = null
}

variable "gcp_cloud_exadata_infrastructures_configuration" {
  type    = any
  default = null
}

variable "gcp_cloud_vm_clusters_configuration" {
  type    = any
  default = null
}
