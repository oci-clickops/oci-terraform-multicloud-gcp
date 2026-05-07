mock_provider "google" {}

run "full_stack_with_keys" {
  command = plan

  variables {
    default_project_id          = "project-a"
    default_location            = "us-east4"
    default_gcp_oracle_zone     = "us-east4-a-r2"
    default_deletion_protection = false

    gcp_odb_networks_configuration = {
      primary = {
        odb_network_id = "primary-odb-network"
        network        = "projects/project-a/global/networks/database-vpc"
      }
    }
    gcp_odb_subnets_configuration = {
      client = {
        odb_subnet_id   = "client-subnet"
        cidr_range      = "192.168.1.0/24"
        purpose         = "CLIENT_SUBNET"
        odb_network_key = "primary"
      }
      backup = {
        odb_subnet_id   = "backup-subnet"
        cidr_range      = "192.168.2.0/28"
        purpose         = "BACKUP_SUBNET"
        odb_network_key = "primary"
      }
    }
    gcp_cloud_exadata_infrastructures_configuration = {
      primary = {
        cloud_exadata_infrastructure_id = "primary-exa"
        properties = {
          shape = "Exadata.X11M"
        }
      }
    }
    gcp_cloud_vm_clusters_configuration = {
      primary = {
        cloud_vm_cluster_id        = "primary-vmc"
        exadata_infrastructure_key = "primary"
        odb_network_key            = "primary"
        odb_subnet_key             = "client"
        backup_odb_subnet_key      = "backup"
        properties = {
          license_type   = "BRING_YOUR_OWN_LICENSE"
          cpu_core_count = 4
        }
      }
    }
  }
}

run "network_only_deployment" {
  command = plan

  variables {
    default_project_id          = "project-a"
    default_location            = "us-east4"
    default_gcp_oracle_zone     = "us-east4-a-r2"
    default_deletion_protection = false

    gcp_odb_networks_configuration = {
      primary = {
        odb_network_id = "primary-odb-network"
        network        = "projects/project-a/global/networks/database-vpc"
      }
    }
    gcp_odb_subnets_configuration = {
      client = {
        odb_subnet_id   = "client-subnet"
        cidr_range      = "192.168.1.0/24"
        purpose         = "CLIENT_SUBNET"
        odb_network_key = "primary"
      }
      backup = {
        odb_subnet_id   = "backup-subnet"
        cidr_range      = "192.168.2.0/28"
        purpose         = "BACKUP_SUBNET"
        odb_network_key = "primary"
      }
    }
  }
}

run "all_literal_references" {
  command = plan

  variables {
    default_project_id          = "project-a"
    default_location            = "us-east4"
    default_gcp_oracle_zone     = "us-east4-a-r2"
    default_deletion_protection = false

    gcp_cloud_vm_clusters_configuration = {
      primary = {
        cloud_vm_cluster_id    = "primary-vmc"
        exadata_infrastructure = "projects/project-a/locations/us-east4/cloudExadataInfrastructures/primary-exa"
        odb_network            = "projects/project-a/locations/us-east4/odbNetworks/primary"
        odb_subnet             = "projects/project-a/locations/us-east4/odbNetworks/primary/odbSubnets/client"
        backup_odb_subnet      = "projects/project-a/locations/us-east4/odbNetworks/primary/odbSubnets/backup"
        properties = {
          license_type   = "LICENSE_INCLUDED"
          cpu_core_count = 4
        }
      }
    }
  }
}

run "existing_subnets_new_cluster" {
  command = plan

  variables {
    default_project_id          = "project-a"
    default_location            = "us-east4"
    default_gcp_oracle_zone     = "us-east4-a-r2"
    default_deletion_protection = false

    gcp_cloud_exadata_infrastructures_configuration = {
      primary = {
        cloud_exadata_infrastructure_id = "primary-exa"
        properties                      = { shape = "Exadata.X11M" }
      }
    }

    gcp_cloud_vm_clusters_configuration = {
      primary = {
        cloud_vm_cluster_id        = "primary-vmc"
        exadata_infrastructure_key = "primary"
        odb_network                = "projects/project-a/locations/us-east4/odbNetworks/existing"
        odb_subnet                 = "projects/project-a/locations/us-east4/odbNetworks/existing/odbSubnets/client"
        backup_odb_subnet          = "projects/project-a/locations/us-east4/odbNetworks/existing/odbSubnets/backup"
        properties = {
          license_type   = "BRING_YOUR_OWN_LICENSE"
          cpu_core_count = 4
        }
      }
    }
  }
}

run "state_handoff_via_json" {
  command = plan

  variables {
    default_project_id          = "my-gcp-project"
    default_location            = "europe-west2"
    default_deletion_protection = false

    gcp_odb_networks_dependency                  = "examples/state-handoff-vm-cluster/dependencies/gcp_odb_networks_output.json"
    gcp_odb_subnets_dependency                   = "examples/state-handoff-vm-cluster/dependencies/gcp_odb_subnets_output.json"
    gcp_cloud_exadata_infrastructures_dependency = "examples/state-handoff-vm-cluster/dependencies/gcp_cloud_exadata_infrastructures_output.json"

    gcp_cloud_vm_clusters_configuration = {
      primary = {
        cloud_vm_cluster_id        = "handoff-vmc"
        exadata_infrastructure_key = "primary"
        odb_network_key            = "primary"
        odb_subnet_key             = "client"
        backup_odb_subnet_key      = "backup"
        properties = {
          license_type    = "BRING_YOUR_OWN_LICENSE"
          cpu_core_count  = 4
          node_count      = 2
          db_server_ocids = ["ocid1.dbserver.oc1.uk-london-1.aaa", "ocid1.dbserver.oc1.uk-london-1.bbb"]
        }
      }
    }
  }
}

run "ocids_without_nodecount_too_few_fails" {
  command = plan

  variables {
    default_project_id          = "project-a"
    default_location            = "us-east4"
    default_gcp_oracle_zone     = "us-east4-a-r2"
    default_deletion_protection = false

    gcp_cloud_vm_clusters_configuration = {
      primary = {
        cloud_vm_cluster_id    = "primary-vmc"
        exadata_infrastructure = "projects/project-a/locations/us-east4/cloudExadataInfrastructures/exa"
        odb_network            = "projects/project-a/locations/us-east4/odbNetworks/net"
        odb_subnet             = "projects/project-a/locations/us-east4/odbNetworks/net/odbSubnets/client"
        backup_odb_subnet      = "projects/project-a/locations/us-east4/odbNetworks/net/odbSubnets/backup"
        properties = {
          license_type    = "LICENSE_INCLUDED"
          cpu_core_count  = 4
          db_server_ocids = ["ocid1.dbserver.oc1.us-east4.only"]
        }
      }
    }
  }

  expect_failures = [google_oracle_database_cloud_vm_cluster.these["primary"]]
}

run "ocids_without_nodecount_minimum_met" {
  command = plan

  variables {
    default_project_id          = "project-a"
    default_location            = "us-east4"
    default_gcp_oracle_zone     = "us-east4-a-r2"
    default_deletion_protection = false

    gcp_cloud_vm_clusters_configuration = {
      primary = {
        cloud_vm_cluster_id    = "primary-vmc"
        exadata_infrastructure = "projects/project-a/locations/us-east4/cloudExadataInfrastructures/exa"
        odb_network            = "projects/project-a/locations/us-east4/odbNetworks/net"
        odb_subnet             = "projects/project-a/locations/us-east4/odbNetworks/net/odbSubnets/client"
        backup_odb_subnet      = "projects/project-a/locations/us-east4/odbNetworks/net/odbSubnets/backup"
        properties = {
          license_type    = "LICENSE_INCLUDED"
          cpu_core_count  = 4
          db_server_ocids = ["ocid1.dbserver.oc1.us-east4.a", "ocid1.dbserver.oc1.us-east4.b"]
        }
      }
    }
  }
}

run "ocids_below_explicit_nodecount_fails" {
  command = plan

  variables {
    default_project_id          = "project-a"
    default_location            = "us-east4"
    default_gcp_oracle_zone     = "us-east4-a-r2"
    default_deletion_protection = false

    gcp_cloud_vm_clusters_configuration = {
      primary = {
        cloud_vm_cluster_id    = "primary-vmc"
        exadata_infrastructure = "projects/project-a/locations/us-east4/cloudExadataInfrastructures/exa"
        odb_network            = "projects/project-a/locations/us-east4/odbNetworks/net"
        odb_subnet             = "projects/project-a/locations/us-east4/odbNetworks/net/odbSubnets/client"
        backup_odb_subnet      = "projects/project-a/locations/us-east4/odbNetworks/net/odbSubnets/backup"
        properties = {
          license_type    = "LICENSE_INCLUDED"
          cpu_core_count  = 4
          node_count      = 4
          db_server_ocids = ["ocid1.dbserver.oc1.us-east4.a", "ocid1.dbserver.oc1.us-east4.b"]
        }
      }
    }
  }

  expect_failures = [google_oracle_database_cloud_vm_cluster.these["primary"]]
}

run "empty_string_odb_network_rejected" {
  command = plan

  variables {
    gcp_cloud_vm_clusters_configuration = {
      primary = {
        cloud_vm_cluster_id    = "primary-vmc"
        exadata_infrastructure = "projects/project-a/locations/us-east4/cloudExadataInfrastructures/exa"
        odb_network            = ""
        odb_subnet             = "projects/project-a/locations/us-east4/odbNetworks/net/odbSubnets/client"
        backup_odb_subnet      = "projects/project-a/locations/us-east4/odbNetworks/net/odbSubnets/backup"
        properties = {
          license_type   = "LICENSE_INCLUDED"
          cpu_core_count = 4
        }
      }
    }
  }

  expect_failures = [var.gcp_cloud_vm_clusters_configuration]
}

run "empty_string_subnet_key_rejected" {
  command = plan

  variables {
    gcp_odb_subnets_configuration = {
      client = {
        odb_subnet_id   = "client-subnet"
        cidr_range      = "192.168.1.0/24"
        purpose         = "CLIENT_SUBNET"
        odb_network_key = ""
      }
    }
  }

  expect_failures = [var.gcp_odb_subnets_configuration]
}

run "module_subnet_network_segment_mismatch_at_plan" {
  command = plan

  variables {
    default_project_id          = "project-a"
    default_location            = "us-east4"
    default_gcp_oracle_zone     = "us-east4-a-r2"
    default_deletion_protection = false

    gcp_odb_networks_configuration = {
      net_a = { odb_network_id = "net-a", network = "projects/project-a/global/networks/vpc" }
      net_b = { odb_network_id = "net-b", network = "projects/project-a/global/networks/vpc" }
    }
    gcp_odb_subnets_configuration = {
      client = {
        odb_subnet_id   = "client-subnet"
        cidr_range      = "192.168.1.0/24"
        purpose         = "CLIENT_SUBNET"
        odb_network_key = "net_a"
      }
      backup = {
        odb_subnet_id   = "backup-subnet"
        cidr_range      = "192.168.2.0/28"
        purpose         = "BACKUP_SUBNET"
        odb_network_key = "net_a"
      }
    }
    gcp_cloud_vm_clusters_configuration = {
      primary = {
        cloud_vm_cluster_id    = "primary-vmc"
        exadata_infrastructure = "projects/project-a/locations/us-east4/cloudExadataInfrastructures/exa"
        odb_network_key        = "net_b"
        odb_subnet_key         = "client"
        backup_odb_subnet_key  = "backup"
        properties = {
          license_type   = "LICENSE_INCLUDED"
          cpu_core_count = 4
        }
      }
    }
  }

  expect_failures = [google_oracle_database_cloud_vm_cluster.these["primary"]]
}

run "maintenance_window_shallow_merge" {
  command = plan

  variables {
    default_project_id          = "project-a"
    default_location            = "us-east4"
    default_gcp_oracle_zone     = "us-east4-a-r2"
    default_deletion_protection = false

    default_cloud_exadata_maintenance_window = {
      preference     = "CUSTOM_PREFERENCE"
      lead_time_week = 2
      patching_mode  = "ROLLING"
      hours_of_day   = [4, 12]
    }

    gcp_cloud_exadata_infrastructures_configuration = {
      primary = {
        cloud_exadata_infrastructure_id = "primary-exa"
        properties = {
          shape = "Exadata.X11M"
          maintenance_window = {
            preference = "NO_PREFERENCE"
          }
        }
      }
    }
  }

  assert {
    condition     = google_oracle_database_cloud_exadata_infrastructure.these["primary"].properties[0].maintenance_window[0].preference == "NO_PREFERENCE"
    error_message = "Per-resource preference must override the default."
  }
  assert {
    condition     = google_oracle_database_cloud_exadata_infrastructure.these["primary"].properties[0].maintenance_window[0].lead_time_week == 2
    error_message = "Default lead_time_week must survive when not overridden."
  }
  assert {
    condition     = google_oracle_database_cloud_exadata_infrastructure.these["primary"].properties[0].maintenance_window[0].patching_mode == "ROLLING"
    error_message = "Default patching_mode must survive when not overridden."
  }
  assert {
    condition     = length(google_oracle_database_cloud_exadata_infrastructure.these["primary"].properties[0].maintenance_window[0].hours_of_day) == 2
    error_message = "Default hours_of_day list must survive when not overridden."
  }
}

run "maintenance_window_default_only" {
  command = plan

  variables {
    default_project_id          = "project-a"
    default_location            = "us-east4"
    default_gcp_oracle_zone     = "us-east4-a-r2"
    default_deletion_protection = false

    default_cloud_exadata_maintenance_window = {
      preference = "NO_PREFERENCE"
    }

    gcp_cloud_exadata_infrastructures_configuration = {
      primary = {
        cloud_exadata_infrastructure_id = "primary-exa"
        properties                      = { shape = "Exadata.X11M" }
      }
    }
  }

  assert {
    condition     = google_oracle_database_cloud_exadata_infrastructure.these["primary"].properties[0].maintenance_window[0].preference == "NO_PREFERENCE"
    error_message = "Default preference must apply when no override is provided."
  }
}

run "maintenance_window_none_emits_no_block" {
  command = plan

  variables {
    default_project_id          = "project-a"
    default_location            = "us-east4"
    default_gcp_oracle_zone     = "us-east4-a-r2"
    default_deletion_protection = false

    gcp_cloud_exadata_infrastructures_configuration = {
      primary = {
        cloud_exadata_infrastructure_id = "primary-exa"
        properties                      = { shape = "Exadata.X11M" }
      }
    }
  }

  assert {
    condition     = length(google_oracle_database_cloud_exadata_infrastructure.these["primary"].properties[0].maintenance_window) == 0
    error_message = "No maintenance_window block must be emitted when neither default nor override is provided."
  }
}

run "non_rsa_ssh_rejected" {
  command = plan

  variables {
    gcp_cloud_vm_clusters_configuration = {
      primary = {
        cloud_vm_cluster_id    = "primary-vmc"
        exadata_infrastructure = "projects/project-a/locations/us-east4/cloudExadataInfrastructures/exa"
        odb_network            = "projects/project-a/locations/us-east4/odbNetworks/net"
        odb_subnet             = "projects/project-a/locations/us-east4/odbNetworks/net/odbSubnets/client"
        backup_odb_subnet      = "projects/project-a/locations/us-east4/odbNetworks/net/odbSubnets/backup"
        properties = {
          license_type    = "LICENSE_INCLUDED"
          cpu_core_count  = 4
          ssh_public_keys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAITESTKEY user@host"]
        }
      }
    }
  }

  expect_failures = [var.gcp_cloud_vm_clusters_configuration]
}

run "backup_subnet_with_client_purpose_fails" {
  command = plan

  variables {
    default_project_id          = "project-a"
    default_location            = "us-east4"
    default_gcp_oracle_zone     = "us-east4-a-r2"
    default_deletion_protection = false

    gcp_odb_networks_configuration = {
      net = { odb_network_id = "net", network = "projects/project-a/global/networks/vpc" }
    }
    gcp_odb_subnets_configuration = {
      client_a = {
        odb_subnet_id   = "client-a"
        cidr_range      = "192.168.1.0/24"
        purpose         = "CLIENT_SUBNET"
        odb_network_key = "net"
      }
      client_b = {
        odb_subnet_id   = "client-b"
        cidr_range      = "192.168.2.0/24"
        purpose         = "CLIENT_SUBNET"
        odb_network_key = "net"
      }
    }
    gcp_cloud_vm_clusters_configuration = {
      primary = {
        cloud_vm_cluster_id    = "primary-vmc"
        exadata_infrastructure = "projects/project-a/locations/us-east4/cloudExadataInfrastructures/exa"
        odb_network_key        = "net"
        odb_subnet_key         = "client_a"
        backup_odb_subnet_key  = "client_b"
        properties = {
          license_type   = "LICENSE_INCLUDED"
          cpu_core_count = 4
        }
      }
    }
  }

  expect_failures = [google_oracle_database_cloud_vm_cluster.these["primary"]]
}

run "output_path_emits_vm_cluster_json" {
  command = plan

  variables {
    default_project_id          = "project-a"
    default_location            = "us-east4"
    default_gcp_oracle_zone     = "us-east4-a-r2"
    default_deletion_protection = false
    output_path                 = "./out"

    gcp_cloud_vm_clusters_configuration = {
      primary = {
        cloud_vm_cluster_id    = "primary-vmc"
        exadata_infrastructure = "projects/project-a/locations/us-east4/cloudExadataInfrastructures/exa"
        odb_network            = "projects/project-a/locations/us-east4/odbNetworks/net"
        odb_subnet             = "projects/project-a/locations/us-east4/odbNetworks/net/odbSubnets/client"
        backup_odb_subnet      = "projects/project-a/locations/us-east4/odbNetworks/net/odbSubnets/backup"
        properties = {
          license_type   = "BRING_YOUR_OWN_LICENSE"
          cpu_core_count = 4
        }
      }
    }
  }

  assert {
    condition     = local_file.gcp_cloud_vm_clusters_output[0].filename == "./out/gcp_cloud_vm_clusters_output.json"
    error_message = "VM cluster dependency JSON file must be planned when output_path is set."
  }
}

run "multiple_clusters_one_network" {
  command = plan

  variables {
    default_project_id          = "project-a"
    default_location            = "us-east4"
    default_gcp_oracle_zone     = "us-east4-a-r2"
    default_deletion_protection = false

    gcp_odb_networks_configuration = {
      shared = { odb_network_id = "shared-net", network = "projects/project-a/global/networks/vpc" }
    }
    gcp_odb_subnets_configuration = {
      client = {
        odb_subnet_id   = "client-sub"
        cidr_range      = "192.168.1.0/24"
        purpose         = "CLIENT_SUBNET"
        odb_network_key = "shared"
      }
      backup = {
        odb_subnet_id   = "backup-sub"
        cidr_range      = "192.168.2.0/28"
        purpose         = "BACKUP_SUBNET"
        odb_network_key = "shared"
      }
    }
    gcp_cloud_exadata_infrastructures_configuration = {
      exa1 = { cloud_exadata_infrastructure_id = "exa-1", properties = { shape = "Exadata.X11M" } }
      exa2 = { cloud_exadata_infrastructure_id = "exa-2", properties = { shape = "Exadata.X11M" } }
    }
    gcp_cloud_vm_clusters_configuration = {
      vmc1 = {
        cloud_vm_cluster_id        = "vmc-1"
        exadata_infrastructure_key = "exa1"
        odb_network_key            = "shared"
        odb_subnet_key             = "client"
        backup_odb_subnet_key      = "backup"
        properties                 = { license_type = "LICENSE_INCLUDED", cpu_core_count = 4 }
      }
      vmc2 = {
        cloud_vm_cluster_id        = "vmc-2"
        exadata_infrastructure_key = "exa2"
        odb_network_key            = "shared"
        odb_subnet_key             = "client"
        backup_odb_subnet_key      = "backup"
        properties                 = { license_type = "BRING_YOUR_OWN_LICENSE", cpu_core_count = 8 }
      }
    }
  }
}

run "subnet_project_mismatch_with_local_network_fails" {
  command = plan

  variables {
    default_project_id          = "project-a"
    default_location            = "us-east4"
    default_gcp_oracle_zone     = "us-east4-a-r2"
    default_deletion_protection = false

    gcp_odb_networks_configuration = {
      primary = {
        odb_network_id = "primary"
        network        = "projects/project-a/global/networks/vpc"
        project_id     = "project-a"
      }
    }
    gcp_odb_subnets_configuration = {
      client = {
        odb_subnet_id   = "client-sub"
        cidr_range      = "192.168.1.0/24"
        purpose         = "CLIENT_SUBNET"
        odb_network_key = "primary"
        project_id      = "project-b"
      }
    }
  }

  expect_failures = [google_oracle_database_odb_subnet.these["client"]]
}

run "disabled_outputs_no_local_files" {
  command = plan

  variables {
    default_project_id          = "project-a"
    default_location            = "us-east4"
    default_gcp_oracle_zone     = "us-east4-a-r2"
    default_deletion_protection = false
    enable_output               = false
    output_path                 = "./out"

    gcp_odb_networks_configuration = {
      primary = { odb_network_id = "primary", network = "projects/project-a/global/networks/vpc" }
    }
  }

  assert {
    condition     = length(local_file.gcp_odb_networks_output) == 0
    error_message = "When enable_output is false no local_file resources are created."
  }
  assert {
    condition     = length(local_file.gcp_cloud_vm_clusters_output) == 0
    error_message = "When enable_output is false no VM cluster local_file resource is created."
  }
}
