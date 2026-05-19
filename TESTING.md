# Release Testing - ExaDB

This document tracks release validation for `modules/exadb`.

ODB Networking release validation is tracked separately in
`TESTING_ODBNETWORKING.md`. ADB release validation is tracked separately in
`TESTING_ADB.md`.

Do not record secrets, private keys, passwords, sensitive tfvars, or
customer-specific values in this file.

## Scope

### In Scope

- Local Terraform formatting, validation, and ExaDB contract tests.
- Example validation for ExaDB examples.
- User-run Google Cloud execution for Cloud VM Cluster using an existing Cloud
  Exadata Infrastructure supplied through dependency maps.
- JSON handoff validation for ODB Networking outputs consumed by the ExaDB
  cluster example.
- Plan-only validation for customer-owned single-stack ExaDB composition.
- Negative plan-time validation checks for dependency contracts and subnet
  purpose rules.
- Drift checks and user-run cleanup checks for ExaDB resources created during
  testing.

### Out Of Scope

- Any `terraform apply` executed by Codex.
- Real Google Cloud creation of Cloud Exadata Infrastructure.
- ODB Networking creation or certification; tracked in
  `TESTING_ODBNETWORKING.md`.
- Autonomous Database validation; tracked in `TESTING_ADB.md`.
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
boundary in a later session.

## Environment

| Field | Value |
| --- | --- |
| Test run ID | `exadb-plan-20260519-131641` |
| Tester | Codex |
| Date | 2026-05-19 13:16 CEST |
| Git commit | `fa47b9e` |
| Terraform version | `1.15.1` (`darwin_arm64`) |
| Google provider lock version | `7.32.0` |
| GCP project | `omcpmpoc2` |
| GCP region | `europe-west2` |
| Existing ODB Network | `projects/omcpmpoc2/locations/europe-west2/odbNetworks/dgc-odb-network` |
| Existing client ODB Subnet | `projects/omcpmpoc2/locations/europe-west2/odbNetworks/dgc-odb-network/odbSubnets/dgc-odb-client` |
| Existing backup ODB Subnet | `projects/omcpmpoc2/locations/europe-west2/odbNetworks/dgc-odb-network/odbSubnets/dgc-odb-backup` |
| Existing Cloud Exadata Infrastructure | `projects/omcpmpoc2/locations/europe-west2/cloudExadataInfrastructures/demoinfra2` |
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
| Cloud VM Cluster ID | Google resource ID segment prefixed with `dgc` | `dgc-vm-cluster` |
| Cloud VM Cluster name | Google/Oracle-supported cluster name prefixed with `dgc` | `dgcvmclu` |
| Tracking labels | Required label map shown above | Present in ignored `dgc.auto.tfvars` files |
| Cloud Exadata Infrastructure dependency | `projects/<project>/locations/<region>/cloudExadataInfrastructures/<infra>` | `demoinfra2` in `omcpmpoc2/europe-west2` |

## Local Validation Matrix

| ID | Area | Command / Action | Expected Result | Actual Result | Status | Evidence / Notes |
| --- | --- | --- | --- | --- | --- | --- |
| EXA-L-001 | Repository | `git status --short` | Dirty worktree understood; generated files are not tracked | Existing tracked docs/module changes plus ignored local Terraform artifacts | Pass | No cleanup or revert performed |
| EXA-L-002 | Repository | `terraform fmt -check -recursive modules` | Exit code `0` | Exit code `0` | Pass | Re-run before final handoff |
| EXA-L-003 | Repository | `git diff --check` | Exit code `0` | Exit code `0` | Pass | Re-run before final handoff |
| EXA-L-004 | ExaDB | `cd modules/exadb && terraform validate -no-color` | Configuration is valid | Configuration is valid | Pass | Terraform reported `Success! The configuration is valid.` |
| EXA-L-005 | ExaDB | `cd modules/exadb && terraform test -no-color` | All local tests pass | 20 passed, 0 failed | Pass | Fresh rerun after adding `gi_version` validation |
| EXA-L-006 | ExaDB Cluster Example | `cd modules/exadb/examples/cluster && terraform init -backend=false && terraform validate -no-color` | Init and validation pass | Init and validation pass | Pass | Reused installed `hashicorp/google` `7.32.0` and `hashicorp/local` `2.9.0` |
| EXA-L-007 | ExaDB Vision Example | `cd modules/exadb/examples/vision && terraform init -backend=false && terraform validate -no-color` | Init and validation pass | Init and validation pass | Pass | Reused installed providers |
| EXA-L-008 | ExaDB OCI DB Home Handoff Example | `cd modules/exadb/examples/oci-dbhome-handoff && terraform init -backend=false && terraform validate -no-color` | Init and validation pass | Init and validation pass | Pass | Downloaded upstream `terraform-oci-modules-exadata//exadata-database` and `oracle/oci` provider; no plan/apply |

## Local Contract Coverage

| ID | Contract | Expected Coverage | Status | Evidence / Notes |
| --- | --- | --- | --- | --- |
| EXA-C-001 | Dependency maps | Direct and wrapped dependency maps are accepted | Pass | `accepts_direct_and_wrapped_dependency_maps` |
| EXA-C-002 | Dependency transport | JSON file paths are rejected by reusable module inputs | Pass | `rejects_dependency_file_paths_in_module_inputs`; `rejects_dependency_file_paths_in_all_module_inputs` |
| EXA-C-003 | ODB subnet purpose | Client and backup subnet purposes are enforced | Pass | `rejects_client_subnet_key_with_backup_purpose`; `rejects_backup_subnet_key_with_client_purpose` |
| EXA-C-004 | Network coherence | ODB subnet project/location/network segment must match ODB Network | Pass | `rejects_mismatched_client_subnet_parent_network` |
| EXA-C-005 | Exadata dependency | Existing Cloud Exadata Infrastructure can be referenced by key | Pass | `accepts_direct_and_wrapped_dependency_maps` |
| EXA-C-006 | Exadata creation contract | Cloud Exadata Infrastructure resource schema is covered by mock tests | Pass | `defaults_display_names_and_parses_multiline_ssh_key_file`; `plans_dependency_output_files_when_output_path_is_set` |
| EXA-C-007 | VM Cluster references | Exactly one Exadata, ODB Network, client subnet, and backup subnet reference is required | Pass | `accepts_direct_and_wrapped_dependency_maps`; `rejects_vm_cluster_without_required_reference_set` |
| EXA-C-008 | SSH keys | RSA OpenSSH public keys are accepted and invalid keys are rejected | Pass | `defaults_display_names_and_parses_multiline_ssh_key_file`; `rejects_invalid_ssh_public_key_file` |
| EXA-C-009 | DB server placement | `db_server_ocids` format and minimum count are validated | Pass | `cluster_example_decodes_dependency_file_paths`; `rejects_invalid_db_server_ocid`; `rejects_too_few_db_server_ocids_for_node_count` |
| EXA-C-010 | Output JSON | Exadata and VM Cluster output JSON is wrapped under expected top-level keys | Pass | `plans_dependency_output_files_when_output_path_is_set`; `plans_vm_cluster_dependency_output_file_when_output_path_is_set` |
| EXA-C-011 | Grid Infrastructure version | VM Cluster `properties.gi_version` is required before provider apply | Pass | `rejects_vm_cluster_without_gi_version`; added after API rejected `giVersion = null` |

## GCP VM Cluster Matrix

Use `modules/exadb/examples/cluster` with an existing Cloud Exadata
Infrastructure. Keep `gcp_cloud_exadata_infrastructures_configuration = {}` in
the wrapper. Provide the existing infrastructure through
`gcp_cloud_exadata_infrastructures_dependency`.

| ID | Area | Command / Action | Expected Result | Actual Result | Status | Evidence / Notes |
| --- | --- | --- | --- | --- | --- | --- |
| EXA-G-001 | ExaDB VM Cluster | Configure ODB dependencies from certified networking outputs | Networking output key `primary`, and subnet keys `client` and `backup`, resolve to real resources | Ignored cluster tfvars consume real networking JSON output files and use `odb_network_key = "primary"` | Pass | ODB Networking certification is tracked in `TESTING_ODBNETWORKING.md` |
| EXA-G-002 | ExaDB VM Cluster | Configure existing infra under dependency key `infra` | `infra` key resolves to existing Cloud Exadata Infrastructure | `infra` points to existing `demoinfra2` in `omcpmpoc2/europe-west2` | Pass | Existing infra was discovered by read-only `gcloud` inventory |
| EXA-G-003 | ExaDB VM Cluster | Configure explicit `db_server_ocids` for each VM node | Plan does not depend on implicit DB server discovery | Two DB server OCIDs configured in ignored tfvars for `node_count = 2` | Pass | OCIDs intentionally not repeated in this artifact |
| EXA-G-004 | ExaDB VM Cluster | `terraform plan -no-color -refresh=false -lock=false` from the cluster example | Plan creates VM Cluster only, not Exadata Infrastructure | Plan creates `dgc-vm-cluster`, one output JSON `local_file`, and validation data; 4 add, 0 change, 0 destroy | Pass | Re-run after switching ignored tfvars to JSON handoff; no Exadata Infrastructure creation planned |
| EXA-G-005 | ExaDB VM Cluster | User-only manual apply of the reviewed post-fix cluster-example `tfplan` | VM Cluster apply completes successfully | User reported `Apply complete! Resources: 2 added, 0 changed, 0 destroyed.` after setting `gi_version = "19.0.0.0"` | Pass | Codex did not execute apply; first failed attempt is retained in the execution log |
| EXA-G-006 | ExaDB VM Cluster | `terraform output gcp_cloud_vm_clusters` | Output contains the VM Cluster keyed by input key | Output contains key `primary`; `state` is `AVAILABLE`; OCI VM Cluster OCID is present | Pass | Verified with `terraform output -json`; OCID intentionally not repeated in this artifact |
| EXA-G-007 | ExaDB VM Cluster | `terraform plan -detailed-exitcode` | Exit code `0`, no drift | Exit code `0`; Terraform reported `No changes. Your infrastructure matches the configuration.` | Pass | No `tfplan` was written |
| EXA-G-008 | ExaDB VM Cluster | Post-fix `terraform plan -no-color -refresh=false -lock=false` from the cluster example | Plan includes non-null `gi_version` and creates only remaining resources after failed apply | Plan creates VM Cluster and output JSON only; 2 add, 0 change, 0 destroy; `gi_version = "19.0.0.0"` | Pass | The failed apply already created the two `terraform_data` validation resources in state |

## JSON Handoff Matrix

Use the networking JSON files from `modules/odb-networking/examples/basic/output`
as the ODB dependency inputs for `modules/exadb/examples/cluster`. Keep the
Cloud Exadata Infrastructure dependency inline unless a separate Exadata
producer stack exists.

| ID | Area | Command / Action | Expected Result | Actual Result | Status | Evidence / Notes |
| --- | --- | --- | --- | --- | --- | --- |
| EXA-H-001 | JSON Handoff | Set `gcp_odb_networks_dependency_file_path` to the networking output JSON | Wrapper decodes JSON before calling the module | Plan decoded real `gcp_odb_networks_output.json` and resolved ODB Network key `primary` | Pass | First attempt exposed expected key mismatch with direct-map tfvars; corrected consumer key to `primary` for JSON handoff |
| EXA-H-002 | JSON Handoff | Set `gcp_odb_subnets_dependency_file_path` to the subnet output JSON | Wrapper decodes JSON and preserves subnet `purpose` | Plan decoded real `gcp_odb_subnets_output.json`; client and backup purpose validations passed | Pass | Uses generated networking JSON from user-run apply |
| EXA-H-003 | JSON Handoff | `cd modules/exadb/examples/cluster && terraform plan -no-color` | Plan resolves ODB Network/Subnet keys from decoded maps | Plan creates VM Cluster only; resolves ODB Network/Subnet IDs from decoded JSON maps; 4 add, 0 change, 0 destroy | Pass | Plan-only; no apply; no `tfplan` written |

## Single-Stack Plan Matrix

Use `modules/exadb/examples/vision` with local ignored `dgc.auto.tfvars` to
validate the customer-owned single-stack path where ODB networking, Cloud
Exadata Infrastructure, and Cloud VM Cluster are all declared in the same
Terraform state. This is plan-only because the test environment cannot create
Cloud Exadata Infrastructure.

| ID | Area | Command / Action | Expected Result | Actual Result | Status | Evidence / Notes |
| --- | --- | --- | --- | --- | --- | --- |
| EXA-S-001 | ExaDB Vision | Configure `gcp_cloud_exadata_infrastructures_configuration.primary` and VM Cluster `exadata_infrastructure_key = "primary"` | Plan resolves VM Cluster Exadata reference from the local Exadata Infrastructure configuration, not from an external dependency map | Plan creates ODB Network, client subnet, backup subnet, Cloud Exadata Infrastructure, VM Cluster, and validation data; 7 add, 0 change, 0 destroy | Pass | Plan-only; no apply; no `tfplan` written |

## Negative Test Matrix

Run these as plan-only checks. Do not apply negative scenarios.

| ID | Area | Command / Action | Expected Result | Actual Result | Status | Evidence / Notes |
| --- | --- | --- | --- | --- | --- | --- |
| EXA-N-001 | ExaDB VM Cluster | Use backup subnet as the client subnet | Plan fails because client subnet must be `CLIENT_SUBNET` | Plan failed with `external odb_subnet_key dependency must have purpose CLIENT_SUBNET` | Pass | Plan-only |
| EXA-N-002 | ExaDB VM Cluster | Set `backup_odb_subnet_key = "client"` and run `terraform plan -no-color` | Plan fails because backup subnet must be `BACKUP_SUBNET` | Plan failed with `external backup_odb_subnet_key dependency must have purpose BACKUP_SUBNET` | Pass | Plan-only |
| EXA-N-003 | ExaDB VM Cluster | Use an ODB subnet dependency whose project/location differs from the ODB Network | Plan fails before provider apply | Plan failed because client ODB subnet must belong to selected ODB Network, including project and location | Pass | Plan-only |
| EXA-N-004 | ExaDB Cluster Wrapper | Set both inline and file-path ODB Network dependency | Plan fails in `terraform_data.validate_dependency_sources` | Plan failed with `Set only one of gcp_odb_networks_dependency or gcp_odb_networks_dependency_file_path` | Pass | Plan-only |
| EXA-N-005 | ExaDB Cluster Wrapper | Set both inline and file-path ODB Subnet dependency | Plan fails in `terraform_data.validate_dependency_sources` | Plan failed with `Set only one of gcp_odb_subnets_dependency or gcp_odb_subnets_dependency_file_path` | Pass | Plan-only |
| EXA-N-006 | ExaDB Cluster Wrapper | Set both inline and file-path Exadata dependency | Plan fails in `terraform_data.validate_dependency_sources` | Plan failed with `Set only one of gcp_cloud_exadata_infrastructures_dependency or gcp_cloud_exadata_infrastructures_dependency_file_path` | Pass | Plan-only |
| EXA-N-007 | ExaDB Dependency | Use malformed `gcp_cloud_exadata_infrastructures_dependency.infra.id` | Plan fails variable validation | Plan failed variable validation for Cloud Exadata Infrastructure dependency ID format | Pass | Plan-only |

## Drift And Cleanup Matrix

| ID | Area | Command / Action | Expected Result | Actual Result | Status | Evidence / Notes |
| --- | --- | --- | --- | --- | --- | --- |
| EXA-D-001 | ExaDB Drift | Change ignored VM Cluster field `cpu_core_count` | No actionable drift for the ignored field | Exit code `0`; Terraform reported no changes after setting `cpu_core_count = 8` in ignored tfvars | Pass | Confirms Day-2 ignored capacity field does not produce a plan |
| EXA-D-002 | ExaDB Drift | Change a VM Cluster label after adding `labels` to `ignore_changes` and run `terraform plan -detailed-exitcode` | No actionable drift for label-only changes | Exit code `0`; Terraform reported no changes with a temporary label-only tfvars change | Pass | VM Cluster labels are treated as creation-time metadata because provider marks label changes as ForceNew when not ignored |
| EXA-D-003 | ExaDB Cleanup | User-only manual cleanup of the cluster example after restoring tfvars | VM Cluster is destroyed; external Exadata Infrastructure remains | | Not Run | Codex must not execute real-resource cleanup |
| EXA-D-004 | Repository Cleanup | `git status --short --ignored` | No generated files or real tfvars are tracked | Real tfvars, states, plans, provider locks, `.terraform/`, output JSON, and local tests are ignored | Pass | No generated Terraform artifact is introduced as a tracked file |

## Execution Log

| Timestamp | Tester | Test ID | Command / Action | Result | Evidence / Notes |
| --- | --- | --- | --- | --- | --- |
| 2026-05-19 12:52:28 CEST | Codex | EXA-L-004 | `terraform validate -no-color` in `modules/exadb` | Pass | Configuration is valid |
| 2026-05-19 12:52:28 CEST | Codex | EXA-L-006 | Init and validate `modules/exadb/examples/cluster` | Pass | Init succeeded; validation reported configuration is valid |
| 2026-05-19 12:52:28 CEST | Codex | EXA-L-007 | Init and validate `modules/exadb/examples/vision` | Pass | Init succeeded; validation reported configuration is valid |
| 2026-05-19 12:54:56 CEST | Codex | EXA-C-001..EXA-C-010 | Expanded local ignored `.tftest.hcl` coverage | Pass | Added local coverage for dependencies, network coherence, DB server OCIDs, output JSON, and wrapper conflicts |
| 2026-05-19 12:54:56 CEST | Codex | EXA-L-005 | First `terraform test -no-color` in `modules/exadb` after test expansion | Fail | Terraform test module cache was stale: `Module not installed` for new `module { source = "./examples/cluster" }` blocks |
| 2026-05-19 12:54:56 CEST | Codex | EXA-L-005 | `terraform init -backend=false` in `modules/exadb` | Pass | Installed new test module blocks and reused `hashicorp/google` `7.32.0` |
| 2026-05-19 12:54:56 CEST | Codex | EXA-L-005 | `terraform test -no-color` in `modules/exadb` | Pass | 19 passed, 0 failed |
| 2026-05-19 12:57:51 CEST | Codex | EXA-L-005 | `terraform test -no-color` in `modules/exadb` | Pass | Fresh rerun: 19 passed, 0 failed |
| 2026-05-19 13:16:41 CEST | Codex | EXA-G-001..EXA-G-004 | Created ignored `modules/exadb/examples/cluster/dgc.auto.tfvars` and ran `terraform plan -no-color -refresh=false -lock=false` | Pass | 4 add, 0 change, 0 destroy; creates VM Cluster only and references existing `demoinfra2` |
| 2026-05-19 13:33:04 CEST | Codex | EXA-H-001..EXA-H-003 | ExaDB plan using networking JSON output file paths | Pass | Decoded real networking JSON outputs; consumer key adjusted to `primary`; plan resolved ODB dependencies and created VM Cluster only |
| 2026-05-19 13:33:04 CEST | Codex | EXA-N-001..EXA-N-003 | Negative ExaDB subnet purpose and network coherence plans | Pass | Each plan failed before provider apply with the expected precondition message |
| 2026-05-19 13:33:04 CEST | Codex | EXA-N-004..EXA-N-006 | Negative wrapper inline-map plus file-path conflict plans | Pass | Each plan failed in `terraform_data.validate_dependency_sources` with the expected conflict message |
| 2026-05-19 13:33:04 CEST | Codex | EXA-N-007 | Negative malformed Cloud Exadata dependency ID plan | Pass | Plan failed variable validation for required full resource name format |
| 2026-05-19 14:06:55 CEST | Codex | EXA-G-001..EXA-G-004 | Updated ignored cluster tfvars to use real networking JSON handoff and ran `terraform plan -no-color -refresh=false -lock=false` | Pass | Plan creates only `dgc-vm-cluster`, output JSON, and validation data; 4 add, 0 change, 0 destroy |
| 2026-05-19 14:22:11 CEST | Codex | EXA-S-001 | Created ignored `modules/exadb/examples/vision/dgc.auto.tfvars` and ran `terraform plan -no-color -refresh=false -lock=false` | Pass | Single-stack customer path creates ODB networking, Cloud Exadata Infrastructure, and VM Cluster in one state; 7 add, 0 change, 0 destroy; no apply; no `tfplan` written |
| 2026-05-19 14:29:38 CEST | User | EXA-G-005 | User-run `terraform apply tfplan` in `modules/exadb/examples/cluster` | Fail | Google API rejected VM Cluster creation because `giVersion` was null; `terraform_data` validation resources were created before the failure |
| 2026-05-19 14:29:38 CEST | Codex | EXA-C-011 | Added module validation and test coverage for required VM Cluster `gi_version` | Pass | `terraform test -no-color` in `modules/exadb`: 20 passed, 0 failed |
| 2026-05-19 14:29:38 CEST | Codex | EXA-G-008 | Post-fix `terraform plan -no-color -refresh=false -lock=false` in `modules/exadb/examples/cluster` | Pass | 2 add, 0 change, 0 destroy; remaining resources are VM Cluster and output JSON; `gi_version = "19.0.0.0"` |
| 2026-05-19 17:23:35 CEST | Codex | EXA-L-008 | Added and validated `modules/exadb/examples/oci-dbhome-handoff` | Pass | Example reads `gcp_cloud_vm_clusters_output.json`, validates `ocid`/`AVAILABLE`, and passes OCI OCID to upstream OCI Exadata DB Home module |
| 2026-05-19 18:20:44 CEST | User | EXA-G-005 | User-run post-fix `terraform apply tfplan` in `modules/exadb/examples/cluster` | Pass | User reported `Apply complete! Resources: 2 added, 0 changed, 0 destroyed.` |
| 2026-05-19 18:20:44 CEST | Codex | EXA-G-006 | `terraform output -json` and output JSON inspection in `modules/exadb/examples/cluster` | Pass | VM Cluster output is keyed by `primary`, `state = AVAILABLE`, and includes an OCI Cloud VM Cluster OCID for handoff |
| 2026-05-19 18:20:44 CEST | Codex | EXA-G-007 | `terraform plan -detailed-exitcode -no-color` in `modules/exadb/examples/cluster` | Pass | Exit code `0`; Terraform reported no changes |
| 2026-05-19 18:20:44 CEST | Codex | EXA-L-008 | Inspected downloaded upstream OCI Exadata module in `.terraform/modules` | Pass | Upstream `cloud_db_homes_configuration.vm_cluster_id` accepts a direct OCI OCID and passes it to `oci_database_db_home.vm_cluster_id` |
| 2026-05-19 18:28:16 CEST | Codex | EXA-D-001 | Temporarily changed ignored `cpu_core_count` in ignored cluster tfvars and ran `terraform plan -detailed-exitcode -no-color` | Pass | Exit code `0`; Terraform reported no changes |
| 2026-05-19 18:28:16 CEST | Codex | EXA-D-002 | Temporarily changed managed VM Cluster label in ignored cluster tfvars and ran `terraform plan -detailed-exitcode -no-color` | Pass | Exit code `2`; provider planned VM Cluster replacement due label ForceNew behavior |
| 2026-05-19 18:28:16 CEST | Codex | EXA-G-007 | Restored ignored cluster tfvars and reran `terraform plan -detailed-exitcode -no-color` | Pass | Exit code `0`; Terraform reported no changes after restoring test inputs |
| 2026-05-19 18:34:22 CEST | Codex | EXA-D-002 | Re-ran label-only drift check before changing module lifecycle | Fail as expected | Exit code `2`; provider planned VM Cluster replacement for a label-only change |
| 2026-05-19 18:34:22 CEST | Codex | EXA-D-002 | Added `labels` to VM Cluster `ignore_changes` and re-ran same label-only drift check | Pass | Exit code `0`; Terraform reported no changes |
| 2026-05-19 18:35:13 CEST | Codex | EXA-L-002 | `terraform fmt -check -recursive modules` | Pass | Exit code `0` |
| 2026-05-19 18:35:13 CEST | Codex | EXA-L-004 | `terraform validate -no-color` in `modules/exadb` | Pass | Configuration is valid |
| 2026-05-19 18:35:13 CEST | Codex | EXA-L-005 | `terraform test -no-color` in `modules/exadb` | Pass | 20 passed, 0 failed |
| 2026-05-19 18:35:13 CEST | Codex | EXA-L-006 | `terraform validate -no-color` in `modules/exadb/examples/cluster` | Pass | Configuration is valid |
| 2026-05-19 18:35:13 CEST | Codex | EXA-G-007 | Restored ignored cluster tfvars and reran `terraform plan -detailed-exitcode -no-color` | Pass | Exit code `0`; Terraform reported no changes |
| 2026-05-19 18:35:13 CEST | Codex | EXA-L-003 | `git diff --check` | Pass | Exit code `0` |

## Publication Checklist

| Item | Required Result | Status | Evidence / Notes |
| --- | --- | --- | --- |
| Local formatting and diff checks pass | `EXA-L-001` through `EXA-L-003` are `Pass` | Pass | No generated Terraform artifacts are introduced as tracked files; fmt and diff checks returned exit code `0` |
| ExaDB local validation passes | `EXA-L-004` and `EXA-L-005` are `Pass` | Pass | `validate` passed; `terraform test` reported 20 passed, 0 failed |
| Examples validate | `EXA-L-006` through `EXA-L-008` are `Pass` | Pass | Cluster, vision, and OCI DB Home handoff examples initialized and validated |
| VM Cluster user-run real apply passes | `EXA-G-001` through `EXA-G-008` are `Pass` | Pass | First user-run apply failed because `gi_version` was missing; post-fix user-run apply, output check, and no-drift check now pass |
| JSON handoff path validates | `EXA-H-001` through `EXA-H-003` are `Pass` | Pass | Real networking JSON output files decode into ExaDB plan when consumer keys match producer output keys |
| ExaDB single-stack customer path validates | `EXA-S-001` is `Pass` | Pass | Plan-only coverage for local Exadata Infrastructure plus VM Cluster key resolution; no Cloud Exadata Infrastructure apply |
| Negative plan checks fail as expected | `EXA-N-001` through `EXA-N-007` are `Pass` | Pass | Purpose, network coherence, wrapper conflict, and malformed dependency checks fail before apply |
| Drift checks behave as expected | `EXA-D-001` and `EXA-D-002` are `Pass` | Pass | Ignored capacity drift is suppressed; VM Cluster label drift is also suppressed to avoid provider ForceNew replacement |
| Cleanup completed | `EXA-D-003` through `EXA-D-004` are `Pass` | Not Run | Real resource cleanup is user-only and remains pending |
| Scope statement is accurate for release notes | Cloud Exadata Infrastructure creation is not claimed as real-applied | Pass | Real apply coverage is VM Cluster only; Cloud Exadata Infrastructure creation remains plan/local-contract coverage |

## Residual Risk

- Cloud Exadata Infrastructure creation is not validated with a real Google
  Cloud apply in this release test plan.
- VM Cluster creation depends on regional capacity, entitlement, IAM, DB server
  availability, and the health of the existing Cloud Exadata Infrastructure.
- ODB Networking dependencies are assumed certified through
  `TESTING_ODBNETWORKING.md`.
- The current Google provider marks Cloud VM Cluster label changes as
  replacement when not ignored. The module treats VM Cluster labels as
  creation-time metadata to avoid accidental replacement.
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
