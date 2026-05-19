# Release Testing - ADB

This document tracks release validation for `modules/adb`.

ODB Networking release validation is tracked separately in
`TESTING_ODBNETWORKING.md`. ExaDB release validation is tracked separately in
`TESTING.md`.

It is intended to be filled in during release testing. Do not record secrets,
private keys, passwords, sensitive tfvars, or customer-specific values in this
file.

## Scope

### In Scope

- Local Terraform formatting, validation, and contract tests.
- Example validation for `modules/adb/examples/vision` and
  `modules/adb/examples/existing-odb-network`.
- Plan-only validation using the real `dgc` ODB Network and client subnet
  created by the ODB networking release tests.
- JSON handoff validation for ODB networking outputs consumed by the ADB
  existing-network example.
- Negative plan-time validation checks for dependency contracts and subnet
  purpose rules.

### Out Of Scope

- Any `terraform apply` executed by Codex.
- Real Autonomous Database creation until the user manually applies a reviewed
  plan.
- ODB Networking creation or certification; tracked in
  `TESTING_ODBNETWORKING.md`.
- ExaDB validation; tracked in `TESTING.md`.
- Autonomous Database Day-2 operations through OCI.
- Legacy VPC/CIDR mode.
- Any reusable module behavior that consumes dependency JSON file paths
  directly.

### Agent Execution Boundary

Codex must never execute `terraform apply` in this repository. Plan generation,
validation, schema inspection, and test commands may be executed by the agent.
Any real GCP apply step in this document is a user-only manual action.

## Environment

| Field | Value |
| --- | --- |
| Test run ID | `adb-plan-20260519-191827` |
| Tester | Codex |
| Date | 2026-05-19 19:18 CEST |
| Terraform version | `1.15.1` (`darwin_arm64`) |
| Google provider lock version | `7.32.0` |
| GCP project | `omcpmpoc2` |
| GCP region | `europe-west2` |
| Existing ODB Network | `projects/omcpmpoc2/locations/europe-west2/odbNetworks/dgc-odb-network` |
| Existing client ODB Subnet | `projects/omcpmpoc2/locations/europe-west2/odbNetworks/dgc-odb-network/odbSubnets/dgc-odb-client` |
| Existing backup ODB Subnet | `projects/omcpmpoc2/locations/europe-west2/odbNetworks/dgc-odb-network/odbSubnets/dgc-odb-backup` |
| ADB ID planned | `dgc-adb` |
| DB version planned | `23ai` |
| DB workload planned | `OLTP` |

## Test Data

Use local ignored tfvars files based on the example templates. Do not commit
real test inputs or admin passwords.

The plan-only ADB test uses:

- `modules/adb/examples/existing-odb-network/dgc.auto.tfvars`
- `TF_VAR_gcp_autonomous_databases_admin_passwords` for the admin password
- ODB networking JSON handoff files from
  `modules/odb-networking/examples/basic/output`

Required tracking labels for test tfvars:

```hcl
default_labels = {
  managed_by = "terraform"
  test_owner = "dgc"
  test_scope = "oracle-database-at-gcp"
  cleanup    = "manual"
}
```

## Local Validation Matrix

| ID | Area | Command / Action | Expected Result | Actual Result | Status | Evidence / Notes |
| --- | --- | --- | --- | --- | --- | --- |
| ADB-L-001 | Repository | `git status --short --ignored` | Dirty worktree understood; ignored test files are not tracked | Existing ExaDB/TESTING tracked changes plus ignored local Terraform/test artifacts | Pass | No cleanup or revert performed |
| ADB-L-002 | ADB Schema | `terraform providers schema -json > /tmp/adb-provider-schema.json` from `modules/adb` | Schema generated for installed Google provider | Schema generated after sandbox escalation | Pass | Sandbox plugin loading failed first; reran per `AGENTS.md` |
| ADB-L-003 | ADB Schema | `jq` inspect `google_oracle_database_autonomous_database` | Resource exposes ODB Network/Subnet attributes and expected properties | `odb_network`, `odb_subnet`, labels, and ignored property fields confirmed | Pass | Google provider `7.32.0` |
| ADB-L-004 | ADB Module | `cd modules/adb && terraform validate -no-color` | Configuration is valid | Configuration is valid | Pass | |
| ADB-L-005 | ADB Module | `cd modules/adb && terraform test -no-color` | All local tests pass | 38 passed, 0 failed | Pass | Duplicate-name tests removed to align with OCI-style provider/API uniqueness |
| ADB-L-006 | ADB Existing ODB Example | `cd modules/adb/examples/existing-odb-network && terraform init -backend=false && terraform validate -no-color` | Init and validation pass | Init and validation pass | Pass | Reused installed providers |
| ADB-L-007 | ADB Vision Example | `cd modules/adb/examples/vision && terraform init -backend=false && terraform validate -no-color` | Init and validation pass | Init and validation pass | Pass | Reused installed providers |

## Local Contract Coverage

| ID | Module | Contract | Expected Coverage | Status | Evidence / Notes |
| --- | --- | --- | --- | --- | --- |
| ADB-C-001 | ADB | `module_name` label compatibility | Invalid module names are rejected | Pass | `rejects_invalid_module_name_for_gcp_label` |
| ADB-C-002 | ADB | Display name defaults and module label | Defaults and sanitized module label are planned | Pass | `defaults_display_name_and_sanitizes_module_label` |
| ADB-C-003 | ADB | Dependency maps | Direct and wrapped dependency maps are accepted | Pass | `accepts_direct_and_wrapped_dependency_maps` |
| ADB-C-004 | ADB | Dependency transport | JSON file paths are rejected by reusable module inputs | Pass | Network and subnet path rejection tests |
| ADB-C-005 | ADB | ODB Network-only contract | Legacy VPC/CIDR mode is rejected | Pass | `rejects_vpc_cidr_mode` |
| ADB-C-006 | ADB | Required references | Missing ODB references and missing dependency keys fail at plan time | Pass | Missing subnet/network/subnet key tests |
| ADB-C-007 | ADB | Subnet purpose | Backup subnet is rejected for ADB | Pass | `rejects_backup_subnet_dependency_for_adb` |
| ADB-C-008 | ADB | Network coherence | ODB subnet must belong to selected ODB Network | Pass | `rejects_mismatched_subnet_parent_network` |
| ADB-C-009 | ADB | Provider/API uniqueness | Duplicate ADB IDs are left to the Google provider/API | Pass | OCI-style scope decision; no standalone `terraform_data` uniqueness resource |
| ADB-C-010 | ADB | Property validation | Enums, backup retention range, and contact email are validated | Pass | `rejects_invalid_property_enums_ranges_and_contacts` |
| ADB-C-011 | ADB | Output JSON | `output_path` writes wrapped ADB JSON | Pass | `plans_dependency_output_file_when_output_path_is_set` |
| ADB-C-012 | ADB Examples | Vision composition | ODB networking and ADB compose in one stack | Pass | `vision_example_composes_odb_networking_and_adb` |
| ADB-C-013 | ADB Examples | JSON handoff | Existing ODB example decodes JSON file paths | Pass | `existing_odb_network_example_decodes_dependency_file_paths` |
| ADB-C-014 | ADB Examples | Wrapper conflicts | Inline map plus file path conflicts fail | Pass | Network and subnet wrapper conflict tests |
| ADB-C-015 | ADB | Admin password policy | Invalid admin passwords fail at plan time | Pass | Too short, missing uppercase, missing lowercase, missing number, containing `admin`, and containing double quote are rejected |
| ADB-C-016 | ADB | Extended dependency output | Wrapped output JSON includes OCI, connection, endpoint, and peer metadata fields | Pass | `plans_dependency_output_file_when_output_path_is_set` asserts new output keys |
| ADB-C-017 | ADB | Database name format | Invalid `database` names fail before provider apply | Pass | `rejects_invalid_database_name_format`, `rejects_database_names_longer_than_30_characters` |
| ADB-C-018 | ADB | Provider/API database uniqueness | Duplicate `database` names are left to the Google provider/API | Pass | The module validates database name format only, matching OCI-style scope |
| ADB-C-019 | ADB | Google label syntax | Invalid default and per-resource labels fail at plan time | Pass | `rejects_invalid_default_labels`, `rejects_invalid_resource_labels` |
| ADB-C-020 | ADB | Project/location hygiene | Whitespace-only project or location values are rejected | Pass | Default and per-resource project/location tests |
| ADB-C-021 | ADB | Operations Insights enum | Unsupported `operations_insights_state` values are rejected | Pass | `rejects_invalid_operations_insights_state` |
| ADB-C-022 | ADB | Private endpoint IP | CIDR-style or invalid endpoint IP values are rejected | Pass | `rejects_invalid_private_endpoint_ip` |
| ADB-C-023 | ADB | Optional provider strings | Exposed optional string properties cannot be whitespace-only | Pass | Character set, N character set, DB version, private endpoint label, secret ID, and vault ID tests |

## GCP Plan Matrix

Use `modules/adb/examples/existing-odb-network` with local ignored
`dgc.auto.tfvars`. Provide the admin password only through
`TF_VAR_gcp_autonomous_databases_admin_passwords`.

| ID | Area | Command / Action | Expected Result | Actual Result | Status | Evidence / Notes |
| --- | --- | --- | --- | --- | --- | --- |
| ADB-G-001 | ADB Existing ODB Network | Configure dependency file paths to real networking outputs | ODB Network key `primary` and subnet key `client` resolve to real resources | Plan resolved `dgc-odb-network` and `dgc-odb-client` from JSON handoff | Pass | Uses existing ODB networking test stack |
| ADB-G-002 | ADB Existing ODB Network | `terraform plan -no-color -refresh=false -lock=false` | Plan creates one ADB and wrapper validation data only | Plan creates `dgc-adb` plus wrapper dependency validation; module-level uniqueness `terraform_data` has been removed | Pass | Plan-only; no `tfplan` written by Codex |
| ADB-G-003 | ADB Existing ODB Network | Confirm plan labels and IDs | All created resources use `dgc` prefix and tracking labels | `dgc-adb` and required labels present | Pass | Admin password shown only as sensitive |

## Negative Plan Matrix

| ID | Area | Command / Action | Expected Result | Actual Result | Status | Evidence / Notes |
| --- | --- | --- | --- | --- | --- | --- |
| ADB-N-001 | ADB Existing ODB Network | Temporarily set `odb_subnet_key = "backup"` with real networking JSON | Plan fails before provider apply because ADB requires a client subnet | Plan failed with `odb_subnet_key must reference an ODB subnet with purpose CLIENT_SUBNET` | Pass | Plan-only; tfvars restored immediately after the check |

## Drift And Cleanup Matrix

| ID | Area | Command / Action | Expected Result | Actual Result | Status | Evidence / Notes |
| --- | --- | --- | --- | --- | --- | --- |
| ADB-D-001 | ADB Apply | User-only manual apply of reviewed ADB plan | ADB reaches `AVAILABLE` | User reported `Apply complete! Resources: 3 added, 0 changed, 0 destroyed.` and output state `AVAILABLE` | Pass | Codex did not execute apply |
| ADB-D-002 | ADB Outputs | `terraform output gcp_autonomous_databases` after user apply | Output contains key `primary`, state, OCID, and connection strings | Output contains `primary`, `state = AVAILABLE`, OCI OCID, OCI URL, and connection strings | Pass | Verified with `terraform output -json` |
| ADB-D-003 | ADB Drift | `terraform plan -detailed-exitcode -no-color` after user apply | Exit code `0`, no drift | Exit code `0`; Terraform reported `No changes. Your infrastructure matches the configuration.` | Pass | Initial sandbox run failed to load plugins; escalated plan succeeded |
| ADB-D-004 | ADB Dependency Drift | Switch the existing-network example from JSON file handoff to inline dependency maps and run `terraform plan -detailed-exitcode -no-color` | Exit code `0`, no drift | Exit code `0`; Terraform reported no changes | Pass | Confirms direct dependency maps and JSON-decoded dependency maps are behaviorally equivalent |
| ADB-D-005 | ADB Day-2 Drift | Temporarily change `properties.compute_count` and run `terraform plan -detailed-exitcode -no-color` | Exit code `0`, no drift | Exit code `0`; Terraform reported no changes | Pass | Capacity field is intentionally ignored per Oracle Day-2 guidance |
| ADB-D-006 | ADB Label Drift | Temporarily change only an ADB label and run `terraform plan -detailed-exitcode -no-color` | No replacement or actionable drift after adding `labels` to `ignore_changes` | Initial plan showed replacement for label-only change; after adding `labels` to `ignore_changes`, exit code `0` and no changes | Pass | ADB labels are treated as creation-time metadata because provider marks label changes as ForceNew when not ignored |
| ADB-D-007 | ADB Cleanup | User-only manual cleanup of ADB test resource | `dgc-adb` is destroyed; ODB Network remains for other tests | User reported `module.oracle_autonomous_database_at_gcp.google_oracle_database_autonomous_database.these["primary"]: Destruction complete after 6m14s` and `terraform_data.validate_dependency_sources: Destruction complete after 0s` | Pass | Codex did not execute cleanup |
| ADB-D-008 | Repository Cleanup | `git status --short --ignored` | No generated files or real tfvars are tracked | Only code/docs are tracked or untracked for review; real tfvars, states, plans, provider locks, `.terraform/`, and local tests are ignored | Pass | User-only resource cleanup remains not run |

## Execution Log

| Timestamp | Tester | Test ID | Command / Action | Result | Evidence / Notes |
| --- | --- | --- | --- | --- | --- |
| 2026-05-19 19:18:27 CEST | Codex | ADB-L-002..ADB-L-003 | Generated and inspected provider schema | Pass | Initial sandbox run failed to load plugins; escalated schema generation succeeded |
| 2026-05-19 19:18:27 CEST | Codex | ADB-L-004 | `terraform validate -no-color` in `modules/adb` | Pass | Configuration is valid |
| 2026-05-19 19:18:27 CEST | Codex | ADB-L-005 | Expanded ignored local ADB tests and ran `terraform test -no-color` | Pass | 18 passed, 0 failed; first rerun required `terraform init -backend=false` for new test module block |
| 2026-05-19 19:18:27 CEST | Codex | ADB-L-006 | Init and validate `modules/adb/examples/existing-odb-network` | Pass | Configuration is valid |
| 2026-05-19 19:18:27 CEST | Codex | ADB-L-007 | Init and validate `modules/adb/examples/vision` | Pass | Configuration is valid |
| 2026-05-19 19:18:27 CEST | Codex | ADB-G-001..ADB-G-003 | Created ignored `dgc.auto.tfvars` and ran ADB plan using real ODB networking JSON | Pass | 3 add, 0 change, 0 destroy; `dgc-adb` planned with `dgc` labels |
| 2026-05-19 19:18:27 CEST | Codex | ADB-N-001 | Temporarily changed ADB subnet key to `backup` and ran plan | Pass | Plan failed before provider apply with expected client subnet precondition |
| 2026-05-19 19:18:27 CEST | Codex | ADB-L-004..ADB-L-007 | Final local verification pass | Pass | `terraform fmt -check -recursive modules`, ADB validate/test, both example validates, and `git diff --check` passed |
| 2026-05-19 19:18:27 CEST | Codex | ADB-G-002 | Final ADB plan using restored tfvars | Pass | 3 add, 0 change, 0 destroy; no `tfplan` written |
| 2026-05-19 19:33:06 CEST | User | ADB-D-001 | User-run `terraform apply tfplan` in `modules/adb/examples/existing-odb-network` | Pass | Apply completed after 7m20s; 3 added, 0 changed, 0 destroyed; state `AVAILABLE` |
| 2026-05-19 19:33:06 CEST | Codex | ADB-D-002 | `terraform output -json` in `modules/adb/examples/existing-odb-network` | Pass | Output contains key `primary`, state `AVAILABLE`, OCI OCID, OCI URL, and connection strings |
| 2026-05-19 19:33:06 CEST | Codex | ADB-D-003 | `terraform plan -detailed-exitcode -no-color` in `modules/adb/examples/existing-odb-network` | Pass | Exit code `0`; Terraform reported no changes |
| 2026-05-19 19:46:12 CEST | Codex | ADB-D-004 | Replaced JSON dependency file paths with inline dependency maps and ran `terraform plan -detailed-exitcode -no-color` | Pass | Exit code `0`; Terraform reported no changes |
| 2026-05-19 19:46:12 CEST | Codex | ADB-D-005 | Temporarily changed `compute_count` from `2` to `4` and ran `terraform plan -detailed-exitcode -no-color` | Pass | Exit code `0`; Terraform reported no changes |
| 2026-05-19 19:46:12 CEST | Codex | ADB-D-006 | Temporarily changed only `labels.test_resource` before and after adding `labels` to ADB `ignore_changes` | Pass | Initial plan showed replacement; after lifecycle update, exit code `0` with no changes |
| 2026-05-19 19:48:38 CEST | Codex | ADB-D-003 | Restored JSON handoff tfvars and reran `terraform plan -detailed-exitcode -no-color` | Pass | Exit code `0`; Terraform reported no changes |
| 2026-05-19 19:51:02 CEST | Codex | ADB-L-004..ADB-L-007 | Final validation after ADB label lifecycle update | Pass | `terraform fmt -check -recursive modules`, ADB `validate`, ADB `test` 18/18, both example `init -backend=false` and `validate` passed |
| 2026-05-19 19:51:02 CEST | Codex | ADB-D-008 | Checked repository status and whitespace | Pass | `git status --short --ignored` confirmed generated artifacts are ignored; `git diff --check` passed |
| 2026-05-19 19:51:43 CEST | Codex | ADB-C-015..ADB-C-016 | Added admin password validation tests and extended output JSON assertions | Pass | Red/green cycle completed; `terraform test -no-color` reported 24 passed, 0 failed |
| 2026-05-19 19:51:43 CEST | Codex | ADB-L-004..ADB-L-007 | Final local verification after extended outputs and password validation | Pass | `terraform fmt -check -recursive modules`, ADB `validate`, ADB `test` 24/24, and both example validates passed |
| 2026-05-19 19:51:43 CEST | Codex | ADB-D-003 | Attempted post-change real no-drift plan from the current example state | Not Used | Current `terraform.tfstate` is empty and planned creates; backup state was inspected read-only but not restored. Codex did not apply or mutate state |
| 2026-05-19 21:09:59 CEST | User | ADB-D-007 | User-run cleanup of ADB test resource | Pass | ADB resource destruction completed after 6m14s; wrapper `terraform_data.validate_dependency_sources` destruction completed after 0s |
| 2026-05-19 21:15:40 CEST | Codex | ADB-C-017..ADB-C-023 | Added provider-field validation tests and implementation | Pass | Red/green cycle completed; `terraform test -no-color` reported 40 passed, 0 failed |
| 2026-05-19 21:55:57 CEST | Codex | ADB-C-009, ADB-C-018, ADB-L-004..ADB-L-007 | Removed standalone uniqueness `terraform_data` to align with OCI module style | Pass | ADB `validate`, `terraform test` 38/38, and both ADB examples `init -backend=false` plus `validate` passed |
| 2026-05-19 21:16:44 CEST | Codex | ADB-L-004..ADB-L-007 | Historical final local verification after provider-field validations | Pass | At that point `terraform test` reported 40/40; later uniqueness-scope alignment removed two duplicate-name tests, so current coverage is 38/38 |

## Publication Checklist

| Item | Required Result | Status | Evidence / Notes |
| --- | --- | --- | --- |
| ADB local validation passes | `ADB-L-004` and `ADB-L-005` are `Pass` | Pass | `validate` passed; `terraform test` reported 38 passed, 0 failed |
| ADB examples validate | `ADB-L-006` and `ADB-L-007` are `Pass` | Pass | Existing ODB Network and vision examples initialized and validated |
| ADB provider schema checked | `ADB-L-002` and `ADB-L-003` are `Pass` | Pass | Google provider `7.32.0`; schema inspected from `/tmp/adb-provider-schema.json` |
| ADB existing ODB Network plan passes | `ADB-G-001` through `ADB-G-003` are `Pass` | Pass | Plan creates one ADB using real ODB networking JSON |
| Negative plan checks fail as expected | `ADB-N-001` is `Pass` | Pass | Backup subnet is rejected before provider apply |
| ADB user-run real apply passes | `ADB-D-001` through `ADB-D-003` are `Pass` | Pass | User-run apply, output verification, and no-drift check passed |
| ADB Day-2 drift checks pass | `ADB-D-004` through `ADB-D-006` are `Pass` | Pass | Inline dependency maps, compute count drift, and label-only drift checks all report no changes |
| Cleanup completed | `ADB-D-007` through `ADB-D-008` are `Pass` | Pass | User-run ADB resource cleanup completed; repository generated artifacts remain ignored |

## Residual Risk

- ADB creation depends on regional capacity, entitlement, IAM, service limits,
  and the health of the existing ODB Network and client subnet.
- Admin passwords are supplied outside committed tfvars via
  `TF_VAR_gcp_autonomous_databases_admin_passwords` and are now validated at
  plan time.
- Local tests use Terraform mock providers and validate module contracts, not
  all runtime behavior of the Google Cloud Oracle Database API.
- Labels are intentionally treated as creation-time metadata for ADB because
  the current Google provider plans replacement for label-only changes.
- The post-change real no-drift plan was not re-established before cleanup
  because the current local example state was empty. The ADB test resource has
  now been removed by the user.

## Release Decision

| Decision | Selected | Notes |
| --- | --- | --- |
| Publish | | |
| Block | | |
| Publish with documented residual risk | | |
