# Copyright (c) 2026, Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

resource "local_file" "gcp_autonomous_databases_output" {
  count = var.enable_output && var.output_path != null && length(local.gcp_autonomous_databases_output) > 0 ? 1 : 0

  content  = jsonencode({ gcp_autonomous_databases = local.gcp_autonomous_databases_output })
  filename = "${trimsuffix(var.output_path, "/")}/gcp_autonomous_databases_output.json"
}
