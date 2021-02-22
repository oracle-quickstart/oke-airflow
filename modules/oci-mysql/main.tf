resource "oci_mysql_mysql_db_system" "airflow_database" {
    admin_password = var.mysqladmin_password
    admin_username = var.mysqladmin_username
#    availability_domain = var.availability_domain
    availability_domain = data.oci_identity_availability_domains.ads.availability_domains[var.availability_domain - 1].name
    compartment_id = var.compartment_ocid
    shape_name = var.mysql_shape
    subnet_id = var.subnet_id
    backup_policy {
    is_enabled        = var.enable_mysql_backups
    retention_in_days = "10"
    }
    description = "Airflow Database"
    port          = "3306"
    port_x        = "33306"
    data_storage_size_in_gb = 50
    ip_address = var.oci_mysql_ip
}
