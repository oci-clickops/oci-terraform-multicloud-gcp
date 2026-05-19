# Release Testing - ODB Networking

This document tracks release validation for `modules/odb-networking`.

Do not record secrets, private keys, passwords, sensitive tfvars, or
customer-specific values in this file.

## Scope

### In Scope

- Local Terraform formatting, validation, and contract tests.
- Example validation for `modules/odb-networking/examples/basic`.
- User-run Google Cloud execution for one ODB Network and two ODB Subnets.
- JSON handoff validation for downstream ExaDB and ADB consumers.
- Negative plan-time validation checks for ODB Networking contracts.
- Drift checks and user-run cleanup tracking for networking resources.

### Out Of Scope

- Any `terraform apply` executed by Codex.
- Google Cloud VPC creation.
- ExaDB validation; tracked in `TESTING.md`.
- ADB validation; tracked in `TESTING_ADB.md`.
- Any reusable module behavior that consumes dependency JSON file paths
  directly.

### Agent Execution Boundary

Codex must never execute `terraform apply` in this repository. Plan generation,
validation, schema inspection, and test commands may be executed by the agent.
Any real GCP apply step in this document is a user-only manual action. Cleanup
of real GCP resources is also user-only unless the user explicitly changes that
boundary in a later session.

## Environment

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
| Tracking labels | Required label map shown above | Present in ignored `dgc.auto.tfvars` |

## Local Validation Matrix

| ID | Area | Command / Action | Expected Result | Actual Result | Status | Evidence / Notes |
| --- | --- | --- | --- | --- | --- | --- |
| ODB-L-001 | Repository | `git status --short` | Dirty worktree understood; no generated files staged | Existing tracked docs/module changes and ignored local artifacts | Pass | No cleanup or revert performed |
| ODB-L-002 | Repository | `terraform fmt -check -recursive modules` | Exit code `0` | Exit code `0` | Pass | Re-run after hardening changes |
| ODB-L-003 | Repository | `git diff --check` | Exit code `0` | Exit code `0` | Pass | Re-run before final handoff |
| ODB-L-004 | ODB Networking | `cd modules/odb-networking && terraform validate -no-color` | Configuration is valid | Configuration is valid | Pass | Terraform reported `Success! The configuration is valid.` |
| ODB-L-005 | ODB Networking | `cd modules/odb-networking && terraform test -no-color` | All local tests pass | 19 passed, 0 failed | Pass | Expanded from 12 tests to cover labels, non-empty defaults/overrides, and required GCP Oracle zone |
| ODB-L-006 | ODB Networking Example | `cd modules/odb-networking/examples/basic && terraform init -backend=false && terraform validate -no-color` | Init and validation pass | Init and validation pass | Pass | Reused installed `hashicorp/google` `7.32.0` and `hashicorp/local` `2.9.0` |

## Local Contract Coverage

| ID | Contract | Expected Coverage | Status | Evidence / Notes |
| --- | --- | --- | --- | --- |
| ODB-C-001 | Resource IDs | Valid and invalid ODB Network/Subnet IDs are tested | Pass | `creates_network_and_subnets_with_keyed_outputs`; `rejects_invalid_odb_network_and_subnet_ids` |
| ODB-C-002 | VPC reference | `network` must use `projects/<project>/global/networks/<network>` | Pass | `rejects_invalid_network_resource_name` |
| ODB-C-003 | CIDR validation | Valid and invalid `cidr_range` values are tested | Pass | `creates_network_and_subnets_with_keyed_outputs`; `rejects_invalid_cidr_range` |
| ODB-C-004 | Subnet purpose | Only `CLIENT_SUBNET` and `BACKUP_SUBNET` are accepted | Pass | `creates_network_and_subnets_with_keyed_outputs`; `rejects_invalid_subnet_purpose` |
| ODB-C-005 | Parent reference mutex | Each subnet sets exactly one of `odbnetwork` or `odb_network_key` | Pass | `rejects_subnet_without_exactly_one_parent_reference`; `rejects_subnet_with_two_parent_references` |
| ODB-C-006 | Parent key resolution | Invalid `odb_network_key` fails at plan time | Pass | `rejects_missing_parent_odb_network_key` |
| ODB-C-007 | Resource uniqueness | Duplicate IDs fail within the provider scope | Pass | `rejects_duplicate_odb_network_ids`; `rejects_duplicate_odb_subnet_ids` |
| ODB-C-008 | JSON handoff | `output_path` writes wrapped network and subnet JSON | Pass | `plans_dependency_output_files_when_output_path_is_set` |
| ODB-C-009 | Default hygiene | Whitespace-only project, location, and GCP Oracle zone defaults are rejected | Pass | `rejects_empty_default_project_location_and_zone` |
| ODB-C-010 | Google label syntax | Invalid default, ODB Network, and ODB Subnet labels fail at plan time | Pass | `rejects_invalid_default_labels`; `rejects_invalid_network_labels`; `rejects_invalid_subnet_labels` |
| ODB-C-011 | Required GCP Oracle zone | ODB Networks require `gcp_oracle_zone` or `default_gcp_oracle_zone` | Pass | `rejects_network_without_gcp_oracle_zone` |

## GCP Integration Matrix

Use `modules/odb-networking/examples/basic` with a local ignored tfvars file.
Set `default_deletion_protection = false` and `output_path = "./output"` for
test resources.

| ID | Area | Command / Action | Expected Result | Actual Result | Status | Evidence / Notes |
| --- | --- | --- | --- | --- | --- | --- |
| ODB-G-001 | ODB Networking | `terraform plan -no-color -refresh=false -lock=false` from the basic example | Plan creates one ODB Network, one client subnet, and one backup subnet | Plan creates `dgc-odb-network`, `dgc-odb-client`, `dgc-odb-backup`, two output JSON `local_file` resources, and validation data; 6 add, 0 change, 0 destroy | Pass | Plan intentionally did not use `-out`; no `tfplan` written by Codex |
| ODB-G-002 | ODB Networking | User-only manual apply of the reviewed basic-example `tfplan` | Apply completes successfully | User reported `Apply complete! Resources: 6 added, 0 changed, 0 destroyed.` | Pass | Codex did not execute apply |
| ODB-G-003 | ODB Networking | `terraform output gcp_odb_networks` | Output contains key `primary` with a full ODB Network resource name | `primary.id` is `projects/omcpmpoc2/locations/europe-west2/odbNetworks/dgc-odb-network`; state `AVAILABLE` | Pass | Verified with `terraform output -json` |
| ODB-G-004 | ODB Networking | `terraform output gcp_odb_subnets` | Output contains keys `client` and `backup` with correct purposes | `client` is `CLIENT_SUBNET`; `backup` is `BACKUP_SUBNET`; both state `AVAILABLE` | Pass | Verified with `terraform output -json` |
| ODB-G-005 | ODB Networking | Inspect `output/gcp_odb_networks_output.json` | JSON is wrapped under `gcp_odb_networks` | JSON top-level key is `gcp_odb_networks`; `primary.state` is `AVAILABLE` | Pass | Verified with `jq` |
| ODB-G-006 | ODB Networking | Inspect `output/gcp_odb_subnets_output.json` | JSON is wrapped under `gcp_odb_subnets` and includes `purpose` | JSON top-level key is `gcp_odb_subnets`; client/backup include correct `purpose`, state, and CIDR | Pass | Verified with `jq` |
| ODB-G-007 | ODB Networking | `terraform plan -detailed-exitcode` after user apply | Exit code `0`, no drift | Exit code `0`; Terraform reported `No changes. Your infrastructure matches the configuration.` | Pass | Drift check performed after user-run apply |

## Consumer Handoff Matrix

| ID | Area | Command / Action | Expected Result | Actual Result | Status | Evidence / Notes |
| --- | --- | --- | --- | --- | --- | --- |
| ODB-H-001 | ExaDB Handoff | Set `gcp_odb_networks_dependency_file_path` to the networking output JSON in ExaDB cluster example | Wrapper decodes JSON before calling `modules/exadb` | ExaDB plan decoded real `gcp_odb_networks_output.json` and resolved ODB Network key `primary` | Pass | Consumer keys were aligned to producer output keys |
| ODB-H-002 | ExaDB Handoff | Set `gcp_odb_subnets_dependency_file_path` to the subnet output JSON in ExaDB cluster example | Wrapper decodes JSON and preserves subnet `purpose` | ExaDB plan decoded real `gcp_odb_subnets_output.json`; client and backup purpose validations passed | Pass | Uses generated networking JSON from user-run apply |
| ODB-H-003 | ADB Handoff | Configure ADB existing-network example with networking JSON file paths | Wrapper decodes JSON and resolves the client subnet | ADB plan resolved `dgc-odb-network` and `dgc-odb-client` from JSON handoff | Pass | Detailed ADB validation is tracked in `TESTING_ADB.md` |

## Drift And Cleanup Matrix

| ID | Area | Command / Action | Expected Result | Actual Result | Status | Evidence / Notes |
| --- | --- | --- | --- | --- | --- | --- |
| ODB-D-001 | ODB Networking Drift | Change only ODB Network/Subnet labels after adding `labels` to `ignore_changes` and run `terraform plan -no-color -refresh=false -lock=false` | No actionable drift for label-only changes | Terraform reported no changes with a temporary label-only `-var` override | Pass | Before the lifecycle change, the same label-only override planned replacement of ODB Network and both ODB Subnets |
| ODB-D-002 | ODB Networking Cleanup | User-only manual cleanup of the basic networking example | Test ODB Subnets and ODB Network are destroyed | | Not Run | Codex must not execute real-resource cleanup |
| ODB-D-003 | Repository Cleanup | `git status --short --ignored` | No generated files or real tfvars are tracked | Real tfvars, states, plans, provider locks, `.terraform/`, output JSON, and local tests are ignored | Pass | No generated Terraform artifact is introduced as a tracked file |

## Execution Log

| Timestamp | Tester | Test ID | Command / Action | Result | Evidence / Notes |
| --- | --- | --- | --- | --- | --- |
| 2026-05-19 12:52:28 CEST | Codex | ODB-L-004 | `terraform validate -no-color` in `modules/odb-networking` | Pass | Configuration is valid |
| 2026-05-19 12:52:28 CEST | Codex | ODB-L-006 | Init and validate `modules/odb-networking/examples/basic` | Pass | Init succeeded; validation reported configuration is valid |
| 2026-05-19 12:54:56 CEST | Codex | ODB-C-001..ODB-C-008 | Expanded local ignored `.tftest.hcl` coverage | Pass | Added local coverage for invalid IDs, CIDR, parent keys, duplicate IDs, and output JSON |
| 2026-05-19 12:54:56 CEST | Codex | ODB-L-005 | `terraform test -no-color` in `modules/odb-networking` | Pass | 12 passed, 0 failed |
| 2026-05-19 12:57:51 CEST | Codex | ODB-L-005 | `terraform test -no-color` in `modules/odb-networking` | Pass | Fresh rerun: 12 passed, 0 failed |
| 2026-05-19 13:16:41 CEST | Codex | ODB-G-001 | Created ignored `modules/odb-networking/examples/basic/dgc.auto.tfvars` and ran `terraform plan -no-color -refresh=false -lock=false` | Pass | 6 add, 0 change, 0 destroy; dgc resource IDs, labels, VPC, and non-overlapping CIDRs present |
| 2026-05-19 13:29:21 CEST | User | ODB-G-002 | User-run `terraform apply tfplan` in `modules/odb-networking/examples/basic` | Pass | User reported `Apply complete! Resources: 6 added, 0 changed, 0 destroyed.` |
| 2026-05-19 13:29:21 CEST | Codex | ODB-G-003..ODB-G-004 | `terraform output -json` in `modules/odb-networking/examples/basic` | Pass | ODB Network and both ODB Subnets are keyed correctly and state `AVAILABLE` |
| 2026-05-19 13:29:21 CEST | Codex | ODB-G-005..ODB-G-006 | `jq` inspection of networking output JSON files | Pass | JSON files are wrapped under `gcp_odb_networks` and `gcp_odb_subnets`; subnet purpose and CIDRs present |
| 2026-05-19 13:29:21 CEST | Codex | ODB-G-007 | `terraform plan -detailed-exitcode -no-color` in `modules/odb-networking/examples/basic` | Pass | Exit code `0`; no drift |
| 2026-05-19 13:33:04 CEST | Codex | ODB-H-001..ODB-H-002 | ExaDB plan using networking JSON output file paths | Pass | Decoded real networking JSON outputs; consumer key adjusted to `primary`; plan resolved ODB dependencies |
| 2026-05-19 19:18:27 CEST | Codex | ODB-H-003 | ADB existing-network plan using real ODB networking JSON | Pass | ADB plan resolved `dgc-odb-network` and `dgc-odb-client` from JSON handoff |
| 2026-05-19 21:26:31 CEST | Codex | ODB-C-009..ODB-C-011 | Added ODB Networking hardening tests and implementation | Pass | Red/green cycle completed; `terraform test -no-color` reported 19 passed, 0 failed |
| 2026-05-19 21:26:31 CEST | Codex | ODB-D-001 | Ran ODB Networking label-only drift probe before and after adding `labels` to `ignore_changes` | Pass | Before lifecycle change, label-only plan proposed replacing ODB Network and both ODB Subnets; after lifecycle change, Terraform reported no changes |
| 2026-05-19 21:28:16 CEST | Codex | ODB-L-002..ODB-L-006, ODB-D-001 | Final ODB Networking verification after hardening | Pass | `terraform fmt -check -recursive modules`, ODB Networking `validate`, ODB Networking `test` 19/19, basic example `init -backend=false` and `validate`, and label-only plan all passed |

## Publication Checklist

| Item | Required Result | Status | Evidence / Notes |
| --- | --- | --- | --- |
| Local formatting and diff checks pass | `ODB-L-001` through `ODB-L-003` are `Pass` | Pass | No generated Terraform artifacts are introduced as tracked files; fmt and diff checks returned exit code `0` |
| ODB Networking local validation passes | `ODB-L-004` and `ODB-L-005` are `Pass` | Pass | `validate` passed; `terraform test` reported 19 passed, 0 failed |
| ODB Networking example validates | `ODB-L-006` is `Pass` | Pass | Basic example initialized and validated |
| ODB Networking user-run real apply passes | `ODB-G-001` through `ODB-G-007` are `Pass` | Pass | User-run apply passed; outputs, JSON handoff, and no-drift check passed |
| Consumer handoff validates | `ODB-H-001` through `ODB-H-003` are `Pass` | Pass | Real networking JSON output files decode into ExaDB and ADB consumer examples |
| Drift checks behave as expected | `ODB-D-001` is `Pass` | Pass | ODB Network and ODB Subnet label drift is suppressed to avoid provider ForceNew replacement |
| Cleanup completed | `ODB-D-002` through `ODB-D-003` are `Pass` | Not Run | Real resource cleanup is user-only and remains pending |

## Residual Risk

- ODB Networking creation depends on regional capacity, entitlement, IAM,
  service limits, and the health of the existing Google Cloud VPC.
- The current Google provider marks ODB Network and ODB Subnet label changes as
  replacement when not ignored. The module treats those labels as creation-time
  metadata to avoid accidental replacement.
- Local tests use Terraform mock providers and validate module contracts, not
  all runtime behavior of the Google Cloud Oracle Database API.

## Release Decision

| Decision | Selected | Notes |
| --- | --- | --- |
| Publish | | |
| Block | | |
| Publish with documented residual risk | | |
