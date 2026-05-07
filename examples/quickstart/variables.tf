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
  default     = "quickstart-client"
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
  default     = "quickstart-backup"
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

variable "cloud_exadata_infrastructure_id" {
  description = "Cloud Exadata Infrastructure ID to create."
  type        = string
  default     = "quickstart-exadata"
}

variable "cloud_exadata_infrastructure_display_name" {
  description = "Display name for the Cloud Exadata Infrastructure."
  type        = string
  default     = null
}

variable "cloud_exadata_infrastructure_location" {
  description = "Optional region override for the Cloud Exadata Infrastructure."
  type        = string
  default     = null
}

variable "cloud_exadata_infrastructure_project_id" {
  description = "Optional project override for the Cloud Exadata Infrastructure."
  type        = string
  default     = null
}

variable "cloud_exadata_infrastructure_gcp_oracle_zone" {
  description = "Optional GCP Oracle zone override for the Cloud Exadata Infrastructure."
  type        = string
  default     = null
}

variable "cloud_exadata_infrastructure_labels" {
  description = "Labels for the Cloud Exadata Infrastructure."
  type        = map(string)
  default     = {}
}

variable "cloud_exadata_infrastructure_deletion_protection" {
  description = "Whether deletion protection is enabled for the Cloud Exadata Infrastructure."
  type        = bool
  default     = false
}

variable "cloud_exadata_infrastructure_timeouts" {
  description = "Provider operation timeouts for the Cloud Exadata Infrastructure."
  type = object({
    create = optional(string)
    update = optional(string)
    delete = optional(string)
  })
  default = {
    create = "300m"
    update = "180m"
    delete = "180m"
  }
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

variable "total_storage_size_gb" {
  description = "Total storage size in GB for the Cloud Exadata Infrastructure."
  type        = number
  default     = null
}

variable "customer_contacts" {
  description = "Customer contacts for Exadata infrastructure maintenance notifications."
  type = list(object({
    email = string
  }))
}

variable "exadata_maintenance_window" {
  description = "Maintenance window configuration for the Cloud Exadata Infrastructure."
  type = object({
    preference                       = optional(string)
    months                           = optional(list(string))
    weeks_of_month                   = optional(list(number))
    days_of_week                     = optional(list(string))
    hours_of_day                     = optional(list(number))
    lead_time_week                   = optional(number)
    patching_mode                    = optional(string)
    custom_action_timeout_mins       = optional(number)
    is_custom_action_timeout_enabled = optional(bool)
  })
  default = {
    preference                       = "CUSTOM_PREFERENCE"
    months                           = null
    weeks_of_month                   = [1]
    days_of_week                     = ["SUNDAY"]
    hours_of_day                     = [4]
    lead_time_week                   = null
    patching_mode                    = "ROLLING"
    custom_action_timeout_mins       = null
    is_custom_action_timeout_enabled = null
  }
}

variable "cloud_vm_cluster_id" {
  description = "Cloud VM Cluster ID to create."
  type        = string
  default     = "quickstart-vm-cluster"
}

variable "display_name" {
  description = "Display name for the Cloud VM Cluster."
  type        = string
  default     = null
}

variable "labels" {
  description = "Labels to apply to resources."
  type        = map(string)
  default = {
    terraform = "true"
    example   = "quickstart"
  }
}

variable "deletion_protection" {
  description = "Whether deletion protection is enabled for resources."
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
  description = "License type for the Cloud VM Cluster."
  type        = string
  default     = "BRING_YOUR_OWN_LICENSE"
}

variable "cpu_core_count" {
  description = "Number of enabled CPU cores for the Cloud VM Cluster."
  type        = number
  default     = 4
}

variable "node_count" {
  description = "Number of VMs in the Cloud VM Cluster."
  type        = number
  default     = 2
}

variable "ocpu_count" {
  description = "Number of enabled OCPUs per VM."
  type        = number
  default     = 2
}

variable "memory_size_gb" {
  description = "Memory allocated to the Cloud VM Cluster in GiB."
  type        = number
  default     = 60
}

variable "db_node_storage_size_gb" {
  description = "Local DB node storage allocated to the Cloud VM Cluster in GiB."
  type        = number
  default     = 120
}

variable "data_storage_size_tb" {
  description = "Usable Exadata storage allocated to the Cloud VM Cluster in TiB."
  type        = number
  default     = 2
}

variable "disk_redundancy" {
  description = "Disk redundancy for the Cloud VM Cluster."
  type        = string
  default     = "HIGH"
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
  default     = "quickstart"
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
  description = "Hostname prefix for VM cluster host names."
  type        = string
  default     = "exa"
}

variable "ssh_public_keys" {
  description = "RSA SSH public keys for VM cluster access in OpenSSH format."
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
  description = "Optional database server OCIDs for explicit VM placement. Leave null to let the service choose placement."
  type        = list(string)
  default     = null
}
