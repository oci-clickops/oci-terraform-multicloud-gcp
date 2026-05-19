# OCI DB Home Handoff Example

This wrapper shows the Day-2 handoff from Oracle Database@Google Cloud to the
OCI Exadata Database module.

The GCP VM Cluster stack produces `gcp_cloud_vm_clusters_output.json`. This
example reads that file, extracts the OCI VM Cluster OCID from
`gcp_cloud_vm_clusters.<key>.ocid`, and passes it to the OCI module as
`cloud_db_homes_configuration.<dbhome>.vm_cluster_id`.

The reusable GCP module does not call the OCI provider. The JSON file read is
kept in this wrapper so the module stays backend-agnostic.

## Flow

1. Deploy the GCP VM Cluster stack, for example `../cluster`, with
   `output_path = "./output"`.
2. Wait until the VM Cluster output has `state = "AVAILABLE"` and `ocid` is not
   null.
3. Rename `input.auto.tfvars.template` to `<name>.auto.tfvars`.
4. Set OCI authentication values, the OCI region, and DB/CDB/PDB settings.
5. Run the normal Terraform workflow from this directory.

Use the OCI region embedded in the VM Cluster OCID, not the Google Cloud region.
For example, if the OCID starts with `ocid1.cloudvmcluster.oc1.uk-london-1`,
set `region = "uk-london-1"`.

## Handoff Contract

The recommended file handoff is:

```hcl
gcp_cloud_vm_clusters_dependency_file_path = "../cluster/output/gcp_cloud_vm_clusters_output.json"
```

Then each DB Home can reference the VM Cluster by key:

```hcl
cloud_db_homes_configuration = {
  dbhome1 = {
    vm_cluster_key = "primary"
    display_name   = "dgc-dbhome1"
    db_version     = "19.0.0.0"
    source         = "VM_CLUSTER_NEW"
  }
}
```

The wrapper converts that to:

```hcl
vm_cluster_id = local.gcp_cloud_vm_clusters_dependency.primary.ocid
```

Direct OCID handoff is also supported:

```hcl
cloud_db_homes_configuration = {
  dbhome1 = {
    vm_cluster_id = "ocid1.cloudvmcluster.oc1.<region>.<id>"
    display_name  = "dgc-dbhome1"
    db_version    = "19.0.0.0"
    source        = "VM_CLUSTER_NEW"
  }
}
```

Do not use the Google resource name
`projects/<project>/locations/<region>/cloudVmClusters/<name>` as
`vm_cluster_id`; the OCI module requires the OCI OCID.

## Validation

The wrapper fails the plan when:

* both inline and file handoff inputs are set;
* a DB Home sets neither or both of `vm_cluster_id` and `vm_cluster_key`;
* a direct `vm_cluster_id` is not an OCI Cloud VM Cluster OCID;
* a `vm_cluster_key` does not exist in the GCP VM Cluster dependency map;
* the referenced dependency has no `ocid`;
* the referenced dependency has a non-`AVAILABLE` state.

## Source Pinning

This example references the upstream OCI Exadata module from GitHub:

```hcl
git::https://github.com/oci-landing-zones/terraform-oci-modules-exadata.git//exadata-database?ref=main
```

For production, pin `ref` to a release tag or commit SHA.
