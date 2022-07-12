# ---------------------------------------------------------------------------------------------------------------------
# AD Settings. By default uses AD1 
# ---------------------------------------------------------------------------------------------------------------------
variable "availability_domain" {
  default = "1"
}

# ---------------------------------------------------------------------------------------------------------------------
# SSH Keys - Put this to top level because they are required
# ---------------------------------------------------------------------------------------------------------------------
variable "ssh_provided_public_key" {
  default = ""
}


# ---------------------------------------------------------------------------------------------------------------------
# Network Settings
# --------------------------------------------------------------------------------------------------------------------- 

# If you want to use an existing VCN set useExistingVcn = "true" and configure OCID(s) of myVcn, OKESubnet and edgeSubnet

variable "useExistingVcn" {
  default = "false"
}

variable "myVcn" {
  default = " "
}
variable "OKESubnet" {
  default = " "
}
variable "edgeSubnet" {
  default = " "
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
  default =  "10.0.2.0/24"
}

variable "vcn_dns_label" {
  default = "airflowvcn"
}

variable "service_port" {
  default = "8080"
}

variable "public_edge_node" {
  default = true 
}

# ---------------------------------------------------------------------------------------------------------------------
# OKE Settings
# ---------------------------------------------------------------------------------------------------------------------

variable "create_new_oke_cluster" {
  default = "true"
}

variable "existing_oke_cluster_id" {
  default = " "
}

variable "cluster_name" {
  default = "airflow-cluster"
}

variable "kubernetes_version" {
  default = "v1.20.11"
}

variable "airflow_node_pool_name" {
  default = "Airflow-Node-Pool"
}

variable "airflow_node_pool_shape" {
  default = "VM.Standard2.2"
}

variable "airflow_node_pool_size" {
  default = 1
}

variable "airflow_namespace" {
  default = "airflow"
}

variable "kube_label" {
  default = "airflow"
}

variable "cluster_options_add_ons_is_kubernetes_dashboard_enabled" {
  default = "false"
}

variable "cluster_options_admission_controller_options_is_pod_security_policy_enabled" {
  default = "false"
}

variable "cluster_endpoint_config_is_public_ip_enabled" {
  default = "false" 
}

variable "use_remote_exec" {
  default = "true"
}

variable "endpoint_subnet_id" {
  default = " "
}

variable "node_pool_node_shape_config_memory_in_gbs" {
  default = 2
}

variable "node_pool_node_shape_config_ocpus" {
  default = 1
}

variable "flex_gbs" {
  default = 2
}

variable "flex_ocpu" {
  default = 1
}

# ---------------------------------------------------------------------------------------------------------------------
# OCI registry settings
# ---------------------------------------------------------------------------------------------------------------------

variable "registry" {
  default = "iad.ocir.io"
}

variable "repo_name" {
  default = "airflow"
}

# Set the user to login OCIR registry
variable "username" {
  default = "oracleidentitycloudservice/<username>"
}

variable "image_name" {
  default = "airflow"
}

variable "image_label" {
  default = "2.0"
}

# ---------------------------------------------------------------------------------------------------------------------
# OCI vault secret ID where authentication key is stored 
# it is used for authenticatoin when pushing/pulling images to/from OCIR registry 
# Set it to secret OCID where you store authentication token that is used to push/pull images from OCIR
# ---------------------------------------------------------------------------------------------------------------------
variable "vault_secret_id" {
#  default = "ocid1.vaultsecret.oc1.iad.xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
}


# ---------------------------------------------------------------------------------------------------------------------
# DB settings
# ---------------------------------------------------------------------------------------------------------------------

variable "meta_db_type" {
  default = "OCI Mysql"
}

variable "mysql_admin_username" {
  default = "mysqladmin"
}

variable "mysql_admin_password" {}

variable "mysql_shape" {
  default = "MySQL.VM.Standard.E3.1.8GB"
}

variable "enable_backups" {
  default = "false"
}

variable "private_ip_address" {
  default = "10.0.2.8"
}

variable "db_name" {
  default = "airflow"
}

variable "airflow_username" {
  default = "airflow"
}

variable "airflow_password" {}


# ---------------------------------------------------------------------------------------------------------------------
# Bastion VM Settings
# ---------------------------------------------------------------------------------------------------------------------


variable "bastion_name" {
  default = "bastion"
}

variable "bastion_shape" {
  default = "VM.Standard2.1"
}

variable "bastion_flex_gbs" {
  default = 1
}

variable "bastion_flex_ocpus" {
  default = 2
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

