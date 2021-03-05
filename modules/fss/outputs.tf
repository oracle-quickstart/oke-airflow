locals {
  mount_target_id = oci_file_storage_mount_target.airflow_mount_target.id 
}

output "mount_target_id" {
    value = local.mount_target_id
}

output "nfs_ip" {
    value = lookup(data.oci_core_private_ips.fss_ip.private_ips[0], "ip_address") 
}
