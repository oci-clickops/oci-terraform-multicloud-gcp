# Copyright (c) 2026, Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

output "module_name" {
  description = "The module instance name."
  value       = var.module_name
}

output "gcp_odb_networks" {
  description = "Created ODB networks, keyed by input key."
  value       = var.enable_output ? local.gcp_odb_networks_output : null
}

output "gcp_odb_subnets" {
  description = "Created ODB subnets, keyed by input key."
  value       = var.enable_output ? local.gcp_odb_subnets_output : null
}

output "gcp_cloud_exadata_infrastructures" {
  description = "Created Exadata infrastructures, keyed by input key."
  value       = var.enable_output ? local.gcp_cloud_exadata_infrastructures_output : null
}

output "gcp_cloud_vm_clusters" {
  description = "Created Exadata VM clusters, keyed by input key."
  value       = var.enable_output ? local.gcp_cloud_vm_clusters_output : null
}

resource "local_file" "gcp_odb_networks_output" {
  count = var.enable_output && var.output_path != null && length(local.gcp_odb_networks_output) > 0 ? 1 : 0

  content  = jsonencode({ gcp_odb_networks = local.gcp_odb_networks_output })
  filename = "${trimsuffix(var.output_path, "/")}/gcp_odb_networks_output.json"
}

resource "local_file" "gcp_odb_subnets_output" {
  count = var.enable_output && var.output_path != null && length(local.gcp_odb_subnets_output) > 0 ? 1 : 0

  content  = jsonencode({ gcp_odb_subnets = local.gcp_odb_subnets_output })
  filename = "${trimsuffix(var.output_path, "/")}/gcp_odb_subnets_output.json"
}

resource "local_file" "gcp_cloud_exadata_infrastructures_output" {
  count = var.enable_output && var.output_path != null && length(local.gcp_cloud_exadata_infrastructures_output) > 0 ? 1 : 0

  content  = jsonencode({ gcp_cloud_exadata_infrastructures = local.gcp_cloud_exadata_infrastructures_output })
  filename = "${trimsuffix(var.output_path, "/")}/gcp_cloud_exadata_infrastructures_output.json"
}

resource "local_file" "gcp_cloud_vm_clusters_output" {
  count = var.enable_output && var.output_path != null && length(local.gcp_cloud_vm_clusters_output) > 0 ? 1 : 0

  content  = jsonencode({ gcp_cloud_vm_clusters = local.gcp_cloud_vm_clusters_output })
  filename = "${trimsuffix(var.output_path, "/")}/gcp_cloud_vm_clusters_output.json"
}
