output "db_ip" {
    value = data.oci_mysql_mysql_db_system.airflow_database.endpoints[0].ip_address 
}

output "db_port" {
    value = data.oci_mysql_mysql_db_system.airflow_database.endpoints[0].port
}
