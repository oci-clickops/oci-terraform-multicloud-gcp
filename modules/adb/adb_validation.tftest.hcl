# Copyright (c) 2026, Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

mock_provider "google" {
  mock_resource "google_oracle_database_autonomous_database" {
    defaults = {
      id       = "projects/test-project/locations/us-east4/autonomousDatabases/test-adb"
      name     = "projects/test-project/locations/us-east4/autonomousDatabases/test-adb"
      location = "us-east4"
      project  = "test-project"
    }
  }
}

run "valid_vpc_mode_configuration_passes" {
  command = plan

  variables {
    default_project_id = "test-project"
    default_location   = "us-east4"
    gcp_autonomous_databases_configuration = {
      primary = {
        autonomous_database_id = "test-adb"
        database               = "testdb"
        network                = "projects/test-project/global/networks/test-vpc"
        cidr                   = "10.5.0.0/24"
        properties = {
          db_workload  = "OLTP"
          license_type = "LICENSE_INCLUDED"
          compute_count        = 2
          data_storage_size_tb = 1
          db_version           = "23ai"
        }
      }
    }
  }

  assert {
    condition     = length(google_oracle_database_autonomous_database.these) == 1
    error_message = "Expected one ADB resource to be planned."
  }
}

run "invalid_autonomous_database_id_fails" {
  command = plan

  variables {
    default_project_id = "test-project"
    default_location   = "us-east4"
    gcp_autonomous_databases_configuration = {
      primary = {
        autonomous_database_id = "INVALID_ID"
        network                = "projects/test-project/global/networks/test-vpc"
        cidr                   = "10.5.0.0/24"
      }
    }
  }

  expect_failures = [var.gcp_autonomous_databases_configuration]
}

run "both_networking_modes_simultaneously_fails" {
  command = plan

  variables {
    default_project_id = "test-project"
    default_location   = "us-east4"
    gcp_autonomous_databases_configuration = {
      primary = {
        autonomous_database_id = "test-adb"
        network                = "projects/test-project/global/networks/test-vpc"
        cidr                   = "10.5.0.0/24"
        odb_network            = "projects/test-project/locations/us-east4/odbNetworks/test-network"
      }
    }
  }

  expect_failures = [var.gcp_autonomous_databases_configuration]
}

run "invalid_network_format_fails" {
  command = plan

  variables {
    default_project_id = "test-project"
    default_location   = "us-east4"
    gcp_autonomous_databases_configuration = {
      primary = {
        autonomous_database_id = "test-adb"
        network                = "not-a-valid-network-name"
        cidr                   = "10.5.0.0/24"
      }
    }
  }

  expect_failures = [var.gcp_autonomous_databases_configuration]
}

run "invalid_odb_network_format_fails" {
  command = plan

  variables {
    default_project_id = "test-project"
    default_location   = "us-east4"
    gcp_autonomous_databases_configuration = {
      primary = {
        autonomous_database_id = "test-adb"
        odb_network            = "not-a-valid-resource-name"
        odb_subnet             = "projects/test-project/locations/us-east4/odbNetworks/net/odbSubnets/sub"
      }
    }
  }

  expect_failures = [var.gcp_autonomous_databases_configuration]
}

run "invalid_db_workload_fails" {
  command = plan

  variables {
    default_project_id = "test-project"
    default_location   = "us-east4"
    gcp_autonomous_databases_configuration = {
      primary = {
        autonomous_database_id = "test-adb"
        network                = "projects/test-project/global/networks/test-vpc"
        cidr                   = "10.5.0.0/24"
        properties = {
          db_workload = "INVALID_WORKLOAD"
        }
      }
    }
  }

  expect_failures = [var.gcp_autonomous_databases_configuration]
}

run "invalid_license_type_fails" {
  command = plan

  variables {
    default_project_id = "test-project"
    default_location   = "us-east4"
    gcp_autonomous_databases_configuration = {
      primary = {
        autonomous_database_id = "test-adb"
        network                = "projects/test-project/global/networks/test-vpc"
        cidr                   = "10.5.0.0/24"
        properties = {
          license_type = "INVALID_LICENSE"
        }
      }
    }
  }

  expect_failures = [var.gcp_autonomous_databases_configuration]
}

run "backup_retention_period_out_of_range_fails" {
  command = plan

  variables {
    default_project_id = "test-project"
    default_location   = "us-east4"
    gcp_autonomous_databases_configuration = {
      primary = {
        autonomous_database_id = "test-adb"
        network                = "projects/test-project/global/networks/test-vpc"
        cidr                   = "10.5.0.0/24"
        properties = {
          backup_retention_period_days = 90
        }
      }
    }
  }

  expect_failures = [var.gcp_autonomous_databases_configuration]
}

run "invalid_customer_contact_email_fails" {
  command = plan

  variables {
    default_project_id = "test-project"
    default_location   = "us-east4"
    gcp_autonomous_databases_configuration = {
      primary = {
        autonomous_database_id = "test-adb"
        network                = "projects/test-project/global/networks/test-vpc"
        cidr                   = "10.5.0.0/24"
        properties = {
          customer_contacts = [{ email = "not-a-valid-email" }]
        }
      }
    }
  }

  expect_failures = [var.gcp_autonomous_databases_configuration]
}

run "invalid_odb_networks_dependency_format_fails" {
  command = plan

  variables {
    default_project_id = "test-project"
    default_location   = "us-east4"
    gcp_odb_networks_dependency = {
      primary = { id = "not-a-valid-resource-name" }
    }
    gcp_autonomous_databases_configuration = {}
  }

  expect_failures = [var.gcp_odb_networks_dependency]
}

run "valid_odb_network_dependency_passes" {
  command = plan

  variables {
    default_project_id = "test-project"
    default_location   = "us-east4"
    gcp_odb_networks_dependency = {
      primary = { id = "projects/test-project/locations/us-east4/odbNetworks/test-network" }
    }
    gcp_odb_subnets_dependency = {
      client = { id = "projects/test-project/locations/us-east4/odbNetworks/test-network/odbSubnets/test-subnet" }
    }
    gcp_autonomous_databases_configuration = {}
  }

  assert {
    condition     = length(google_oracle_database_autonomous_database.these) == 0
    error_message = "Expected zero ADB resources when configuration is empty."
  }
}

run "missing_location_without_default_fails" {
  command = plan

  variables {
    default_project_id = "test-project"
    gcp_autonomous_databases_configuration = {
      primary = {
        autonomous_database_id = "test-adb"
        network                = "projects/test-project/global/networks/test-vpc"
        cidr                   = "10.5.0.0/24"
      }
    }
  }

  expect_failures = [google_oracle_database_autonomous_database.these["primary"]]
}

run "odb_network_key_not_in_dependency_fails" {
  command = plan

  variables {
    default_project_id = "test-project"
    default_location   = "us-east4"
    gcp_odb_networks_dependency = {}
    gcp_autonomous_databases_configuration = {
      primary = {
        autonomous_database_id = "test-adb"
        odb_network_key        = "missing-key"
        odb_subnet             = "projects/test-project/locations/us-east4/odbNetworks/net/odbSubnets/sub"
      }
    }
  }

  expect_failures = [google_oracle_database_autonomous_database.these["primary"]]
}
