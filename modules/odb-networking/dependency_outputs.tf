# Copyright (c) 2026, Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

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
