# Copyright (c) 2026, Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "project_id" {
  type = string
}

variable "location" {
  type = string
}

variable "gcp_oracle_zone" {
  type = string
}

variable "network" {
  description = "VPC network self link in projects/{project}/global/networks/{network} format."
  type        = string
}

variable "odb_network_id" {
  type    = string
  default = "primary-odb-network"
}

variable "client_odb_subnet_id" {
  type    = string
  default = "client-subnet"
}

variable "client_odb_subnet_cidr_range" {
  type    = string
  default = "192.168.1.0/24"
}

variable "backup_odb_subnet_id" {
  type    = string
  default = "backup-subnet"
}

variable "backup_odb_subnet_cidr_range" {
  type    = string
  default = "192.168.2.0/28"
}

variable "cloud_exadata_infrastructure_id" {
  type    = string
  default = "primary-exadata"
}

variable "exadata_shape" {
  type    = string
  default = "Exadata.X11M"
}

variable "compute_count" {
  type    = number
  default = 2
}

variable "storage_count" {
  type    = number
  default = 3
}

variable "customer_contact_email" {
  type = string
}

variable "cloud_vm_cluster_id" {
  type    = string
  default = "primary-vm-cluster"
}

variable "license_type" {
  type    = string
  default = "LICENSE_INCLUDED"
}

variable "cpu_core_count" {
  type    = number
  default = 4
}

variable "gi_version" {
  type    = string
  default = "19.0.0.0"
}

variable "hostname_prefix" {
  type    = string
  default = "exa"
}

variable "ssh_public_keys" {
  type = list(string)
}
