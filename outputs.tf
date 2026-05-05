# Copyright (c) 2026, Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

output "module_name" {
  description = "The module instance name."
  value       = var.module_name
}

output "gcp_odb_networks" {
  description = "Created ODB networks, keyed by input key."
  value = var.enable_output ? {
    for key, network in google_oracle_database_odb_network.these : key => {
      id             = network.id
      name           = network.name
      odb_network_id = network.odb_network_id
      location       = network.location
      project        = network.project
      state          = network.state
      entitlement_id = network.entitlement_id
    }
  } : null
}

output "gcp_odb_subnets" {
  description = "Created ODB subnets, keyed by input key."
  value = var.enable_output ? {
    for key, subnet in google_oracle_database_odb_subnet.these : key => {
      id            = subnet.id
      name          = subnet.name
      odb_subnet_id = subnet.odb_subnet_id
      odbnetwork    = subnet.odbnetwork
      cidr_range    = subnet.cidr_range
      purpose       = subnet.purpose
      location      = subnet.location
      project       = subnet.project
      state         = subnet.state
    }
  } : null
}

output "gcp_cloud_exadata_infrastructures" {
  description = "Created Exadata infrastructures, keyed by input key."
  value = var.enable_output ? {
    for key, infrastructure in google_oracle_database_cloud_exadata_infrastructure.these : key => {
      id                                 = infrastructure.id
      name                               = infrastructure.name
      cloud_exadata_infrastructure_id    = infrastructure.cloud_exadata_infrastructure_id
      location                           = infrastructure.location
      project                            = infrastructure.project
      entitlement_id                     = infrastructure.entitlement_id
      ocid                               = try(infrastructure.properties[0].ocid, null)
      state                              = try(infrastructure.properties[0].state, null)
      shape                              = try(infrastructure.properties[0].shape, null)
      available_storage_size_gb          = try(infrastructure.properties[0].available_storage_size_gb, null)
      cpu_count                          = try(infrastructure.properties[0].cpu_count, null)
      max_cpu_count                      = try(infrastructure.properties[0].max_cpu_count, null)
      memory_size_gb                     = try(infrastructure.properties[0].memory_size_gb, null)
      max_memory_gb                      = try(infrastructure.properties[0].max_memory_gb, null)
      data_storage_size_tb               = try(infrastructure.properties[0].data_storage_size_tb, null)
      max_data_storage_tb                = try(infrastructure.properties[0].max_data_storage_tb, null)
      db_node_storage_size_gb            = try(infrastructure.properties[0].db_node_storage_size_gb, null)
      max_db_node_storage_size_gb        = try(infrastructure.properties[0].max_db_node_storage_size_gb, null)
      next_maintenance_run_id            = try(infrastructure.properties[0].next_maintenance_run_id, null)
      next_maintenance_run_time          = try(infrastructure.properties[0].next_maintenance_run_time, null)
      next_security_maintenance_run_time = try(infrastructure.properties[0].next_security_maintenance_run_time, null)
      monthly_db_server_version          = try(infrastructure.properties[0].monthly_db_server_version, null)
      monthly_storage_server_version     = try(infrastructure.properties[0].monthly_storage_server_version, null)
      oci_url                            = try(infrastructure.properties[0].oci_url, null)
    }
  } : null
}

output "gcp_cloud_vm_clusters" {
  description = "Created Exadata VM clusters, keyed by input key."
  value = var.enable_output ? {
    for key, cluster in google_oracle_database_cloud_vm_cluster.these : key => {
      id                         = cluster.id
      name                       = cluster.name
      cloud_vm_cluster_id        = cluster.cloud_vm_cluster_id
      location                   = cluster.location
      project                    = cluster.project
      gcp_oracle_zone            = cluster.gcp_oracle_zone
      ocid                       = try(cluster.properties[0].ocid, null)
      state                      = try(cluster.properties[0].state, null)
      shape                      = try(cluster.properties[0].shape, null)
      hostname                   = try(cluster.properties[0].hostname, null)
      domain                     = try(cluster.properties[0].domain, null)
      scan_dns                   = try(cluster.properties[0].scan_dns, null)
      scan_ip_ids                = try(cluster.properties[0].scan_ip_ids, null)
      scan_listener_port_tcp     = try(cluster.properties[0].scan_listener_port_tcp, null)
      scan_listener_port_tcp_ssl = try(cluster.properties[0].scan_listener_port_tcp_ssl, null)
      scan_dns_record_id         = try(cluster.properties[0].scan_dns_record_id, null)
      dns_listener_ip            = try(cluster.properties[0].dns_listener_ip, null)
      system_version             = try(cluster.properties[0].system_version, null)
      compartment_id             = try(cluster.properties[0].compartment_id, null)
      oci_url                    = try(cluster.properties[0].oci_url, null)
    }
  } : null
}
