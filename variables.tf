# ---------------------------------------------------------------------------------------------------------------------
# SSH Keys - Put this to top level because they are required
# ---------------------------------------------------------------------------------------------------------------------

variable "ssh_provided_key" {
  default = ""
}

# ---------------------------------------------------------------------------------------------------------------------
# Network Settings
# --------------------------------------------------------------------------------------------------------------------- 
variable "useExistingVcn" {
  default = "false"
}
variable "custom_cidrs" {
  default = "false"
}
variable "VCN_CIDR" {
  default = "10.0.0.0/16"
}
variable "edge_cidr" {
  default = "10.0.1.0/24"
}
variable "private_cidr" {
  default = "10.0.2.0/24"
}
variable "myVcn" {
  default = " "
}
variable "privateSubnet" {
  default = " "
}
variable "edgeSubnet" {
  default = " "
}
variable "vcn_dns_label" { 
  default = "airflowvcn"
}
# Which AD to target - this can be adjusted.  Default 1 for single AD regions.
variable "availability_domain" {
  default = "1"
}
# ---------------------------------------------------------------------------------------------------------------------
# ORM Schema variables
# You should modify these based on deployment requirements.
# These default to recommended values
# --------------------------------------------------------------------------------------------------------------------- 
variable "meta_db_type" {
  default = "OCI Mysql"
}
variable "provide_ssh_key" {
  default = "true"
}
variable "deploy_to_private_subnet" {
  default = "true"
}
variable "create_new_oke_cluster" {
  default = "true"
}
variable "kubernetes_version" {
  default = "v1.18.10"
}
variable "image_operating_system" {
  default = "Oracle Linux"
}
variable "image_operating_system_version" {
  default = "7.8"
}
variable "webserver_node_pool_name" {
  default = "Airflow-Webserver-Pool"
}
variable "webserver_node_pool_shape" {}
variable "num_pool_webserver" {
  default = 1
}
variable "scheduler_node_pool_name" {
  default = "Airflow-Scheduler-Pool"
}
variable "scheduler_node_pool_shape" {}
variable "num_pool_scheduler" {
  default = 1
}
variable "worker_node_pool_name" {
  default = "Airflow-Worker-Pool"
}
variable "worker_node_pool_shape" {}
variable "num_pool_worker" {
  default = 1
}
variable "mq_node_pool_name" {
  default = "Airflow-MQ-Pool"
}
variable "mq_node_pool_shape" {}
variable "num_pool_mq" {
  default = 1
}
variable "cluster_options_add_ons_is_kubernetes_dashboard_enabled" {
  default = true
}
variable "cluster_options_add_ons_is_tiller_enabled" {
  default = true
}
variable "cluster_name" {}
variable "cluster_options_admission_controller_options_is_pod_security_policy_enabled" {
  description = "If true: The pod security policy admission controller will use pod security policies to restrict the pods accepted into the cluster."
  default     = false
}
variable "existing_oke_cluster_id" {
  default = " "
}
# ---------------------------------------------------------------------------------------------------------------------
# Environmental variables
# You probably want to define these as environmental variables.
# Instructions on that are here: https://github.com/oracle/oci-quickstart-prerequisites
# ---------------------------------------------------------------------------------------------------------------------

variable "compartment_ocid" {}

# Required by the OCI Provider

variable "tenancy_ocid" {}
variable "region" {}
