# Copyright (c) 2026, Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "project_id" { description = "GCP project ID enabled for Oracle Database@Google Cloud." }
variable "location"   { description = "GCP region for Oracle Database@Google Cloud resources." }

variable "default_labels" {
  type    = any
  default = null
}

variable "default_deletion_protection" {
  type    = any
  default = false
}

variable "gcp_cloud_vm_clusters_configuration" {
  type    = any
  default = null
}
