# Oracle Database@Google Cloud ODB Networking Terraform Module

## Overview

This module creates the Oracle Database@Google Cloud networking layer on top of an existing Google Cloud VPC:

* ODB Networks
* ODB Subnets

It follows the OCI Landing Zones style: resources are declared through keyed maps, created with `for_each`, and returned with the same keys in the outputs. The outputs can be passed directly into `modules/exadb` and `modules/adb` as dependency maps.

The module does not create Google Cloud VPC networks. VPCs are expected to be provided by the platform foundation or Google Cloud landing zone, commonly through Shared VPC or another centrally governed networking stack.

Use [SPEC.md](./SPEC.md) for the exact input and output contract.

## Requirements

* Terraform `>= 1.4.0`
* HashiCorp Google provider `>= 7.13.0, < 8.0.0`
* A Google Cloud project enabled for Oracle Database@Google Cloud
* An existing Google Cloud VPC network
* Oracle Database@Google Cloud entitlement and regional capacity

The schema was validated against Google provider `7.32.0` on May 19, 2026.

## Usage

```hcl
module "odb_networking" {
  source = "./modules/odb-networking"

  default_project_id      = "my-project"
  default_location        = "us-east4"
  default_gcp_oracle_zone = "us-east4-a"

  gcp_odb_networks_configuration = {
    primary = {
      odb_network_id = "prod-odb-network"
      network        = "projects/my-project/global/networks/prod-vpc"
    }
  }

  gcp_odb_subnets_configuration = {
    client = {
      odb_subnet_id   = "prod-client"
      odb_network_key = "primary"
      cidr_range      = "192.168.1.0/24"
      purpose         = "CLIENT_SUBNET"
    }
    backup = {
      odb_subnet_id   = "prod-backup"
      odb_network_key = "primary"
      cidr_range      = "192.168.2.0/28"
      purpose         = "BACKUP_SUBNET"
    }
  }
}
```

Downstream modules should consume `module.odb_networking.gcp_odb_networks` and `module.odb_networking.gcp_odb_subnets` directly when they are composed in the same root module.

The module validates provider-sensitive inputs at plan time: project, location, and GCP Oracle zone defaults cannot be whitespace-only; labels must use Google Cloud label-compatible syntax; and subnet CIDRs and purposes are checked before any Google Cloud API call. Duplicate resource IDs are left to the Google provider/API, matching the OCI module style.

## JSON Handoff

The sweet path is direct dependency maps from Terraform outputs, Terragrunt dependency blocks, `terraform_remote_state`, HCP Terraform workspace outputs, CI/CD variables, or an orchestration layer.

For local development, demos, or file-based orchestration, set `output_path` to write:

* `gcp_odb_networks_output.json`
* `gcp_odb_subnets_output.json`

Reusable consumer modules still receive maps. Wrappers/examples are responsible for decoding files with `jsondecode(file(...))`.

## Operational Drift Policy

ODB Network and ODB Subnet labels are treated as creation-time tracking metadata. The current Google provider plans replacement for label-only changes on these resources, so the module ignores `labels` drift to avoid accidental replacement of networking resources. All other ODB Networking attributes remain visible to Terraform.

## Examples

* [examples/basic](./examples/basic): creates an ODB Network and client/backup ODB Subnets on an existing VPC.

## Outputs

* `gcp_odb_networks`
* `gcp_odb_subnets`

Both outputs are keyed by the same logical keys used in the input maps.

## License

Copyright (c) 2026, Oracle and/or its affiliates.

Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.
