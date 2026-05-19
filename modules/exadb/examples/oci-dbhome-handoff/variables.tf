# Copyright (c) 2026, Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "tenancy_ocid" {
  description = "OCI tenancy OCID."
  type        = string
}

variable "region" {
  description = "OCI region for DB Home, CDB, and PDB operations. Use the OCI region of the VM Cluster OCID."
  type        = string
}

variable "user_ocid" {
  description = "OCI user OCID for API-key authentication."
  type        = string
  default     = ""
}

variable "fingerprint" {
  description = "OCI API key fingerprint."
  type        = string
  default     = ""
}

variable "private_key_path" {
  description = "Path to the OCI API signing private key."
  type        = string
  default     = ""
}

variable "private_key_password" {
  description = "Password for the OCI API signing private key, when encrypted."
  type        = string
  default     = ""
  sensitive   = true
}

variable "gcp_cloud_vm_clusters_dependency" {
  description = "Optional inline dependency map from modules/exadb output gcp_cloud_vm_clusters. Accepts direct or wrapped shape."
  type        = any
  default     = null

  validation {
    condition = var.gcp_cloud_vm_clusters_dependency == null ? true : (
      !can(tostring(var.gcp_cloud_vm_clusters_dependency))
    )
    error_message = "gcp_cloud_vm_clusters_dependency must be a map, not a JSON file path string. Use gcp_cloud_vm_clusters_dependency_file_path in this wrapper for file handoff."
  }
}

variable "gcp_cloud_vm_clusters_dependency_file_path" {
  description = "Optional local JSON file path containing gcp_cloud_vm_clusters output from the GCP VM Cluster stack. Use only when gcp_cloud_vm_clusters_dependency is not set."
  type        = string
  default     = null

  validation {
    condition     = var.gcp_cloud_vm_clusters_dependency_file_path == null ? true : trimspace(var.gcp_cloud_vm_clusters_dependency_file_path) != ""
    error_message = "gcp_cloud_vm_clusters_dependency_file_path must be null or a non-empty file path."
  }
}

variable "compartments_dependency" {
  description = "OCI compartments dependency map passed through to terraform-oci-modules-exadata."
  type        = any
  default     = null
}

variable "subscription_dependency" {
  description = "OCI subscriptions dependency map passed through to terraform-oci-modules-exadata."
  type        = any
  default     = null
}

variable "network_dependency" {
  description = "OCI network dependency map passed through to terraform-oci-modules-exadata when downstream database configuration needs OCI networking references."
  type        = any
  default     = null
}

variable "default_compartment_id" {
  description = "Default OCI compartment OCID or key in compartments_dependency."
  type        = any
  default     = null
}

variable "default_defined_tags" {
  description = "Default OCI defined tags passed through to terraform-oci-modules-exadata."
  type        = any
  default     = {}
}

variable "default_freeform_tags" {
  description = "Default OCI freeform tags passed through to terraform-oci-modules-exadata."
  type        = any
  default     = {}
}

variable "cloud_db_homes_configuration" {
  description = "OCI DB Home configuration. Each entry must set exactly one of vm_cluster_id or wrapper-only vm_cluster_key."
  type        = any
  default     = null
}

variable "databases_configuration" {
  description = "OCI CDB configuration passed through to terraform-oci-modules-exadata."
  type        = any
  default     = null
}

variable "pluggable_databases_configuration" {
  description = "OCI PDB configuration passed through to terraform-oci-modules-exadata."
  type        = any
  default     = null
}
