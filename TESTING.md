# Release Testing - ODB Networking And ExaDB

This document tracks release validation for the Oracle Database@Google Cloud
Terraform modules:

- `modules/odb-networking`
- `modules/exadb`

It is intended to be filled in during release testing. Do not record secrets,
private keys, passwords, sensitive tfvars, or customer-specific values in this
file.

## Scope

### In Scope

- Local Terraform formatting, validation, and contract tests.
- Example validation for ODB networking and ExaDB examples.
- User-run Google Cloud execution for ODB Network and ODB Subnets.
- User-run Google Cloud execution for Cloud VM Cluster using an existing Cloud
  Exadata Infrastructure supplied through dependency maps.
- JSON handoff validation for ODB networking outputs consumed by the ExaDB
  cluster example.
- Negative plan-time validation checks for dependency contracts and subnet
  purpose rules.
- Drift checks and user-run cleanup checks for resources created during
  testing.

### Out Of Scope

- Real Google Cloud creation of Cloud Exadata Infrastructure.
- Autonomous Database (`modules/adb`) validation. ADB release testing is tracked
  separately.
- Legacy VM Cluster VPC/CIDR mode.
- Any reusable module behavior that consumes dependency JSON file paths
  directly.

### Certification Statement

Cloud Exadata Infrastructure creation is validated only through local Terraform
schema, mock-provider, and contract tests. Real integration testing uses an
existing Cloud Exadata Infrastructure and validates VM Cluster creation against
that dependency.

### Agent Execution Boundary

Codex must never execute `terraform apply` in this repository. Plan generation,
validation, schema inspection, and test commands may be executed by the agent.
Any real GCP apply step in this document is a user-only manual action. Cleanup
of real GCP resources is also user-only unless the user explicitly changes that
boundary in a later session. The agent may record results from user-provided
command output after the user runs the action outside the agent session.

## Environment

Fill this section for each release test run.

| Field | Value |
| --- | --- |
| Test run ID | `gcp-plan-20260519-131641` |
| Tester | Codex |
| Date | 2026-05-19 13:16 CEST |
| Git commit | `fa47b9e` |
| Terraform version | `1.15.1` (`darwin_arm64`) |
| Google provider lock version | `7.32.0` |
| GCP project | `omcpmpoc2` |
| GCP region | `europe-west2` |
| GCP Oracle zone | `europe-west2-c-r2` |
| Existing VPC resource name | `projects/omcpmpoc2/global/networks/emea-specialist-vpc` |
| Existing Cloud Exadata Infrastructure resource name | `projects/omcpmpoc2/locations/europe-west2/cloudExadataInfrastructures/demoinfra2` |
| DB server OCIDs used for VM Cluster placement | Stored only in ignored `modules/exadb/examples/cluster/dgc.auto.tfvars` |
| SSH public key source | `/Users/dgutierrez/.ssh/dgcdemo_vmcluster_rsa.pub` |

## Test Data

Use local ignored tfvars files based on the example templates. Do not commit
real test inputs.

All test resources created for this release run must use the `dgc` prefix in
resource IDs/names. Set tracking labels on every created resource through
`default_labels` and, where useful, resource-specific `labels`.

Required tracking labels for test tfvars:

```hcl
default_labels = {
  managed_by = "terraform"
  test_owner = "dgc"
  test_scope = "oracle-database-at-gcp"
  cleanup    = "manual"
}
```

| Input | Expected Shape | Recorded Value |
| --- | --- | --- |
| ODB Network ID | Google resource ID segment prefixed with `dgc` | `dgc-odb-network` |
| Client ODB Subnet ID | Google resource ID segment prefixed with `dgc` | `dgc-odb-client` |
| Client ODB Subnet CIDR | CIDR block | `10.60.0.0/24` |
| Backup ODB Subnet ID | Google resource ID segment prefixed with `dgc` | `dgc-odb-backup` |
| Backup ODB Subnet CIDR | CIDR block | `10.60.1.0/28` |
| Cloud VM Cluster ID | Google resource ID segment prefixed with `dgc` | `dgc-vm-cluster` |
| Cloud VM Cluster name | Google/Oracle-supported cluster name prefixed with `dgc` | `dgcvmclu` |
| Tracking labels | Required label map shown above | Present in ignored `dgc.auto.tfvars` files |
| Cloud Exadata Infrastructure dependency | `projects/<project>/locations/<region>/cloudExadataInfrastructures/<infra>` | `demoinfra2` in `omcpmpoc2/europe-west2` |

## Local Validation Matrix

Run from a clean worktree before any user-run real GCP apply.

| ID | Area | Command / Action | Expected Result | Actual Result | Status | Evidence / Notes |
| --- | --- | --- | --- | --- | --- | --- |
| L-001 | Repository | `git status --short` | No unexpected tracked changes | Only `?? TESTING.md` reported | Pass | Expected new testing artifact; no tracked module changes reported |
| L-002 | Repository | `terraform fmt -check -recursive modules` | Exit code `0` | Exit code `0` | Pass | Re-run after expanding local ignored tests |
| L-003 | Repository | `git diff --check` | Exit code `0` | Exit code `0` | Pass | Re-run before final handoff |
| L-004 | ODB Networking | `cd modules/odb-networking && terraform validate -no-color` | Configuration is valid | Configuration is valid | Pass | Terraform reported `Success! The configuration is valid.` |
| L-005 | ODB Networking | `cd modules/odb-networking && terraform test -no-color` | All local tests pass | 12 passed, 0 failed | Pass | Fresh rerun at 2026-05-19 12:57 CEST |
| L-006 | ExaDB | `cd modules/exadb && terraform validate -no-color` | Configuration is valid | Configuration is valid | Pass | Terraform reported `Success! The configuration is valid.` |
| L-007 | ExaDB | `cd modules/exadb && terraform test -no-color` | All local tests pass | 20 passed, 0 failed | Pass | Fresh rerun after adding `gi_version` validation |
| L-008 | ODB Networking Example | Init and validate `modules/odb-networking/examples/basic` | Init and validation pass | Init and validation pass | Pass | Reused installed `hashicorp/google` `7.32.0` and `hashicorp/local` `2.9.0` |
| L-009 | ExaDB Cluster Example | `cd modules/exadb/examples/cluster && terraform init -backend=false && terraform validate -no-color` | Init and validation pass | Init and validation pass | Pass | Reused installed `hashicorp/google` `7.32.0` and `hashicorp/local` `2.9.0` |
| L-010 | ExaDB Vision Example | `cd modules/exadb/examples/vision && terraform init -backend=false && terraform validate -no-color` | Init and validation pass | Init and validation pass | Pass | Reused installed `hashicorp/google` `7.32.0` and `hashicorp/local` `2.9.0` |
| L-011 | ExaDB OCI DB Home Handoff Example | `cd modules/exadb/examples/oci-dbhome-handoff && terraform init -backend=false && terraform validate -no-color` | Init and validation pass | Init and validation pass | Pass | Downloaded upstream `terraform-oci-modules-exadata//exadata-database` and `oracle/oci` provider; no plan/apply |

## Local Contract Coverage

Use this checklist to confirm the local tests cover the expected release
contract. Add test cases before release if any item is missing.

| ID | Module | Contract | Expected Coverage | Status | Evidence / Notes |
| --- | --- | --- | --- | --- | --- |
| C-001 | ODB Networking | Resource IDs | Valid and invalid ODB Network/Subnet IDs are tested | Pass | `creates_network_and_subnets_with_keyed_outputs`; `rejects_invalid_odb_network_and_subnet_ids` |
| C-002 | ODB Networking | VPC reference | `network` must use `projects/<project>/global/networks/<network>` | Pass | `rejects_invalid_network_resource_name` |
| C-003 | ODB Networking | CIDR validation | Valid and invalid `cidr_range` values are tested | Pass | `creates_network_and_subnets_with_keyed_outputs`; `rejects_invalid_cidr_range` |
| C-004 | ODB Networking | Subnet purpose | Only `CLIENT_SUBNET` and `BACKUP_SUBNET` are accepted | Pass | `creates_network_and_subnets_with_keyed_outputs`; `rejects_invalid_subnet_purpose` |
| C-005 | ODB Networking | Parent reference mutex | Each subnet sets exactly one of `odbnetwork` or `odb_network_key` | Pass | `rejects_subnet_without_exactly_one_parent_reference`; `rejects_subnet_with_two_parent_references` |
| C-006 | ODB Networking | Parent key resolution | Invalid `odb_network_key` fails at plan time | Pass | `rejects_missing_parent_odb_network_key` |
| C-007 | ODB Networking | Resource uniqueness | Duplicate IDs fail within the provider scope | Pass | `rejects_duplicate_odb_network_ids`; `rejects_duplicate_odb_subnet_ids` |
| C-008 | ODB Networking | JSON handoff | `output_path` writes wrapped network and subnet JSON | Pass | `plans_dependency_output_files_when_output_path_is_set` |
| C-009 | ExaDB | Dependency maps | Direct and wrapped dependency maps are accepted | Pass | `accepts_direct_and_wrapped_dependency_maps` |
| C-010 | ExaDB | Dependency transport | JSON file paths are rejected by reusable module inputs | Pass | `rejects_dependency_file_paths_in_module_inputs`; `rejects_dependency_file_paths_in_all_module_inputs` |
| C-011 | ExaDB | ODB subnet purpose | Client and backup subnet purposes are enforced | Pass | `rejects_client_subnet_key_with_backup_purpose`; `rejects_backup_subnet_key_with_client_purpose` |
| C-012 | ExaDB | Network coherence | ODB subnet project/location/network segment must match ODB Network | Pass | `rejects_mismatched_client_subnet_parent_network` |
| C-013 | ExaDB | Exadata dependency | Existing Cloud Exadata Infrastructure can be referenced by key | Pass | `accepts_direct_and_wrapped_dependency_maps` |
| C-014 | ExaDB | Exadata creation contract | Cloud Exadata Infrastructure resource schema is covered by mock tests | Pass | `defaults_display_names_and_parses_multiline_ssh_key_file`; `plans_dependency_output_files_when_output_path_is_set` |
| C-015 | ExaDB | VM Cluster references | Exactly one Exadata, ODB Network, client subnet, and backup subnet reference is required | Pass | `accepts_direct_and_wrapped_dependency_maps`; `rejects_vm_cluster_without_required_reference_set` |
| C-016 | ExaDB | SSH keys | RSA OpenSSH public keys are accepted and invalid keys are rejected | Pass | `defaults_display_names_and_parses_multiline_ssh_key_file`; `rejects_invalid_ssh_public_key_file` |
| C-017 | ExaDB | DB server placement | `db_server_ocids` format and minimum count are validated | Pass | `cluster_example_decodes_dependency_file_paths`; `rejects_invalid_db_server_ocid`; `rejects_too_few_db_server_ocids_for_node_count` |
| C-018 | ExaDB | Output JSON | Exadata and VM Cluster output JSON is wrapped under expected top-level keys | Pass | `plans_dependency_output_files_when_output_path_is_set`; `plans_vm_cluster_dependency_output_file_when_output_path_is_set` |
| C-019 | ExaDB | Grid Infrastructure version | VM Cluster `properties.gi_version` is required before provider apply | Pass | `rejects_vm_cluster_without_gi_version`; added after API rejected `giVersion = null` |

## GCP Integration Matrix

### ODB Networking Apply

Use `modules/odb-networking/examples/basic` with a local ignored tfvars file.
Set `default_deletion_protection = false` and `output_path = "./output"` for
test resources.

| ID | Area | Command / Action | Expected Result | Actual Result | Status | Evidence / Notes |
| --- | --- | --- | --- | --- | --- | --- |
| G-001 | ODB Networking | `terraform plan -no-color -refresh=false -lock=false` from the basic example | Plan creates one ODB Network, one client subnet, and one backup subnet | Plan creates `dgc-odb-network`, `dgc-odb-client`, `dgc-odb-backup`, two output JSON `local_file` resources, and validation data; 6 add, 0 change, 0 destroy | Pass | Plan intentionally did not use `-out`; no `tfplan` written by Codex |
| G-002 | ODB Networking | User-only manual apply of the reviewed basic-example `tfplan` | Apply completes successfully | User reported `Apply complete! Resources: 6 added, 0 changed, 0 destroyed.` | Pass | Codex did not execute apply |
| G-003 | ODB Networking | `terraform output gcp_odb_networks` | Output contains key `primary` with a full ODB Network resource name | `primary.id` is `projects/omcpmpoc2/locations/europe-west2/odbNetworks/dgc-odb-network`; state `AVAILABLE` | Pass | Verified with `terraform output -json` |
| G-004 | ODB Networking | `terraform output gcp_odb_subnets` | Output contains keys `client` and `backup` with correct purposes | `client` is `CLIENT_SUBNET`; `backup` is `BACKUP_SUBNET`; both state `AVAILABLE` | Pass | Verified with `terraform output -json` |
| G-005 | ODB Networking | Inspect `output/gcp_odb_networks_output.json` | JSON is wrapped under `gcp_odb_networks` | JSON top-level key is `gcp_odb_networks`; `primary.state` is `AVAILABLE` | Pass | Verified with `jq` |
| G-006 | ODB Networking | Inspect `output/gcp_odb_subnets_output.json` | JSON is wrapped under `gcp_odb_subnets` and includes `purpose` | JSON top-level key is `gcp_odb_subnets`; client/backup include correct `purpose`, state, and CIDR | Pass | Verified with `jq` |
| G-007 | ODB Networking | `terraform plan -detailed-exitcode` | Exit code `0`, no drift | Exit code `0`; Terraform reported `No changes. Your infrastructure matches the configuration.` | Pass | Drift check performed after user-run apply |

### ExaDB VM Cluster Apply

Use `modules/exadb/examples/cluster` with an existing Cloud Exadata
Infrastructure. Keep `gcp_cloud_exadata_infrastructures_configuration = {}` in
the wrapper. Provide the existing infrastructure through
`gcp_cloud_exadata_infrastructures_dependency`.

| ID | Area | Command / Action | Expected Result | Actual Result | Status | Evidence / Notes |
| --- | --- | --- | --- | --- | --- | --- |
| G-101 | ExaDB VM Cluster | Configure ODB dependencies from real networking outputs | Networking output key `primary`, and subnet keys `client` and `backup`, resolve to real resources | Ignored cluster tfvars consume real networking JSON output files and use `odb_network_key = "primary"` | Pass | This is the apply path for the multi-stack test |
| G-102 | ExaDB VM Cluster | Configure existing infra under dependency key `infra` | `infra` key resolves to existing Cloud Exadata Infrastructure | `infra` points to existing `demoinfra2` in `omcpmpoc2/europe-west2` | Pass | Existing infra was discovered by read-only `gcloud` inventory |
| G-103 | ExaDB VM Cluster | Configure explicit `db_server_ocids` for each VM node | Plan does not depend on implicit DB server discovery | Two DB server OCIDs configured in ignored tfvars for `node_count = 2` | Pass | OCIDs intentionally not repeated in this artifact |
| G-104 | ExaDB VM Cluster | `terraform plan -no-color -refresh=false -lock=false` from the cluster example | Plan creates VM Cluster only, not Exadata Infrastructure | Plan creates `dgc-vm-cluster`, one output JSON `local_file`, and validation data; 4 add, 0 change, 0 destroy | Pass | Re-run after switching ignored tfvars to JSON handoff; no Exadata Infrastructure creation planned |
| G-105 | ExaDB VM Cluster | User-only manual apply of the reviewed cluster-example `tfplan` | VM Cluster apply completes successfully | First user-run apply failed before VM Cluster creation with API error `CannotParseRequest: giVersion must not be null` | Retest Required | Codex did not execute apply; module now validates `gi_version` and ignored tfvars set `19.0.0.0` |
| G-106 | ExaDB VM Cluster | `terraform output gcp_cloud_vm_clusters` | Output contains the VM Cluster keyed by input key | | Not Run | |
| G-107 | ExaDB VM Cluster | `terraform plan -detailed-exitcode` | Exit code `0`, no drift | | Not Run | |
| G-108 | ExaDB VM Cluster | Post-fix `terraform plan -no-color -refresh=false -lock=false` from the cluster example | Plan includes non-null `gi_version` and creates only remaining resources after failed apply | Plan creates VM Cluster and output JSON only; 2 add, 0 change, 0 destroy; `gi_version = "19.0.0.0"` | Pass | The failed apply already created the two `terraform_data` validation resources in state |

### JSON Handoff

Use the networking JSON files from `modules/odb-networking/examples/basic/output`
as the ODB dependency inputs for `modules/exadb/examples/cluster`. Keep the
Cloud Exadata Infrastructure dependency inline unless a separate Exadata
producer stack exists.

| ID | Area | Command / Action | Expected Result | Actual Result | Status | Evidence / Notes |
| --- | --- | --- | --- | --- | --- | --- |
| G-201 | JSON Handoff | Set `gcp_odb_networks_dependency_file_path` to the networking output JSON | Wrapper decodes JSON before calling the module | Plan decoded real `gcp_odb_networks_output.json` and resolved ODB Network key `primary` | Pass | First attempt exposed expected key mismatch with direct-map tfvars; corrected consumer key to `primary` for JSON handoff |
| G-202 | JSON Handoff | Set `gcp_odb_subnets_dependency_file_path` to the subnet output JSON | Wrapper decodes JSON and preserves subnet `purpose` | Plan decoded real `gcp_odb_subnets_output.json`; client and backup purpose validations passed | Pass | Uses generated networking JSON from user-run apply |
| G-203 | JSON Handoff | `cd modules/exadb/examples/cluster && terraform plan -no-color` | Plan resolves ODB Network/Subnet keys from decoded maps | Plan creates VM Cluster only; resolves ODB Network/Subnet IDs from decoded JSON maps; 4 add, 0 change, 0 destroy | Pass | Plan-only; no apply; no `tfplan` written |

### ExaDB Single-Stack Plan

Use `modules/exadb/examples/vision` with local ignored `dgc.auto.tfvars` to
validate the customer-owned single-stack path where ODB networking, Cloud
Exadata Infrastructure, and Cloud VM Cluster are all declared in the same
Terraform state. This is plan-only because the test environment cannot create
Cloud Exadata Infrastructure.

| ID | Area | Command / Action | Expected Result | Actual Result | Status | Evidence / Notes |
| --- | --- | --- | --- | --- | --- | --- |
| G-301 | ExaDB Vision | Configure `gcp_cloud_exadata_infrastructures_configuration.primary` and VM Cluster `exadata_infrastructure_key = "primary"` | Plan resolves VM Cluster Exadata reference from the local Exadata Infrastructure configuration, not from an external dependency map | Plan creates ODB Network, client subnet, backup subnet, Cloud Exadata Infrastructure, VM Cluster, and validation data; 7 add, 0 change, 0 destroy | Pass | Plan-only; no apply; no `tfplan` written |

## Negative Test Matrix

Run these as plan-only checks. Do not apply negative scenarios.

| ID | Area | Command / Action | Expected Result | Actual Result | Status | Evidence / Notes |
| --- | --- | --- | --- | --- | --- | --- |
| N-001 | ExaDB VM Cluster | Use backup subnet as the client subnet | Plan fails because client subnet must be `CLIENT_SUBNET` | Plan failed with `external odb_subnet_key dependency must have purpose CLIENT_SUBNET` | Pass | Plan-only |
| N-002 | ExaDB VM Cluster | Set `backup_odb_subnet_key = "client"` and run `terraform plan -no-color` | Plan fails because backup subnet must be `BACKUP_SUBNET` | Plan failed with `external backup_odb_subnet_key dependency must have purpose BACKUP_SUBNET` | Pass | Plan-only |
| N-003 | ExaDB VM Cluster | Use an ODB subnet dependency whose project/location differs from the ODB Network | Plan fails before provider apply | Plan failed because client ODB subnet must belong to selected ODB Network, including project and location | Pass | Plan-only |
| N-004 | ExaDB Cluster Wrapper | Set both inline and file-path ODB Network dependency | Plan fails in `terraform_data.validate_dependency_sources` | Plan failed with `Set only one of gcp_odb_networks_dependency or gcp_odb_networks_dependency_file_path` | Pass | Plan-only |
| N-005 | ExaDB Cluster Wrapper | Set both inline and file-path ODB Subnet dependency | Plan fails in `terraform_data.validate_dependency_sources` | Plan failed with `Set only one of gcp_odb_subnets_dependency or gcp_odb_subnets_dependency_file_path` | Pass | Plan-only |
| N-006 | ExaDB Cluster Wrapper | Set both inline and file-path Exadata dependency | Plan fails in `terraform_data.validate_dependency_sources` | Plan failed with `Set only one of gcp_cloud_exadata_infrastructures_dependency or gcp_cloud_exadata_infrastructures_dependency_file_path` | Pass | Plan-only |
| N-007 | ExaDB Dependency | Use malformed `gcp_cloud_exadata_infrastructures_dependency.infra.id` | Plan fails variable validation | Plan failed variable validation for Cloud Exadata Infrastructure dependency ID format | Pass | Plan-only |

## Drift And Destroy Matrix

| ID | Area | Command / Action | Expected Result | Actual Result | Status | Evidence / Notes |
| --- | --- | --- | --- | --- | --- | --- |
| D-001 | ExaDB Drift | Change ignored VM Cluster field `cpu_core_count` | No actionable drift for the ignored field | | Not Run | |
| D-002 | ExaDB Drift | Change a managed label and run `terraform plan -detailed-exitcode` | Exit code `2` with expected label diff | | Not Run | |
| D-003 | ExaDB Cleanup | User-only manual cleanup of the cluster example after restoring tfvars | VM Cluster is destroyed; external Exadata Infrastructure remains | | Not Run | Codex must not execute real-resource cleanup |
| D-004 | ODB Networking Cleanup | User-only manual cleanup of the basic networking example | Test ODB Subnets and ODB Network are destroyed | | Not Run | Codex must not execute real-resource cleanup |
| D-005 | Repository Cleanup | `git status --short` | No generated files or real tfvars are staged or tracked | | Not Run | |

## Execution Log

Append one row per meaningful command execution or manual verification.

| Timestamp | Tester | Test ID | Command / Action | Result | Evidence / Notes |
| --- | --- | --- | --- | --- | --- |
| 2026-05-19 12:52:28 CEST | Codex | L-001 | `git status --short` | Pass | Only `?? TESTING.md`; ignored local files checked separately with `git status --short --ignored` |
| 2026-05-19 12:52:28 CEST | Codex | L-002 | `terraform fmt -check -recursive modules` | Pass | Exit code `0` |
| 2026-05-19 12:52:28 CEST | Codex | L-003 | `git diff --check` | Pass | Exit code `0` |
| 2026-05-19 12:52:28 CEST | Codex | L-004 | `terraform validate -no-color` in `modules/odb-networking` | Pass | Configuration is valid |
| 2026-05-19 12:52:28 CEST | Codex | L-006 | `terraform validate -no-color` in `modules/exadb` | Pass | Configuration is valid |
| 2026-05-19 12:52:28 CEST | Codex | L-008 | Init and validate `modules/odb-networking/examples/basic` | Pass | Init succeeded; validation reported configuration is valid |
| 2026-05-19 12:52:28 CEST | Codex | L-009 | Init and validate `modules/exadb/examples/cluster` | Pass | Init succeeded; validation reported configuration is valid |
| 2026-05-19 12:52:28 CEST | Codex | L-010 | Init and validate `modules/exadb/examples/vision` | Pass | Init succeeded; validation reported configuration is valid |
| 2026-05-19 12:54:56 CEST | Codex | C-001..C-018 | Expanded local ignored `.tftest.hcl` coverage | Pass | Added missing local coverage for invalid IDs, CIDR, parent keys, duplicate IDs, network coherence, DB server OCIDs, output JSON, and wrapper conflicts |
| 2026-05-19 12:54:56 CEST | Codex | L-005 | `terraform test -no-color` in `modules/odb-networking` | Pass | 12 passed, 0 failed |
| 2026-05-19 12:54:56 CEST | Codex | L-007 | First `terraform test -no-color` in `modules/exadb` after test expansion | Fail | Terraform test module cache was stale: `Module not installed` for new `module { source = "./examples/cluster" }` blocks |
| 2026-05-19 12:54:56 CEST | Codex | L-007 | `terraform init -backend=false` in `modules/exadb` | Pass | Installed new test module blocks and reused `hashicorp/google` `7.32.0` |
| 2026-05-19 12:54:56 CEST | Codex | L-007 | `terraform test -no-color` in `modules/exadb` | Pass | 19 passed, 0 failed |
| 2026-05-19 12:57:51 CEST | Codex | L-005 | `terraform test -no-color` in `modules/odb-networking` | Pass | Fresh rerun: 12 passed, 0 failed |
| 2026-05-19 12:57:51 CEST | Codex | L-007 | `terraform test -no-color` in `modules/exadb` | Pass | Fresh rerun: 19 passed, 0 failed |
| 2026-05-19 13:16:41 CEST | Codex | G-001 | Created ignored `modules/odb-networking/examples/basic/dgc.auto.tfvars` and ran `terraform plan -no-color -refresh=false -lock=false` | Pass | 6 add, 0 change, 0 destroy; dgc resource IDs, labels, VPC, and non-overlapping CIDRs present |
| 2026-05-19 13:16:41 CEST | Codex | G-101..G-104 | Created ignored `modules/exadb/examples/cluster/dgc.auto.tfvars` and ran `terraform plan -no-color -refresh=false -lock=false` | Pass | 4 add, 0 change, 0 destroy; creates VM Cluster only and references existing `demoinfra2` |
| 2026-05-19 13:29:21 CEST | User | G-002 | User-run `terraform apply tfplan` in `modules/odb-networking/examples/basic` | Pass | User reported `Apply complete! Resources: 6 added, 0 changed, 0 destroyed.` |
| 2026-05-19 13:29:21 CEST | Codex | G-003..G-004 | `terraform output -json` in `modules/odb-networking/examples/basic` | Pass | ODB Network and both ODB Subnets are keyed correctly and state `AVAILABLE` |
| 2026-05-19 13:29:21 CEST | Codex | G-005..G-006 | `jq` inspection of networking output JSON files | Pass | JSON files are wrapped under `gcp_odb_networks` and `gcp_odb_subnets`; subnet purpose and CIDRs present |
| 2026-05-19 13:29:21 CEST | Codex | G-007 | `terraform plan -detailed-exitcode -no-color` in `modules/odb-networking/examples/basic` | Pass | Exit code `0`; no drift |
| 2026-05-19 13:33:04 CEST | Codex | G-201..G-203 | ExaDB plan using networking JSON output file paths | Pass | Decoded real networking JSON outputs; consumer key adjusted to `primary`; plan resolved ODB dependencies and created VM Cluster only |
| 2026-05-19 13:33:04 CEST | Codex | N-001..N-003 | Negative ExaDB subnet purpose and network coherence plans | Pass | Each plan failed before provider apply with the expected precondition message |
| 2026-05-19 13:33:04 CEST | Codex | N-004..N-006 | Negative wrapper inline-map plus file-path conflict plans | Pass | Each plan failed in `terraform_data.validate_dependency_sources` with the expected conflict message |
| 2026-05-19 13:33:04 CEST | Codex | N-007 | Negative malformed Cloud Exadata dependency ID plan | Pass | Plan failed variable validation for required full resource name format |
| 2026-05-19 14:06:55 CEST | Codex | G-101..G-104 | Updated ignored cluster tfvars to use real networking JSON handoff and ran `terraform plan -no-color -refresh=false -lock=false` | Pass | Plan creates only `dgc-vm-cluster`, output JSON, and validation data; 4 add, 0 change, 0 destroy |
| 2026-05-19 14:22:11 CEST | Codex | G-301 | Created ignored `modules/exadb/examples/vision/dgc.auto.tfvars` and ran `terraform plan -no-color -refresh=false -lock=false` | Pass | Single-stack customer path creates ODB networking, Cloud Exadata Infrastructure, and VM Cluster in one state; 7 add, 0 change, 0 destroy; no apply; no `tfplan` written |
| 2026-05-19 14:29:38 CEST | User | G-105 | User-run `terraform apply tfplan` in `modules/exadb/examples/cluster` | Fail | Google API rejected VM Cluster creation because `giVersion` was null; `terraform_data` validation resources were created before the failure |
| 2026-05-19 14:29:38 CEST | Codex | C-019 | Added module validation and test coverage for required VM Cluster `gi_version` | Pass | `terraform test -no-color` in `modules/exadb`: 20 passed, 0 failed |
| 2026-05-19 14:29:38 CEST | Codex | G-108 | Post-fix `terraform plan -no-color -refresh=false -lock=false` in `modules/exadb/examples/cluster` | Pass | 2 add, 0 change, 0 destroy; remaining resources are VM Cluster and output JSON; `gi_version = "19.0.0.0"` |
| 2026-05-19 17:23:35 CEST | Codex | L-011 | Added and validated `modules/exadb/examples/oci-dbhome-handoff` | Pass | Example reads `gcp_cloud_vm_clusters_output.json`, validates `ocid`/`AVAILABLE`, and passes OCI OCID to upstream OCI Exadata DB Home module |

## Publication Checklist

| Item | Required Result | Status | Evidence / Notes |
| --- | --- | --- | --- |
| Local formatting and diff checks pass | `L-001` through `L-003` are `Pass` | Pass | No unexpected tracked changes; fmt and diff checks returned exit code `0` |
| ODB Networking local validation passes | `L-004` and `L-005` are `Pass` | Pass | `validate` passed; `terraform test` reported 12 passed, 0 failed |
| ExaDB local validation passes | `L-006` and `L-007` are `Pass` | Pass | `validate` passed; `terraform test` reported 20 passed, 0 failed |
| Examples validate | `L-008` through `L-011` are `Pass` | Pass | Basic, cluster, vision, and OCI DB Home handoff examples initialized and validated |
| ODB Networking user-run real apply passes | `G-001` through `G-007` are `Pass` | Pass | User-run apply passed; outputs, JSON handoff, and no-drift check passed |
| VM Cluster user-run real apply passes | `G-101` through `G-108` are `Pass` | In Progress | `G-105` failed once due missing `gi_version`; post-fix plan `G-108` passes; rerun user apply/output/drift checks are still required |
| JSON handoff path validates | `G-201` through `G-203` are `Pass` | Pass | Real networking JSON output files decode into ExaDB plan when consumer keys match producer output keys |
| ExaDB single-stack customer path validates | `G-301` is `Pass` | Pass | Plan-only coverage for local Exadata Infrastructure plus VM Cluster key resolution; no Cloud Exadata Infrastructure apply |
| Negative plan checks fail as expected | `N-001` through `N-007` are `Pass` | Pass | Purpose, network coherence, wrapper conflict, and malformed dependency checks fail before apply |
| Drift checks behave as expected | `D-001` and `D-002` are `Pass` | Not Run | |
| Cleanup completed | `D-003` through `D-005` are `Pass` | Not Run | |
| Scope statement is accurate for release notes | Cloud Exadata Infrastructure creation is not claimed as real-applied | Not Run | |

## Residual Risk

- Cloud Exadata Infrastructure creation is not validated with a real Google
  Cloud apply in this release test plan.
- VM Cluster creation depends on regional capacity, entitlement, IAM, DB server
  availability, and the health of the existing Cloud Exadata Infrastructure.
- User-run real apply operations may take a long time and can require rerunning
  Terraform from the same working directory if an operation is interrupted.
- Local tests use Terraform mock providers and validate module contracts, not
  all runtime behavior of the Google Cloud Oracle Database API.

## Release Decision

| Decision | Selected | Notes |
| --- | --- | --- |
| Publish | | |
| Block | | |
| Publish with documented residual risk | | |
