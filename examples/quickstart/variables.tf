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

variable "odb_network_id" {
  description = "ODB network ID to create."
  type        = string
  default     = "quickstart-odb-network"
}

variable "client_odb_subnet_id" {
  description = "Client ODB subnet ID to create."
  type        = string
  default     = "quickstart-client"
}

variable "client_odb_subnet_cidr_range" {
  description = "CIDR range for the client ODB subnet."
  type        = string
  default     = "192.168.1.0/24"
}

variable "backup_odb_subnet_id" {
  description = "Backup ODB subnet ID to create."
  type        = string
  default     = "quickstart-backup"
}

variable "backup_odb_subnet_cidr_range" {
  description = "CIDR range for the backup ODB subnet."
  type        = string
  default     = "192.168.2.0/28"
}

variable "cloud_exadata_infrastructure_id" {
  description = "Cloud Exadata Infrastructure ID to create."
  type        = string
  default     = "quickstart-exadata"
}

variable "exadata_shape" {
  description = "Cloud Exadata Infrastructure shape."
  type        = string
  default     = "Exadata.X11M"
}

variable "compute_count" {
  description = "Cloud Exadata Infrastructure compute server count."
  type        = number
  default     = 2
}

variable "storage_count" {
  description = "Cloud Exadata Infrastructure storage server count."
  type        = number
  default     = 3
}

variable "customer_contact_email" {
  description = "Customer contact email for Exadata infrastructure maintenance notifications."
  type        = string
}

variable "cloud_vm_cluster_id" {
  description = "Cloud VM Cluster ID to create."
  type        = string
  default     = "quickstart-vm-cluster"
}

variable "license_type" {
  description = "License type for the Cloud VM Cluster."
  type        = string
  default     = "LICENSE_INCLUDED"
}

variable "cpu_core_count" {
  description = "Number of enabled CPU cores for the Cloud VM Cluster."
  type        = number
  default     = 4
}

variable "gi_version" {
  description = "Grid Infrastructure version for the Cloud VM Cluster."
  type        = string
  default     = "19.0.0.0"
}

variable "hostname_prefix" {
  description = "Hostname prefix for VM cluster host names."
  type        = string
  default     = "exa"
}

variable "ssh_public_keys" {
  description = "SSH public keys for VM cluster access."
  type        = list(string)
}
