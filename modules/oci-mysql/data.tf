data "oci_identity_availability_domains" "ads" {
  compartment_id = var.compartment_ocid
}

data "oci_mysql_mysql_db_system" "airflow_database" {
  db_system_id = oci_mysql_mysql_db_system.airflow_database.id
}
