resource "oci_file_storage_file_system" "airflow_dags" {
  availability_domain = var.availability_domain
  compartment_id      = var.compartment_ocid
  display_name = "Airflow Dags"
}

resource "oci_file_storage_file_system" "airflow_logs" {
  availability_domain = var.availability_domain
  compartment_id      = var.compartment_ocid
  display_name = "Airflow Logs"
}

resource "oci_file_storage_export_set" "airflow_export_set" {
  mount_target_id = oci_file_storage_mount_target.airflow_mount_target.id
  display_name      = "Airflow Dags Export"
}

resource "oci_file_storage_export" "airflow_export_mount1" {
  export_set_id  = oci_file_storage_export_set.airflow_export_set.id
  file_system_id = oci_file_storage_file_system.airflow_dags.id
  path           = "/airflow-dags"

  export_options {
    source                         = var.vcn_cidr
    access                         = "READ_WRITE"
    identity_squash                = "NONE"
    require_privileged_source_port = false
  }
}

resource "oci_file_storage_export" "airflow_export_mount2" {
  export_set_id  = oci_file_storage_export_set.airflow_export_set.id
  file_system_id = oci_file_storage_file_system.airflow_logs.id
  path           = "/airflow-logs"

  export_options {
    source                         = var.vcn_cidr
    access                         = "READ_WRITE"
    identity_squash                = "NONE"
    require_privileged_source_port = false
  }
}

resource "oci_file_storage_mount_target" "airflow_mount_target" {
  availability_domain = var.availability_domain
  compartment_id      = var.compartment_ocid
  subnet_id           = var.subnet_id
}

