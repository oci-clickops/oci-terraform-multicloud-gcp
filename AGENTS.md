# Agent Instructions

This repository contains Terraform modules for Oracle Database@Google Cloud using the HashiCorp Google provider. Keep future work aligned with the current module philosophy and decisions below.

## Working Style

- Communicate in Spanish with the user unless they switch language.
- Be direct, pragmatic, and engineering-focused. Avoid hype and vague reassurance.
- Read the codebase before changing it. Prefer existing patterns over new abstractions.
- Use `rg` / `rg --files` for search.
- Use `apply_patch` for manual edits. Do not write tracked files with shell heredocs or ad hoc scripts.
- The worktree may be dirty. Never revert changes you did not make unless the user explicitly asks.
- Before changing provider-sensitive behavior, verify against current official Google provider schema/docs. The module work so far was checked against `hashicorp/google` `7.32.0` on May 19, 2026.
- Run focused Terraform checks before claiming completion.

## Session Boot Sequence

At the start of a new session on this repo:

1. Read this `AGENTS.md`.
2. Run `git status --short` and assume dirty files may be intentional user or previous-agent work.
3. Inspect the specific module before making claims or changes.
4. If touching provider behavior, inspect current Google provider docs/schema first.
5. Preserve the decisions below unless the user explicitly changes them.

Do not restart the design from first principles unless the user asks for a redesign. The current goal is to keep `modules/odb-networking`, `modules/exadb`, and `modules/adb` consistent as a professional v1 module set.

## Module Philosophy

`modules/odb-networking`, `modules/exadb`, and `modules/adb` should look like they were built by the same team:

- OCI Landing Zones style:
  - resources declared through keyed maps;
  - `for_each` on those maps;
  - outputs keyed with the same logical keys;
  - explicit external dependency maps instead of copied resource IDs;
  - clear plan-time validations and actionable error messages.
- Keep v1 professional, simple, and maintainable. Prefer narrow, explicit behavior over supporting every provider option.
- The modules should be backend-agnostic. Do not make reusable modules read Terraform remote state, GCS, OCI Object Storage, local JSON paths, GitHub artifacts, etc.
- Transport-specific dependency loading belongs in wrappers/examples/orchestrators, not in reusable modules.

## Upstream Style References

These OCI Landing Zones modules were reviewed and are the main style references:

- `terraform-oci-modules-workloads/cis-compute-storage`
  - GitHub: `https://github.com/oci-landing-zones/terraform-oci-modules-workloads/tree/main/cis-compute-storage`
- `terraform-oci-modules-exadata/exadata-database`
  - GitHub: `https://github.com/oci-landing-zones/terraform-oci-modules-exadata/tree/main/exadata-database`

Use them as references for module philosophy, dependency contracts, keyed maps, outputs, examples, and documentation tone. The goal is that this repository feels like it was built by the same engineering team, while still respecting the particular needs of Oracle Database@Google Cloud and the HashiCorp Google provider.

Important interpretation:

- Follow the OCI LZ pattern of passing dependency maps into reusable modules.
- Follow the Compute example pattern where external JSON/Object Storage reading is done in an example/wrapper, not inside the reusable module.
- Do not copy OCI provider-specific resource shapes, OCID assumptions, compartment patterns, or Object Storage mechanics into Google modules unless there is a real Google equivalent and the user asks for it.
- Prefer consistency of design language over line-by-line imitation.
- When Google provider behavior differs, document the difference and keep the module contract simple.

## Non-Negotiable Guardrails

Do not change these without explicit user approval:

- Do not reintroduce VPC/CIDR as public module inputs.
- Do not make reusable modules consume JSON file paths.
- Do not remove direct-map or wrapped-map dependency support.
- Do not remove `output_path` JSON generation unless the user explicitly asks for a stricter pure-module contract.
- Do not commit generated Terraform artifacts or generated dependency JSON files.
- Do not weaken plan-time validations to make examples pass.
- Do not add broad abstractions, helper modules, or orchestration layers unless a real duplication or maintenance issue requires it.
- Do not silently change provider version constraints.

## Networking Decision

The current v1 decision is **ODB Network-only** for both modules:

- `modules/odb-networking` owns creation of `google_oracle_database_odb_network` and `google_oracle_database_odb_subnet`.
- `modules/exadb` VM Clusters use `odb_network`, `odb_subnet`, and `backup_odb_subnet`, either directly or through keys.
- `modules/adb` Autonomous Databases use `odb_network` and `odb_subnet`, either directly or through keys.
- `modules/exadb` and `modules/adb` consume ODB Network/Subnet resources; they do not create them.
- Do not reintroduce public `network` / `cidr` / `backup_subnet_cidr` interfaces in these modules unless the user explicitly changes this decision.
- If a user needs legacy VPC/CIDR behavior, recommend a tailored wrapper or direct Google provider resources outside this v1 module contract.

## Dependency Contract

Reusable modules accept dependency inputs only as Terraform maps:

- Direct map:

```hcl
gcp_odb_networks_dependency = {
  network = {
    id = "projects/<project>/locations/<region>/odbNetworks/<network>"
  }
}
```

- Wrapped map, matching dependency output JSON shape:

```hcl
gcp_odb_networks_dependency = {
  gcp_odb_networks = {
    network = {
      id = "projects/<project>/locations/<region>/odbNetworks/<network>"
    }
  }
}
```

Reusable modules must **not** accept this:

```hcl
gcp_odb_networks_dependency = "output/gcp_odb_networks_output.json"
```

JSON file paths are decoded only in example/wrapper modules with `jsondecode(file(...))`, then passed to the reusable module as maps.

## JSON Handoff Policy

`output_path` remains in reusable modules as an optional convenience bridge:

- It writes wrapped JSON dependency files for local development, demos, and file-based orchestration.
- It is not the sweet path.
- The recommended sweet path is direct dependency maps from Terraform outputs, Terragrunt dependency blocks, `terraform_remote_state`, HCP Terraform workspace outputs, CI/CD variables, or an orchestration layer.

Current pattern:

- Producer module may write JSON files when `output_path` is set.
- Consumer wrapper/example may expose `*_dependency_file_path`.
- Consumer wrapper/example decodes JSON and passes maps to the reusable module.
- Consumer wrapper/example should fail if both inline map and file path are set for the same dependency.

## Public Interface Rules

When adding or changing inputs:

- Prefer explicit object/map shapes over stringly typed overloads.
- Avoid `any` unless Terraform cannot model the accepted wrapped/direct shape cleanly.
- If `any` is used, add validations that reject unsupported transport forms and invalid resource names.
- Keep resource keys stable and meaningful. Outputs must use the same keys as inputs.
- Defaults should reduce boilerplate without hiding important infrastructure decisions.
- If a field is intentionally not exposed, document why in `README.md` or `SPEC.md`.

## Current Module Structure Decisions

For both `modules/exadb` and `modules/adb`:

- Keep dependency normalization in `dependencies.tf`.
- Keep `local_file` JSON handoff resources in `dependency_outputs.tf`.
- Keep cross-variable validations in `validations.tf` where appropriate.
- Keep generated example artifacts out of source control:
  - `tfplan`
  - `output/*.json`
  - `dependencies/*.json`

For `modules/odb-networking`:

- Keep ODB Network/Subnet creation there, not in ExaDB or ADB.
- Its outputs are the dependency maps consumed by ExaDB and ADB.
- Keep the same `output_path` wrapped JSON handoff pattern for local/wrapper use.

## Documentation Rules

For module docs and examples:

- Lead with the usable module experience, not background exposition.
- Clearly mark the sweet path as dependency maps from outputs/orchestration.
- Clearly mark JSON file handoff as optional/local/wrapper-level.
- Keep examples realistic but not overloaded.
- Do not document unsupported provider fields as module capabilities.
- Keep `README.md` operational and `SPEC.md` contract-focused.
- When a behavior is a v1 scope decision, say so explicitly.

## ExaDB Current Contract

Important `modules/exadb` decisions already implemented:

- ODB Network-only for VM Cluster.
- Does not create ODB Network/Subnet resources; those belong to `modules/odb-networking`.
- Dependencies:
  - `gcp_odb_networks_dependency`
  - `gcp_odb_subnets_dependency`
  - `gcp_cloud_exadata_infrastructures_dependency`
- These accept direct maps or wrapped maps, not JSON paths.
- `examples/cluster` owns file-path consumption through:
  - `gcp_odb_networks_dependency_file_path`
  - `gcp_odb_subnets_dependency_file_path`
  - `gcp_cloud_exadata_infrastructures_dependency_file_path`
- `output_path` still writes Cloud Exadata Infrastructure and Cloud VM Cluster dependency JSON files.
- `display_name` defaults to resource IDs for Cloud Exadata Infrastructure and Cloud VM Cluster.
- `module_name` is validated for Google label compatibility.
- `ssh_public_keys_file_path` supports one RSA OpenSSH public key per non-empty line.

## ADB Current Contract

Important `modules/adb` decisions already implemented:

- ODB Network-only for Autonomous Database.
- Public `network` and `cidr` have been removed from the module input contract.
- Dependencies:
  - `gcp_odb_networks_dependency`
  - `gcp_odb_subnets_dependency`
- These accept direct maps or wrapped maps, not JSON paths.
- `examples/existing-odb-network` owns file-path consumption through:
  - `gcp_odb_networks_dependency_file_path`
  - `gcp_odb_subnets_dependency_file_path`
- `output_path` still writes `gcp_autonomous_databases_output.json`.
- `display_name` defaults to `autonomous_database_id`.
- `module_name` is validated and the generated module label is sanitized like ExaDB.
- Admin passwords remain separate in `gcp_autonomous_databases_admin_passwords` and should not be put in committed tfvars.

## Definition of Done

A change is not complete until:

- The code matches the module philosophy and guardrails above.
- Relevant docs and examples are updated in the same change.
- Generated files are not introduced.
- `terraform fmt -check -recursive modules` passes.
- The touched module passes `terraform validate -no-color`.
- The touched module passes `terraform test -no-color` when local ignored tests are present. If a fresh clone does not include `.tftest.hcl` files, do not recreate and stage tests just to satisfy this check.
- Relevant examples pass `terraform init -backend=false` and `terraform validate -no-color`.
- Any wrapper-level JSON handoff path has at least one positive check and one conflict/failure check when practical.
- `git diff --check` passes.
- The final response states exactly what was verified and any residual risk.

## Validation Commands

Use these commands after relevant changes:

```sh
terraform fmt -check -recursive modules
terraform validate -no-color
terraform test -no-color
```

Run module-specific validation from the module directory:

```sh
cd modules/odb-networking
terraform validate -no-color
terraform test -no-color
```

```sh
cd modules/exadb
terraform validate -no-color
terraform test -no-color
```

```sh
cd modules/adb
terraform validate -no-color
terraform test -no-color
```

Examples require initialization before validation:

```sh
cd modules/odb-networking/examples/basic
terraform init -backend=false
terraform validate -no-color
```

```sh
cd modules/exadb/examples/cluster
terraform init -backend=false
terraform validate -no-color
```

```sh
cd modules/adb/examples/vision
terraform init -backend=false
terraform validate -no-color
```

```sh
cd modules/adb/examples/existing-odb-network
terraform init -backend=false
terraform validate -no-color
```

Also use `git diff --check` before final responses.

## Current Test Coverage Expectations

Contract tests and their fixtures are local-only and intentionally ignored by Git. Keep them under each module's `tests/` directory when they are present, run them with `terraform test -no-color`, and do not add `.tftest.hcl` or test-only fixture files to the repository:

- `modules/odb-networking/tests/odb_networking_validations.tftest.hcl`
- `modules/exadb/tests/exadb_validations.tftest.hcl`
- `modules/adb/tests/adb_validations.tftest.hcl`

Expected coverage includes:

- invalid `module_name` rejected;
- direct dependency maps accepted;
- wrapped dependency maps accepted;
- JSON paths rejected by reusable module inputs;
- example wrappers decode JSON paths;
- purpose validation rejects backup subnet where a client subnet is required;
- dependency output JSON is wrapped under the expected top-level key when `output_path` is set;
- default display names behave as documented.

## Documentation Tone

Docs should clearly distinguish:

- recommended production/sweet path: dependency maps from outputs/orchestration;
- optional convenience bridge: `output_path` JSON files;
- reusable module contract: maps only;
- wrapper/example responsibility: JSON file decoding;
- out-of-contract legacy behavior: VPC/CIDR.

Keep docs concise and operational. Avoid making the modules look like marketing pages.
