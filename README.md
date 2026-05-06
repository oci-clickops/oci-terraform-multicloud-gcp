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

This module is still an early implementation for Oracle Database@Google Cloud. Use normal production change control: pin provider versions, review every plan, and avoid applying changes until the expected service-side behavior is clear.

## Overview

This repository provides a Terraform module for Oracle Database@Google Cloud resources managed through the HashiCorp Google provider.

It supports:

* ODB Networks
* ODB Subnets
* Cloud Exadata Infrastructures
* Cloud VM Clusters

The module follows the OCI Landing Zones style. Resources are declared through keyed maps, created with `for_each`, and returned with the same keys in the outputs. That keeps downstream stacks from depending on copied resource names.

Use this README for deployment guidance. Use [SPEC.md](./SPEC.md) for the full input and output contract.

## Pre-requisites

Before running `terraform apply`, make sure these pieces are already in place:

* A Google Cloud project enabled for Oracle Database@Google Cloud.
* Google provider authentication for the Terraform caller.
* IAM permissions to manage Oracle Database@Google Cloud resources and reference the target VPC network.
* Terraform `>= 1.3.0` and HashiCorp Google provider `>= 7.0.0, < 8.0.0`.
* An existing Google Cloud VPC network.
* Oracle Database@Google Cloud entitlement and capacity in the target project and region.

The schema was validated against Google provider `7.31.0` on May 6, 2026.

## Getting Started

Start with [examples/quickstart](./examples/quickstart) for a first end-to-end deployment. It creates an ODB network, client and backup ODB subnets, a Cloud Exadata Infrastructure, and a Cloud VM Cluster using module keys.

After the quickstart works in your environment, use the smaller examples to choose the networking pattern that matches your platform design.

## Configuration Model

Related resources can be wired in two ways:

* Pass the literal provider resource name or ID.
* Pass a module key that points to another resource created in the same module call.

For example, a VM cluster can use `exadata_infrastructure_key` to select an Exadata infrastructure from `gcp_cloud_exadata_infrastructures_configuration`, and `odb_subnet_key` or `backup_odb_subnet_key` to select subnets from `gcp_odb_subnets_configuration`.

VM clusters support two networking modes:

* Google VPC CIDR mode with `network`, `cidr`, and `backup_subnet_cidr`.
* ODB subnet mode with client and backup ODB subnet references, either passed directly or selected through module keys.

When using ODB subnet module keys, the client key must point to a `CLIENT_SUBNET` and the backup key must point to a `BACKUP_SUBNET`.

Common defaults such as project, location, GCP Oracle zone, labels, deletion protection, Exadata maintenance windows, and operation timeouts are handled by module-level inputs. Resource-specific values override the defaults.

## Operational Drift Policy

Oracle Database@Google Cloud can be operated through both Google and OCI control planes. This dual control-plane model is useful operationally, but it also means some fields can drift outside Terraform. The module uses a narrow `ignore_changes` policy for fields that are expected to drift during Oracle-managed maintenance or OCI-side operations.

For Cloud Exadata Infrastructure, the policy covers capacity and storage fields that may change outside Terraform. For Cloud VM Clusters, it covers Grid Infrastructure patch level, server placement, capacity, storage, backup, and disk redundancy fields.

The policy is intentionally limited. Labels, maintenance windows, customer contacts, networking topology, and computed-only system attributes remain visible to Terraform. ODB Network and ODB Subnet resources do not use `ignore_changes`; network drift should be reviewed explicitly because it can affect connectivity.

The exact ignored fields and rationale are documented in [SPEC.md](./SPEC.md).

## Examples

Available examples:

* [examples/quickstart](./examples/quickstart): recommended first deployment path with a `terraform.tfvars.example` template.
* [examples/basic](./examples/basic): compact module-key resource graph.
* [examples/vpc-cidr](./examples/vpc-cidr): VM Cluster using Google VPC CIDR arguments.
* [examples/existing-odb-subnets](./examples/existing-odb-subnets): VM Cluster using existing ODB network and subnet resource names.

## Module Outputs

The module returns created resources with the same keys used in the input maps:

* `gcp_odb_networks`
* `gcp_odb_subnets`
* `gcp_cloud_exadata_infrastructures`
* `gcp_cloud_vm_clusters`

Each output includes stable identifiers and selected computed attributes exported by the Google provider. Set `enable_output = false` to suppress outputs.

## License

Copyright (c) 2026, Oracle and/or its affiliates.

Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

## Known Issues

1. Oracle Database@Google Cloud resources can take a long time to provision. If `terraform apply` is interrupted, run it again so Terraform can continue from the current state.
2. VM cluster creation requires valid networking inputs. When using ODB subnets, provide both client and backup subnet references through direct values or module keys.
3. Some resource attributes are service-managed and appear only after provisioning completes. Downstream stacks should consume outputs only after the producing stack has completed successfully.
