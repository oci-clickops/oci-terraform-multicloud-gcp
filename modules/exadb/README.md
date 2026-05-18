# Oracle Database@Google Cloud Terraform Module

## Table of Contents

- [Overview](#overview)
- [Pre-requisites](#pre-requisites)
- [Getting Started](#getting-started)
- [Configuration Model](#configuration-model)
- [Operational Drift Policy](#operational-drift-policy)
- [Examples](#examples)
- [Module Outputs](#module-outputs)
- [License](#license)
- [Known Issues](#known-issues)

## <a name="overview">Overview</a>

This repository provides a Terraform module for Oracle Database@Google Cloud resources managed through the HashiCorp Google provider.

It supports:

* ODB Networks
* ODB Subnets
* Cloud Exadata Infrastructures
* Cloud VM Clusters

The module follows the OCI Landing Zones style. Resources are declared through keyed maps, created with `for_each`, and returned with the same keys in the outputs. That keeps downstream stacks from depending on copied resource names.

Use this README for deployment guidance. Use [SPEC.md](./SPEC.md) for the full input and output contract.

For the recommended Day-1 and Day-2 control plane model, which is shared across the Oracle Database@AWS, Oracle Database@Google Cloud, and Oracle Database@Azure modules, see the [oci-multicloud-control-plane-model](https://github.com/oci-clickops/oci-multicloud-control-plane-model) repository.

## <a name="pre-requisites">Pre-requisites</a>

Before running Terraform against real infrastructure, make sure these pieces are already in place:

* A Google Cloud project enabled for Oracle Database@Google Cloud.
* Google provider authentication for the Terraform caller.
* IAM permissions to manage Oracle Database@Google Cloud resources and reference the target VPC network.
* Terraform `>= 1.3.0` and HashiCorp Google provider `>= 7.13.0, < 8.0.0`.
* An existing Google Cloud VPC network.
* Oracle Database@Google Cloud entitlement and capacity in the target project and region.
* RSA SSH public keys for VM Cluster access. Ed25519 keys are rejected by the Oracle Database@Google Cloud VM Cluster API.

The VPC network is intentionally a prerequisite rather than a resource created by this module. In enterprise Google Cloud environments, the VPC is usually owned by the platform foundation or landing zone, often as a Shared VPC with centralized controls for routes, firewall rules, DNS, hybrid connectivity, and subnet delegation. This module references that existing VPC when creating the Oracle Database@Google Cloud ODB Network, then manages the Oracle-specific ODB subnets, Exadata Infrastructure, and VM Clusters.

The schema was validated against Google provider `7.31.0` on May 6, 2026.

## <a name="getting-started">Getting Started</a>

Start with [examples/vision](./examples/vision) for a complete end-to-end deployment. It creates an ODB network, client and backup ODB subnets, a Cloud Exadata Infrastructure, and a Cloud VM Cluster using module keys.

After the vision example works in your environment, use the smaller examples to choose the networking pattern that matches your platform design.

## <a name="configuration-model">Configuration Model</a>

### Key References

Related resources can be wired in two ways:

* Pass the literal provider resource name or ID.
* Pass a module key that points to another resource created in the same module call.

For example, a VM cluster can use `exadata_infrastructure_key` to select an Exadata infrastructure from `gcp_cloud_exadata_infrastructures_configuration`, and `odb_subnet_key` or `backup_odb_subnet_key` to select subnets from `gcp_odb_subnets_configuration`.

VM clusters use ODB subnet mode with client and backup ODB subnet references, either passed directly or selected through module keys. When using ODB subnet module keys, the client key must point to a `CLIENT_SUBNET`, the backup key must point to a `BACKUP_SUBNET`, and both subnet keys must belong to the ODB network selected by `odb_network_key` when that key is set.

Common defaults such as project, location, GCP Oracle zone, labels, deletion protection, Exadata maintenance windows, and operation timeouts are handled by module-level inputs. Resource-specific values override the defaults.

### Multi-Stack Handoff

For multi-team or multi-state deployments, a consumer stack passes dependency maps — from Terragrunt `dependency` blocks, `terraform_remote_state` outputs, HCP Terraform workspace outputs, or CI/CD pipeline variables — into these dependency inputs:

* `gcp_odb_networks_dependency`
* `gcp_odb_subnets_dependency`
* `gcp_cloud_exadata_infrastructures_dependency`

As an alternative for standalone stacks without external orchestration, a producer can set `output_path` to write JSON handoff files that the consumer passes as file paths to the same inputs.

The module stays backend-agnostic. It does not read remote state. A `*_key` resolves either to a resource created in the same module call or to one of these dependency inputs. If a consumed key exists in both places, the module fails fast because the reference is ambiguous.

VPC creation stays outside this module boundary. If a deployment needs a new VPC for a proof of concept, create it in a separate landing-zone or networking stack and pass its resource name through the ODB Network `network` input.

## <a name="operational-drift-policy">Operational Drift Policy</a>

Oracle Database@Google Cloud can be operated through both Google and OCI control planes. This dual control-plane model is useful operationally, but it also means some fields can drift outside Terraform. The module uses a narrow `ignore_changes` policy for fields that are expected to drift during Oracle-managed maintenance or OCI-side operations.

For Cloud Exadata Infrastructure, the policy covers capacity and storage fields that may change outside Terraform. For Cloud VM Clusters, it covers Grid Infrastructure patch level, server placement, capacity, storage, backup, and disk redundancy fields.

The policy is intentionally limited. Labels, maintenance windows, customer contacts, networking topology, and computed-only system attributes remain visible to Terraform. ODB Network and ODB Subnet resources do not use `ignore_changes`; network drift should be reviewed explicitly because it can affect connectivity.

The exact ignored fields and rationale are documented in [SPEC.md](./SPEC.md).

## <a name="examples">Examples</a>

Available examples:

* [examples/vision](./examples/vision): recommended first deployment path — complete end-to-end example with a ready-to-rename `input.auto.tfvars.template`.
* [examples/networking](./examples/networking): networking-only deployment (Network team Stack 1) — creates an ODB Network and client/backup ODB Subnets on an existing VPC, without Exadata Infrastructure or VM Clusters. Set `output_path` to write dependency files for `examples/cluster`.
* [examples/cluster](./examples/cluster): Exadata Infrastructure and VM Cluster deployment (Infra team Stack 2) — receives ODB networking outputs from a separate networking stack via inline maps or JSON file paths. To use an existing Exadata Infrastructure created outside Terraform, pass its resource name directly in `exadata_infrastructure` instead of using a key.

Each example includes an `input.auto.tfvars.template` file. Rename it to `<project-name>.auto.tfvars` and Terraform will load it automatically — no `terraform.tfvars` copy needed.

The examples deliberately do not declare a Terraform backend. For real deployments, configure a remote backend such as Google Cloud Storage, an OCI Object Storage bucket, Terraform Cloud, or any other supported backend in your own copy of the example or wrapper stack. Keep state for networking, Exadata infrastructure, and VM cluster stacks separate when adopting the multi-state handoff pattern.

## <a name="module-outputs">Module Outputs</a>

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
* `gcp_cloud_vm_clusters_output.json`

The Exadata Infrastructure and VM Cluster outputs include operational fields such as server versions, capacity, Grid Infrastructure version, DB server placement, SCAN details, and OCI URLs. These are intended for validation, handoff to downstream stacks, and troubleshooting after long-running create operations complete.

## <a name="license">License</a>

Copyright (c) 2026, Oracle and/or its affiliates.

Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

## <a name="known-issues">Known Issues</a>

1. Oracle Database@Google Cloud resources can take a long time to provision. If a creation or update operation is interrupted, rerun Terraform from the same working directory so it can continue from the current state.
2. VM cluster creation requires valid networking inputs. When using ODB subnets, provide both client and backup subnet references through direct values or module keys.
3. Some VM cluster configurations require explicit DB server placement. Use `db_server_ocids` directly. To discover available DB server OCIDs, run `gcloud oracle-database cloud-exadata-infrastructures db-servers list --location=<LOCATION> --cloud-exadata-infrastructure=<NAME>`.
4. Some resource attributes are service-managed and appear only after provisioning completes. Downstream stacks should consume outputs only after the producing stack has completed successfully.
