variable "availability_domain" {}
variable "compartment_ocid" {}
variable "subnet_id" {}
variable "instance_name" {}
variable "instance_shape" {}
variable "image_id" {}
variable "public_edge_node" {}
variable "ssh_public_key" {}
variable "image_name" {}
variable "image_label" {}
variable "oke_cluster_id" {}
variable "nodepool_id" {}
variable "repo_name" {}
variable "registry" {}
variable "registry_user" {}
variable "secret_id" {}
variable "tenancy_ocid" {}
variable "admin_db_user" {}
variable "admin_db_password" {}
variable "airflow_db_user" {}
variable "airflow_db_password" {}
variable "db_name" {}
variable "db_ip" {}
variable "db_port" {}
variable "namespace" {}
variable "kube_label" {}
variable "mount_target_id" {}
variable "nfs_ip" {}
variable "user_data" {}
locals {
   sql_alchemy_conn=base64encode("mysql://${var.airflow_db_user}:${var.airflow_db_password}@${var.db_ip}:${var.db_port}/${var.db_name}")
}
variable "bastion_flex_gbs" {}
variable "bastion_flex_ocpus" {}
variable "is_flex_shape" {}
