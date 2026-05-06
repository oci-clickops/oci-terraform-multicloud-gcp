#!/bin/sh
set -eu

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

grep -q 'must belong to the ODB network selected by odb_network_key' gcp_vm_cluster.tf \
  || fail "VM clusters using odb_network_key must validate that ODB subnet keys belong to the selected ODB network"

grep -q 'gcp_oracle_zone = "us-east4-a-r2"' examples/quickstart/terraform.tfvars.example \
  || fail "quickstart must show a documented GCP Oracle zone format"
