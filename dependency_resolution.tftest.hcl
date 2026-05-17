mock_provider "google" {}

run "local_odb_subnet_key_accepts_matching_network" {
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
    }
  }

  assert {
    condition     = google_oracle_database_odb_subnet.these["client"].odbnetwork == "primary-odb-network"
    error_message = "ODB subnet keys should resolve to the selected ODB network ID segment."
  }
}

run "local_odb_subnet_key_rejects_network_location_mismatch" {
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
        location       = "us-east4"
      }
    }

    gcp_odb_subnets_configuration = {
      client = {
        odb_subnet_id   = "client-subnet"
        cidr_range      = "192.168.1.0/24"
        purpose         = "CLIENT_SUBNET"
        odb_network_key = "primary"
        location        = "europe-west2"
      }
    }
  }

  expect_failures = [
    google_oracle_database_odb_subnet.these["client"],
  ]
}

run "local_odb_subnet_key_rejects_network_project_mismatch" {
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
        project_id     = "project-a"
      }
    }

    gcp_odb_subnets_configuration = {
      client = {
        odb_subnet_id   = "client-subnet"
        cidr_range      = "192.168.1.0/24"
        purpose         = "CLIENT_SUBNET"
        odb_network_key = "primary"
        project_id      = "project-b"
      }
    }
  }

  expect_failures = [
    google_oracle_database_odb_subnet.these["client"],
  ]
}

run "dependency_odb_subnet_rejects_parent_alias_that_contradicts_id" {
  command = plan

  variables {
    gcp_odb_subnets_dependency = {
      client = {
        id         = "projects/project-a/locations/us-east4/odbNetworks/primary-odb-network/odbSubnets/client-subnet"
        purpose    = "CLIENT_SUBNET"
        odbnetwork = "other-odb-network"
      }
    }
  }

  expect_failures = [
    var.gcp_odb_subnets_dependency,
  ]
}

run "dependency_odb_subnet_parent_is_derived_from_id" {
  command = plan

  variables {
    default_project_id          = "project-a"
    default_location            = "us-east4"
    default_deletion_protection = false

    gcp_odb_networks_dependency = {
      primary = {
        id = "projects/project-a/locations/us-east4/odbNetworks/primary-odb-network"
      }
    }

    gcp_odb_subnets_dependency = {
      client = {
        id      = "projects/project-a/locations/us-east4/odbNetworks/other-odb-network/odbSubnets/client-subnet"
        purpose = "CLIENT_SUBNET"
      }
      backup = {
        id      = "projects/project-a/locations/us-east4/odbNetworks/primary-odb-network/odbSubnets/backup-subnet"
        purpose = "BACKUP_SUBNET"
      }
    }

    gcp_cloud_exadata_infrastructures_dependency = {
      primary = {
        id = "projects/project-a/locations/us-east4/cloudExadataInfrastructures/primary-exadata"
      }
    }

    gcp_cloud_vm_clusters_configuration = {
      primary = {
        cloud_vm_cluster_id        = "primary-vm-cluster"
        exadata_infrastructure_key = "primary"
        odb_network_key            = "primary"
        odb_subnet_key             = "client"
        backup_odb_subnet_key      = "backup"

        properties = {
          license_type    = "BRING_YOUR_OWN_LICENSE"
          cpu_core_count  = 4
          node_count      = 2
          ssh_public_keys = ["ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCexample user@example.com"]
        }
      }
    }
  }

  expect_failures = [
    google_oracle_database_cloud_vm_cluster.these["primary"],
  ]
}

run "vm_cluster_rejects_direct_subnet_parent_with_same_network_segment_but_different_project_location" {
  command = plan

  variables {
    default_project_id          = "project-a"
    default_location            = "us-east4"
    default_deletion_protection = false

    gcp_cloud_vm_clusters_configuration = {
      primary = {
        cloud_vm_cluster_id    = "primary-vm-cluster"
        exadata_infrastructure = "projects/project-a/locations/us-east4/cloudExadataInfrastructures/primary-exadata"
        odb_network            = "projects/project-a/locations/us-east4/odbNetworks/shared"
        odb_subnet             = "projects/project-b/locations/europe-west2/odbNetworks/shared/odbSubnets/client-subnet"
        backup_odb_subnet      = "projects/project-b/locations/europe-west2/odbNetworks/shared/odbSubnets/backup-subnet"

        properties = {
          license_type    = "BRING_YOUR_OWN_LICENSE"
          cpu_core_count  = 4
          node_count      = 2
          ssh_public_keys = ["ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCexample user@example.com"]
        }
      }
    }
  }

  expect_failures = [
    google_oracle_database_cloud_vm_cluster.these["primary"],
  ]
}

run "vm_cluster_rejects_dependency_subnet_parent_with_same_network_segment_but_different_project_location" {
  command = plan

  variables {
    default_project_id          = "project-a"
    default_location            = "us-east4"
    default_deletion_protection = false

    gcp_odb_networks_dependency = {
      primary = {
        id = "projects/project-a/locations/us-east4/odbNetworks/shared"
      }
    }

    gcp_odb_subnets_dependency = {
      client = {
        id      = "projects/project-b/locations/europe-west2/odbNetworks/shared/odbSubnets/client-subnet"
        purpose = "CLIENT_SUBNET"
      }
      backup = {
        id      = "projects/project-b/locations/europe-west2/odbNetworks/shared/odbSubnets/backup-subnet"
        purpose = "BACKUP_SUBNET"
      }
    }

    gcp_cloud_exadata_infrastructures_dependency = {
      primary = {
        id = "projects/project-a/locations/us-east4/cloudExadataInfrastructures/primary-exadata"
      }
    }

    gcp_cloud_vm_clusters_configuration = {
      primary = {
        cloud_vm_cluster_id        = "primary-vm-cluster"
        exadata_infrastructure_key = "primary"
        odb_network_key            = "primary"
        odb_subnet_key             = "client"
        backup_odb_subnet_key      = "backup"

        properties = {
          license_type    = "BRING_YOUR_OWN_LICENSE"
          cpu_core_count  = 4
          node_count      = 2
          ssh_public_keys = ["ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCexample user@example.com"]
        }
      }
    }
  }

  expect_failures = [
    google_oracle_database_cloud_vm_cluster.these["primary"],
  ]
}

run "dependency_json_files_drive_vm_cluster_handoff" {
  command = plan

  variables {
    default_project_id          = "my-gcp-project"
    default_location            = "europe-west2"
    default_deletion_protection = false

    gcp_odb_networks_dependency                  = "examples/external_dependency/dependencies/gcp_odb_networks_output.json"
    gcp_odb_subnets_dependency                   = "examples/external_dependency/dependencies/gcp_odb_subnets_output.json"
    gcp_cloud_exadata_infrastructures_dependency = "examples/external_dependency/dependencies/gcp_cloud_exadata_infrastructures_output.json"

    gcp_cloud_vm_clusters_configuration = {
      primary = {
        cloud_vm_cluster_id        = "handoff-vm-cluster"
        exadata_infrastructure_key = "primary"
        odb_network_key            = "primary"
        odb_subnet_key             = "client"
        backup_odb_subnet_key      = "backup"

        properties = {
          license_type         = "BRING_YOUR_OWN_LICENSE"
          cpu_core_count       = 4
          node_count           = 2
          ssh_public_keys      = ["ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCexample user@example.com"]
          db_server_ocids      = ["ocid1.dbserver.oc1.uk-london-1.example1", "ocid1.dbserver.oc1.uk-london-1.example2"]
          cluster_name         = "handoff"
          hostname_prefix      = "exa"
          gi_version           = "23.0.0.0"
          data_storage_size_tb = 2
        }
      }
    }
  }

  assert {
    condition     = google_oracle_database_cloud_vm_cluster.these["primary"].odb_network == "projects/my-gcp-project/locations/europe-west2/odbNetworks/my-odb-network"
    error_message = "VM clusters should resolve ODB network keys from dependency JSON files."
  }

  assert {
    condition     = google_oracle_database_cloud_vm_cluster.these["primary"].odb_subnet == "projects/my-gcp-project/locations/europe-west2/odbNetworks/my-odb-network/odbSubnets/my-client-subnet"
    error_message = "VM clusters should resolve client subnet keys from dependency JSON files."
  }
}

run "output_path_plans_dependency_json_files" {
  command = plan

  variables {
    default_project_id          = "project-a"
    default_location            = "us-east4"
    default_gcp_oracle_zone     = "us-east4-a-r2"
    default_deletion_protection = false
    output_path                 = "./output"

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

  assert {
    condition     = local_file.gcp_odb_networks_output[0].filename == "./output/gcp_odb_networks_output.json"
    error_message = "output_path should plan an ODB networks dependency JSON file."
  }

  assert {
    condition     = local_file.gcp_odb_subnets_output[0].filename == "./output/gcp_odb_subnets_output.json"
    error_message = "output_path should plan an ODB subnets dependency JSON file."
  }
}
