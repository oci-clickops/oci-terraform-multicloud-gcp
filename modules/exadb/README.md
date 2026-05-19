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

* Cloud Exadata Infrastructures
* Cloud VM Clusters

The module follows the OCI Landing Zones style. Resources are declared through keyed maps, created with `for_each`, and returned with the same keys in the outputs. That keeps downstream stacks from depending on copied resource names.

For v1, new VM Cluster deployments use ODB Network mode only: `odb_network` / `odb_subnet` / `backup_odb_subnet`, either directly or through module keys. The Google provider still exposes the older VPC/CIDR fields, but this module does not expose them as a public interface because new Oracle Database@Google Cloud environments should use ODB Networks and ODB Subnets.

Use this README for deployment guidance. Use [SPEC.md](./SPEC.md) for the full input and output contract.

For the recommended Day-1 and Day-2 control plane model, which is shared across the Oracle Database@AWS, Oracle Database@Google Cloud, and Oracle Database@Azure modules, see the [oci-multicloud-control-plane-model](https://github.com/oci-clickops/oci-multicloud-control-plane-model) repository.

## <a name="pre-requisites">Pre-requisites</a>

Before running Terraform against real infrastructure, make sure these pieces are already in place:

* A Google Cloud project enabled for Oracle Database@Google Cloud.
* Google provider authentication for the Terraform caller.
* IAM permissions to manage Oracle Database@Google Cloud Exadata resources.
* Terraform `>= 1.4.0` and HashiCorp Google provider `>= 7.13.0, < 8.0.0`.
* An existing ODB Network plus client and backup ODB Subnets, created by `modules/odb-networking` or an equivalent stack.
* Oracle Database@Google Cloud entitlement and capacity in the target project and region.
* RSA SSH public keys for VM Cluster access. Ed25519 keys are rejected by the Oracle Database@Google Cloud VM Cluster API.

ODB networking is intentionally outside this module boundary. In enterprise Google Cloud environments, the VPC and ODB networking layer are usually owned by a platform or networking stack. Use [../odb-networking](../odb-networking/README.md) when Terraform should create the ODB Network and ODB Subnets.

The schema was validated against Google provider `7.32.0` on May 19, 2026.

## <a name="getting-started">Getting Started</a>

Start with [examples/vision](./examples/vision) for a complete end-to-end deployment. The example composes `modules/odb-networking` and this module: networking is produced by the shared ODB networking module, then consumed here through dependency maps.

After the vision example works in your environment, use [../odb-networking/examples/basic](../odb-networking/examples/basic) for a standalone networking state and [examples/cluster](./examples/cluster) for the ExaDB consumer state.

## <a name="configuration-model">Configuration Model</a>

### Key References

Every cross-resource reference accepts two interchangeable forms. Pick whichever fits the way the upstream resource was managed:

* **`*_key` form** — a logical name resolved against `*_configuration` for Exadata Infrastructure or a `*_dependency` map for externally managed resources such as ODB Network/Subnet. Exadata Infrastructure keys must be unique across local configuration and dependency maps.
* **direct form** — the literal full GCP resource name, useful for one-off references to externally managed infrastructure that is not modeled in any dependency map.

The two forms are mutually exclusive on the same field pair: set exactly one of `exadata_infrastructure` or `exadata_infrastructure_key`, exactly one of `odb_network` or `odb_network_key`, and so on.

#### Side-by-side example

`*_key` form — recommended when the Exadata Infrastructure is created in this module call and ODB networking is imported through dependency maps:

```hcl
gcp_cloud_exadata_infrastructures_configuration = {
  "shared-exa" = {
    cloud_exadata_infrastructure_id = "shared-exa"
    properties = { shape = "Exadata.X11M" }
  }
}

gcp_cloud_vm_clusters_configuration = {
  "prod-cluster" = {
    cloud_vm_cluster_id        = "prod-cluster"
    exadata_infrastructure_key = "shared-exa"   # resolves to the entry above
    odb_network_key            = "prod-net"     # resolves from gcp_odb_networks_dependency
    odb_subnet_key             = "prod-client"
    backup_odb_subnet_key      = "prod-backup"
    properties = { license_type = "BRING_YOUR_OWN_LICENSE", gi_version = "19.0.0.0", cpu_core_count = 8 }
  }
}
```

Direct form — useful when the Exadata infrastructure was created by `gcloud`, an OCI console operator, or a parallel stack that does not produce a JSON handoff:

```hcl
gcp_cloud_vm_clusters_configuration = {
  "prod-cluster" = {
    cloud_vm_cluster_id    = "prod-cluster"
    exadata_infrastructure = "projects/my-project/locations/us-east4/cloudExadataInfrastructures/shared-exa"
    odb_network            = "projects/my-project/locations/us-east4/odbNetworks/prod-net"
    odb_subnet             = "projects/my-project/locations/us-east4/odbNetworks/prod-net/odbSubnets/prod-client"
    backup_odb_subnet      = "projects/my-project/locations/us-east4/odbNetworks/prod-net/odbSubnets/prod-backup"
    properties = { license_type = "BRING_YOUR_OWN_LICENSE", gi_version = "19.0.0.0", cpu_core_count = 8 }
  }
}
```

Both forms accept the same surrounding configuration. Mix them across different entries in the same map when that matches the way the upstream resources are owned.

#### Cross-resource consistency

When `*_key` references are used for ODB networking, the module enforces that ODB subnets belong to the parent ODB network (same project, location, and network segment), that the client `odb_subnet_key` resolves to `purpose = CLIENT_SUBNET`, and that `backup_odb_subnet_key` resolves to `purpose = BACKUP_SUBNET`. These checks run at plan time as resource preconditions.

Common defaults such as project, location, GCP Oracle zone, labels, deletion protection, Exadata maintenance windows, and operation timeouts are handled by module-level inputs. Resource-specific values override the defaults.

When `display_name` is omitted, Cloud Exadata Infrastructure and Cloud VM Cluster resources use their resource ID as the display name. `module_name` is also validated so the generated module label remains compatible with Google Cloud label rules.

VM Cluster SSH public keys can be supplied directly with `properties.ssh_public_keys` or centrally with `ssh_public_keys_file_path`. When the file path is set, the module reads one RSA OpenSSH public key per non-empty line and injects the resulting list into every VM Cluster configuration.

VM Cluster `properties.gi_version` is required by the Oracle Database@Google Cloud API during creation, even though the Google provider schema marks it optional. Choose a version available in the target Google Cloud location.

### Multi-Stack Handoff

For multi-team or multi-state deployments, a consumer stack passes dependency maps — from Terragrunt `dependency` blocks, `terraform_remote_state` outputs, HCP Terraform workspace outputs, or CI/CD pipeline variables — into these dependency inputs:

* `gcp_odb_networks_dependency`
* `gcp_odb_subnets_dependency`
* `gcp_cloud_exadata_infrastructures_dependency`

As an optional bridge for local development, demos, or file-based orchestration, a producer can set `output_path` to write JSON handoff files. `modules/odb-networking` writes ODB networking handoff files, and this module writes Exadata/VM Cluster handoff files. Reusable module inputs still receive dependency maps; wrappers such as `examples/cluster` are responsible for reading JSON files with `jsondecode(file(...))` before passing those maps to the module.

The module stays backend-agnostic. It does not read remote state. Exadata Infrastructure keys can resolve to a resource created in the same module call or to `gcp_cloud_exadata_infrastructures_dependency`; ODB Network and ODB Subnet keys resolve only to their dependency maps.

VPC and ODB networking creation stay outside this module boundary. If a deployment needs a new VPC for a proof of concept, create it in a separate landing-zone or networking stack, then create the ODB Network/Subnets with `modules/odb-networking`.

The module intentionally does not expose the Google provider's legacy VM Cluster VPC/CIDR inputs. Existing deployments that still depend on that shape should keep using a tailored wrapper or direct provider resources until they are moved to ODB Network mode.

## <a name="operational-drift-policy">Operational Drift Policy</a>

Oracle Database@Google Cloud can be operated through both Google and OCI control planes. This dual control-plane model is useful operationally, but it also means some fields can drift outside Terraform. The module uses a narrow `ignore_changes` policy for fields that are expected to drift during Oracle-managed maintenance or OCI-side operations.

For Cloud Exadata Infrastructure, the policy covers capacity and storage fields that may change outside Terraform. For Cloud VM Clusters, it covers Grid Infrastructure patch level, server placement, capacity, storage, backup, and disk redundancy fields.

The policy is intentionally limited. Labels, maintenance windows, customer contacts, networking topology, and computed-only system attributes remain visible to Terraform. ODB Network and ODB Subnet drift belongs to the networking module or the stack that owns those resources.

The exact ignored fields and rationale are documented in [SPEC.md](./SPEC.md).

## <a name="examples">Examples</a>

Available examples:

* [examples/vision](./examples/vision): recommended first deployment path — complete end-to-end example with a ready-to-rename `input.auto.tfvars.template`.
* [../odb-networking/examples/basic](../odb-networking/examples/basic): networking-only deployment (Network team Stack 1) — creates an ODB Network and client/backup ODB Subnets on an existing VPC, without Exadata Infrastructure or VM Clusters. Set `output_path` to write dependency files for `examples/cluster`.
* [examples/cluster](./examples/cluster): VM Cluster deployment — receives ODB networking and Cloud Exadata Infrastructure outputs from upstream stacks via inline maps or, for local file handoff, example-level `*_dependency_file_path` variables. To use an existing Exadata Infrastructure without a dependency map, pass its resource name directly in `exadata_infrastructure` instead of using a key.
* [examples/oci-dbhome-handoff](./examples/oci-dbhome-handoff): downstream OCI wrapper — reads `gcp_cloud_vm_clusters_output.json`, extracts the VM Cluster OCI OCID, and passes it to the OCI Exadata module for DB Homes, CDBs, and PDBs.

Each example includes an `input.auto.tfvars.template` file. Rename it to `<project-name>.auto.tfvars` and Terraform will load it automatically — no `terraform.tfvars` copy needed.

The examples deliberately do not declare a Terraform backend. For real deployments, configure a remote backend such as Google Cloud Storage, an OCI Object Storage bucket, Terraform Cloud, or any other supported backend in your own copy of the example or wrapper stack. Keep state for networking, Exadata infrastructure, and VM cluster stacks separate when adopting the multi-state handoff pattern.

## <a name="module-outputs">Module Outputs</a>

The module returns created resources with the same keys used in the input maps:

* `gcp_cloud_exadata_infrastructures`
* `gcp_cloud_vm_clusters`

Each output includes stable identifiers and selected computed attributes exported by the Google provider. Set `enable_output = false` to suppress outputs.

When `output_path` is set, the module also writes dependency files for downstream stacks:

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
