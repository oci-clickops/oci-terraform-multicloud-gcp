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

variable "gcp_odb_networks_dependency" {
  description = "ODB network dependency map or path to a JSON dependency file produced by the networking stack."
  type        = any
  default     = "./dependencies/gcp_odb_networks_output.json"
}

variable "gcp_odb_subnets_dependency" {
  description = "ODB subnet dependency map or path to a JSON dependency file produced by the networking stack."
  type        = any
  default     = "./dependencies/gcp_odb_subnets_output.json"
}

variable "exadata_infrastructure" {
  description = "Existing Cloud Exadata Infrastructure full resource name."
  type        = string
}

variable "odb_network_key" {
  description = "Key of the ODB network in the networking dependency output."
  type        = string
  default     = "primary"
}

variable "odb_subnet_key" {
  description = "Key of the client ODB subnet in the networking dependency output."
  type        = string
  default     = "client"
}

variable "backup_odb_subnet_key" {
  description = "Key of the backup ODB subnet in the networking dependency output."
  type        = string
  default     = "backup"
}

variable "cloud_vm_cluster_id" {
  description = "ID to assign to the new Cloud VM Cluster."
  type        = string
}

variable "display_name" {
  description = "Display name for the Cloud VM Cluster."
  type        = string
  default     = null
}

variable "labels" {
  description = "Labels to apply to the Cloud VM Cluster."
  type        = map(string)
  default = {
    terraform = "true"
    example   = "state-handoff-vm-cluster"
  }
}

variable "deletion_protection" {
  description = "Whether deletion protection is enabled for the Cloud VM Cluster."
  type        = bool
  default     = false
}

variable "timeouts" {
  description = "Provider operation timeouts for the Cloud VM Cluster."
  type = object({
    create = optional(string)
    update = optional(string)
    delete = optional(string)
  })
  default = {
    create = "180m"
    update = "90m"
    delete = "90m"
  }
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
  default     = 4

  validation {
    condition     = var.cpu_core_count >= 4
    error_message = "cpu_core_count must be at least 4 for this example configuration."
  }
}

variable "node_count" {
  description = "Number of VMs in the Cloud VM Cluster."
  type        = number
  default     = 2

  validation {
    condition     = var.node_count >= 2
    error_message = "node_count must be at least 2 for this example configuration."
  }
}

variable "ocpu_count" {
  description = "Number of enabled OCPUs per VM."
  type        = number
  default     = 2

  validation {
    condition     = var.ocpu_count >= 2
    error_message = "ocpu_count must be at least 2 per VM for this example configuration."
  }
}

variable "memory_size_gb" {
  description = "Memory allocated to the Cloud VM Cluster in GiB."
  type        = number
  default     = 60

  validation {
    condition     = var.memory_size_gb >= 60
    error_message = "memory_size_gb must be at least 60 for this example configuration."
  }
}

variable "db_node_storage_size_gb" {
  description = "Local DB node storage allocated to the Cloud VM Cluster in GiB."
  type        = number
  default     = 120

  validation {
    condition     = var.db_node_storage_size_gb >= 120
    error_message = "db_node_storage_size_gb must be at least 120 for this example configuration."
  }
}

variable "data_storage_size_tb" {
  description = "Usable Exadata storage allocated to the Cloud VM Cluster in TiB."
  type        = number
  default     = 2

  validation {
    condition     = var.data_storage_size_tb >= 2
    error_message = "data_storage_size_tb must be at least 2 for this example configuration."
  }
}

variable "disk_redundancy" {
  description = "Disk redundancy for the Cloud VM Cluster."
  type        = string
  default     = "HIGH"

  validation {
    condition     = contains(["DISK_REDUNDANCY_UNSPECIFIED", "HIGH", "NORMAL"], var.disk_redundancy)
    error_message = "disk_redundancy must be DISK_REDUNDANCY_UNSPECIFIED, HIGH, or NORMAL."
  }
}

variable "local_backup_enabled" {
  description = "Whether to allocate storage for local backups."
  type        = bool
  default     = false
}

variable "sparse_diskgroup_enabled" {
  description = "Whether to allocate storage for Exadata sparse snapshots."
  type        = bool
  default     = false
}

variable "cluster_name" {
  description = "Cluster name for the Cloud VM Cluster."
  type        = string
  default     = "handoff"

  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9-]{0,10}$", var.cluster_name))
    error_message = "cluster_name must start with a letter, contain only letters, numbers, and hyphens, and be 1-11 characters long."
  }
}

variable "diagnostics_events_enabled" {
  description = "Whether diagnostics events collection is enabled."
  type        = bool
  default     = true
}

variable "health_monitoring_enabled" {
  description = "Whether health monitoring is enabled."
  type        = bool
  default     = true
}

variable "incident_logs_enabled" {
  description = "Whether incident logs and trace collection are enabled."
  type        = bool
  default     = true
}

variable "time_zone_id" {
  description = "Time zone ID for the Cloud VM Cluster."
  type        = string
  default     = "UTC"
}

variable "time_zone_version" {
  description = "Time zone file version for the Cloud VM Cluster."
  type        = string
  default     = null
}

variable "gi_version" {
  description = "Grid Infrastructure version for the Cloud VM Cluster."
  type        = string
  default     = "23.0.0.0"
}

variable "hostname_prefix" {
  description = "Hostname prefix for the Cloud VM Cluster."
  type        = string
  default     = "exa"
}

variable "ssh_public_keys" {
  description = "RSA SSH public keys authorized for the Cloud VM Cluster in OpenSSH format."
  type        = list(string)

  validation {
    condition = alltrue([
      for key in var.ssh_public_keys :
      can(regex("^ssh-rsa[[:space:]]+[A-Za-z0-9+/]+={0,3}([[:space:]]+.+)?$", trimspace(key)))
    ])
    error_message = "ssh_public_keys entries must be valid RSA public keys in OpenSSH format: ssh-rsa <base64> [comment]."
  }
}

variable "db_server_ocids" {
  description = "Database server OCIDs for explicit VM placement. Set null to discover AVAILABLE DB servers from the existing Exadata Infrastructure and select one per VM."
  type        = list(string)
  default     = null

  validation {
    condition = var.db_server_ocids == null ? true : length(var.db_server_ocids) >= 2 && alltrue([
      for ocid in var.db_server_ocids :
      can(regex("^ocid1[.]dbserver[.]", trimspace(ocid)))
    ])
    error_message = "db_server_ocids must be null or contain at least two valid DB server OCIDs, for example ocid1.dbserver.oc1.<region>.<id>."
  }
}
