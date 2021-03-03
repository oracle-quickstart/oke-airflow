module "network" { 
  source = "./modules/network"
  tenancy_ocid = var.tenancy_ocid
  compartment_ocid = var.compartment_ocid
  region = var.region
  useExistingVcn = var.useExistingVcn
  VCN_CIDR = var.network_params["VCN_CIDR"]
  edge_cidr = var.network_params["edge_cidr"]
  private_cidr = var.network_params["private_cidr"]
  vcn_dns_label  = var.network_params["vcn_dns_label"]
  service_port = var.network_params["service_port"]
  custom_vcn = [var.myVcn]
  privateSubnet = var.privateSubnet
  edgeSubnet = var.edgeSubnet
  myVcn = var.myVcn
}

module "fss" {
  source = "./modules/fss"
  compartment_ocid = var.compartment_ocid
  subnet_id =  var.useExistingVcn ? var.privateSubnet : module.network.private-id
  availability_domain = var.availability_domain
  vcn_cidr = data.oci_core_vcn.vcn_info.cidr_block
}

module "oci-mysql" {
  source = "./modules/oci-mysql"
  availability_domain = var.availability_domain
  compartment_ocid = var.compartment_ocid
  mysqladmin_password = var.mysql_params["admin_password"]
  mysqladmin_username = var.mysql_params["admin_username"]
  mysql_shape = var.mysql_params["shape"]
  enable_mysql_backups = var.mysql_params["enable_backups"]
  oci_mysql_ip = var.mysql_params["private_ip_address"]
  subnet_id =  var.useExistingVcn ? var.privateSubnet : module.network.private-id
 
}

module "oke" {
  source = "./modules/oke"
  create_new_oke_cluster = var.create_new_oke_cluster
  existing_oke_cluster_id = var.existing_oke_cluster_id
  tenancy_ocid = var.tenancy_ocid
  compartment_ocid = var.compartment_ocid
  cluster_name = var.oke_params["cluster_name"]
  kubernetes_version = var.oke_params["kubernetes_version"]
  airflow_node_pool_name = var.oke_params["airflow_node_pool_name"]
  airflow_node_pool_shape = var.oke_params["airflow_node_pool_shape"]
  airflow_node_pool_size = var.oke_params["airflow_node_pool_size"]
  cluster_options_add_ons_is_kubernetes_dashboard_enabled =  var.oke_params["cluster_options_add_ons_is_kubernetes_dashboard_enabled"]
  cluster_options_admission_controller_options_is_pod_security_policy_enabled = var.oke_params["cluster_options_admission_controller_options_is_pod_security_policy_enabled"]
  image_id = var.OELImageOCID[var.region]
  vcn_id = var.useExistingVcn ? var.myVcn : module.network.vcn-id
  subnet_id =  module.network.private-id
  lb_subnet_id = module.network.edge-id 
  ssh_public_key = var.provide_ssh_key ? file(var.ssh_provided_public_key) : tls_private_key.ssh_key.public_key_openssh
}

module "bastion" {
  source = "./modules/bastion"
  compartment_ocid = var.compartment_ocid
  availability_domain = var.availability_domain
  image_id = var.OELImageOCID[var.region]
  instance_shape   = var.bastion_params["shape"]
  instance_name = var.bastion_params["name"]
  subnet_id =  var.useExistingVcn ? var.edgeSubnet : module.network.edge-id
  assign_public_ip = "true"
  ssh_public_key = var.provide_ssh_key ? file(var.ssh_provided_public_key) : tls_private_key.ssh_key.public_key_openssh
  bastion_depends_on = [module.oke]
}

module "airflow" {
  source                = "./modules/airflow"
  airflow_depends_on = [module.bastion, module.oke, module.oci-mysql, module.bastion, module.network]
  compartment_ocid       = var.compartment_ocid
  tenancy_ocid           = var.tenancy_ocid
  instance_ip          = module.bastion.public_ip
  cluster_id           = module.oke.cluster_id
  nodepool_id          = module.oke.nodepool_id
  region               = var.region
#  number_of_nodes       = module.oke.number_of_nodes
#  pods_cidrs            = module.oke.pods_cidrs
#  provider_oci          = var.provider_oci
#  ocir_urls             = var.ocir_urls
#
#  check_node_active     = var.check_node_active
#  nodepool_depends_on   = [module.oke.nodepool_id]
  ssh_public_key = var.provide_ssh_key ? file(var.ssh_provided_public_key) : tls_private_key.ssh_key.public_key_openssh
  ssh_private_key = var.provide_ssh_key ? file(var.ssh_provided_private_key) : tls_private_key.ssh_key.private_key_pem
  registry = var.registry_params["registry"]
  repo_name = var.registry_params["repo_name"]
  registry_user = var.registry_params["username"]
  image_name = var.registry_params["image_name"]
  image_label = var.registry_params["image_label"]
  secret_id = var.vault_secret_id
  namespace = var.oke_params["airflow_namespace"]
  kube_label = var.oke_params["kube_label"]
  mount_target_id = module.fss.mount_target_id
  nfs_ip = module.fss.nfs_ip
  admin_db_user = var.mysql_params["admin_username"]
  admin_db_password = var.mysql_params["admin_password"]
  airflow_db_user = var.mysql_params["airflow_username"]
  airflow_db_password = var.mysql_params["airflow_password"]
  db_name = var.mysql_params["db_name"]
  db_ip = module.oci-mysql.db_ip
  db_port = module.oci-mysql.db_port
}
