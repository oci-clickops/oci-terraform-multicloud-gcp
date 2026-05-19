# Copyright (c) 2026, Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

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
