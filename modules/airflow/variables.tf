variable airflow_depends_on {}

variable "instance_ip" {}

variable "compartment_ocid" {}

variable "ssh_public_key" {}

variable "ssh_private_key" {}

variable "cluster_id" {}

variable "nodepool_id" {}

variable region {}

variable registry {}

variable repo_name {}

variable registry_user {}

variable image_name {}

variable image_label {}

variable secret_id {}

variable tenancy_ocid {}

variable namespace {}

variable kube_label {}

variable mount_target_id {}

variable nfs_ip {}

variable admin_db_user {}

variable admin_db_password {}

variable airflow_db_user {}

variable airflow_db_password {}

variable db_name {}

variable db_ip {}

variable db_port {}

locals {
   sql_alchemy_conn=base64encode("mysql://${var.airflow_db_user}:${var.airflow_db_password}@${var.db_ip}:${var.db_port}/${var.db_name}")
}



