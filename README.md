# Oracle Database@Google Cloud Terraform Module

## Table of Contents

1. [Early Preview Disclaimer](#early-preview-disclaimer)
2. [Overview](#overview)
3. [Pre-requisites](#pre-requisites)
4. [Getting Started](#getting-started)
5. [Configuration Model](#configuration-model)
6. [Operational Drift Policy](#operational-drift-policy)
7. [Examples](#examples)
8. [Module Outputs](#module-outputs)
9. [License](#license)
10. [Known Issues](#known-issues)

## Early Preview Disclaimer

This module is still an early implementation for Oracle Database@Google Cloud. Use normal production change control: pin provider versions, review every plan, and avoid write operations until the expected service-side behavior is clear.

## Overview

This repository provides a Terraform module for Oracle Database@Google Cloud resources managed through the HashiCorp Google provider.

It supports:

* ODB Networks
* ODB Subnets
* Cloud Exadata Infrastructures
* Cloud VM Clusters

The module follows the OCI Landing Zones style. Resources are declared through keyed maps, created with `for_each`, and returned with the same keys in the outputs. That keeps downstream stacks from depending on copied resource names.

Use this README for deployment guidance. Use [SPEC.md](./SPEC.md) for the full input and output contract.

For the recommended Day-1 and Day-2 operating model, see [docs/customer-proof-operating-model.md](./docs/customer-proof-operating-model.md).

## Pre-requisites

Before running Terraform against real infrastructure, make sure these pieces are already in place:

* A Google Cloud project enabled for Oracle Database@Google Cloud.
* Google provider authentication for the Terraform caller.
* IAM permissions to manage Oracle Database@Google Cloud resources and reference the target VPC network.
* Terraform `>= 1.3.0` and HashiCorp Google provider `>= 7.0.0, < 8.0.0`.
* An existing Google Cloud VPC network.
* Oracle Database@Google Cloud entitlement and capacity in the target project and region.
* RSA SSH public keys for VM Cluster access. Ed25519 keys are rejected by the Oracle Database@Google Cloud VM Cluster API.

The VPC network is intentionally a prerequisite rather than a resource created by this module. In enterprise Google Cloud environments, the VPC is usually owned by the platform foundation or landing zone, often as a Shared VPC with centralized controls for routes, firewall rules, DNS, hybrid connectivity, and subnet delegation. This module references that existing VPC when creating the Oracle Database@Google Cloud ODB Network, then manages the Oracle-specific ODB subnets, Exadata Infrastructure, and VM Clusters.

The schema was validated against Google provider `7.31.0` on May 6, 2026.

## Getting Started

Start with [examples/quickstart](./examples/quickstart) for a first end-to-end deployment. It creates an ODB network, client and backup ODB subnets, a Cloud Exadata Infrastructure, and a Cloud VM Cluster using module keys.

After the quickstart works in your environment, use the smaller examples to choose the networking pattern that matches your platform design.

## Configuration Model

Related resources can be wired in two ways:

* Pass the literal provider resource name or ID.
* Pass a module key that points to another resource created in the same module call.

For example, a VM cluster can use `exadata_infrastructure_key` to select an Exadata infrastructure from `gcp_cloud_exadata_infrastructures_configuration`, and `odb_subnet_key` or `backup_odb_subnet_key` to select subnets from `gcp_odb_subnets_configuration`.

For multi-state deployments, use OCI-style dependency JSON files. A producer stack can set `output_path` to write handoff files, and a consumer stack can pass those file paths or equivalent maps into dependency inputs:

* `gcp_odb_networks_dependency`
* `gcp_odb_subnets_dependency`
* `gcp_cloud_exadata_infrastructures_dependency`

The reusable module stays backend-agnostic. It does not read remote state. A `*_key` can resolve either to a resource created in the same module call or to one of these dependency inputs. If a consumed key exists in both places, the module fails fast because that handoff is ambiguous.

VM clusters use ODB subnet mode with client and backup ODB subnet references, either passed directly or selected through module keys. This module intentionally exposes only ODB subnet mode for new environments.

When using ODB subnet module keys, the client key must point to a `CLIENT_SUBNET`, the backup key must point to a `BACKUP_SUBNET`, and both subnet keys must belong to the ODB network selected by `odb_network_key` when that key is set.

VPC creation stays outside this module boundary. If a deployment needs a new VPC for a proof of concept, create it in a separate landing-zone or networking stack and pass its resource name through the ODB Network `network` input.

Common defaults such as project, location, GCP Oracle zone, labels, deletion protection, Exadata maintenance windows, and operation timeouts are handled by module-level inputs. Resource-specific values override the defaults.

## Operational Drift Policy

Oracle Database@Google Cloud can be operated through both Google and OCI control planes. This dual control-plane model is useful operationally, but it also means some fields can drift outside Terraform. The module uses a narrow `ignore_changes` policy for fields that are expected to drift during Oracle-managed maintenance or OCI-side operations.

For Cloud Exadata Infrastructure, the policy covers capacity and storage fields that may change outside Terraform. For Cloud VM Clusters, it covers Grid Infrastructure patch level, server placement, capacity, storage, backup, and disk redundancy fields.

The policy is intentionally limited. Labels, maintenance windows, customer contacts, networking topology, and computed-only system attributes remain visible to Terraform. ODB Network and ODB Subnet resources do not use `ignore_changes`; network drift should be reviewed explicitly because it can affect connectivity.

The exact ignored fields and rationale are documented in [SPEC.md](./SPEC.md).

## Examples

Available examples:

* [examples/quickstart](./examples/quickstart): recommended first deployment path with a complete `terraform.tfvars.example` template.
* [examples/basic](./examples/basic): networking-only deployment that creates an ODB Network and client/backup ODB Subnets on an existing VPC, without Exadata Infrastructure or VM Clusters. Use this as a separate state boundary when platform networking should be prepared before database infrastructure.
* [examples/state-handoff-vm-cluster](./examples/state-handoff-vm-cluster): VM Cluster consumer state that reads ODB Network and ODB Subnet dependency JSON files from a separate networking deployment.
* [examples/existing-odb-subnets](./examples/existing-odb-subnets): creates a Cloud Exadata Infrastructure and a VM Cluster using existing ODB network and subnet resource names, with a complete `terraform.tfvars.example` template.
* [examples/existing-infrastructure-vm-cluster](./examples/existing-infrastructure-vm-cluster): creates only a VM Cluster using an existing Cloud Exadata Infrastructure, ODB network, client ODB subnet, and backup ODB subnet, with a complete `terraform.tfvars.example` template.

## Module Outputs

The module returns created resources with the same keys used in the input maps:

* `gcp_odb_networks`
* `gcp_odb_subnets`
* `gcp_cloud_exadata_infrastructures`
* `gcp_cloud_vm_clusters`

Each output includes stable identifiers and selected computed attributes exported by the Google provider. Set `enable_output = false` to suppress outputs.

When `output_path` is set, the module also writes dependency files for downstream stacks:

* `gcp_odb_networks_output.json`
* `gcp_odb_subnets_output.json`
* `gcp_cloud_exadata_infrastructures_output.json`

The Exadata Infrastructure and VM Cluster outputs include operational fields such as server versions, capacity, Grid Infrastructure version, DB server placement, SCAN details, and OCI URLs. These are intended for validation, handoff to downstream stacks, and troubleshooting after long-running create operations complete.

## License

Copyright (c) 2026, Oracle and/or its affiliates.

Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

## Known Issues

1. Oracle Database@Google Cloud resources can take a long time to provision. If a creation or update operation is interrupted, rerun Terraform from the same working directory so it can continue from the current state.
2. VM cluster creation requires valid networking inputs. When using ODB subnets, provide both client and backup subnet references through direct values or module keys.
3. Some VM cluster configurations require explicit DB server placement. Use `db_server_ocids` directly, or use the existing-infrastructure VM cluster example to discover available DB servers from the target Exadata Infrastructure.
4. Some resource attributes are service-managed and appear only after provisioning completes. Downstream stacks should consume outputs only after the producing stack has completed successfully.
