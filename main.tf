module "network" { 
  source = "./modules/network"
  tenancy_ocid = var.tenancy_ocid
  compartment_ocid = var.compartment_ocid
  region = var.region
  useExistingVcn = var.useExistingVcn
  VCN_CIDR = var.VCN_CIDR
  edge_cidr = var.edge_cidr
  private_cidr = var.private_cidr
  vcn_dns_label  = var.vcn_dns_label
  service_port = var.service_port
  custom_vcn = [var.myVcn]
  OKESubnet = var.OKESubnet
  edgeSubnet = var.edgeSubnet
  myVcn = var.myVcn
}

module "fss" {
  source = "./modules/fss"
  compartment_ocid = var.compartment_ocid
  subnet_id =  var.useExistingVcn ? var.OKESubnet : module.network.private-id
  availability_domain = var.availability_domain
  vcn_cidr = data.oci_core_vcn.vcn_info.cidr_block
}

module "oci-mysql" {
  source = "./modules/oci-mysql"
  availability_domain = var.availability_domain
  compartment_ocid = var.compartment_ocid
  mysqladmin_password = var.mysql_admin_password
  mysqladmin_username = var.mysql_admin_username
  mysql_shape = var.mysql_shape
  enable_mysql_backups = var.enable_backups
  oci_mysql_ip = var.private_ip_address
  subnet_id =  var.useExistingVcn ? var.OKESubnet : module.network.private-id
 
}

module "oke" {
  source = "./modules/oke"
  create_new_oke_cluster = var.create_new_oke_cluster
  existing_oke_cluster_id = var.existing_oke_cluster_id
  tenancy_ocid = var.tenancy_ocid
  compartment_ocid = var.compartment_ocid
  cluster_name = var.cluster_name
  kubernetes_version = var.kubernetes_version
  airflow_node_pool_name = var.airflow_node_pool_name
  airflow_node_pool_shape = var.airflow_node_pool_shape
  airflow_node_pool_size = var.airflow_node_pool_size
  cluster_options_add_ons_is_kubernetes_dashboard_enabled =  var.cluster_options_add_ons_is_kubernetes_dashboard_enabled
  cluster_options_admission_controller_options_is_pod_security_policy_enabled = var.cluster_options_admission_controller_options_is_pod_security_policy_enabled
  image_id = data.oci_core_images.oraclelinux7.images.0.id 
  vcn_id = var.useExistingVcn ? var.myVcn : module.network.vcn-id
  subnet_id = var.useExistingVcn ? var.OKESubnet : local.is_oke_public
  lb_subnet_id = module.network.edge-id
  ssh_public_key = var.use_remote_exec ? tls_private_key.oke_ssh_key.public_key_openssh : var.ssh_provided_public_key
  cluster_endpoint_config_is_public_ip_enabled = var.cluster_endpoint_config_is_public_ip_enabled
  endpoint_subnet_id = var.cluster_endpoint_config_is_public_ip_enabled ? module.network.edge-id : module.network.private-id
  node_pool_node_shape_config_memory_in_gbs = var.flex_gbs
  node_pool_node_shape_config_ocpus = var.flex_ocpu
  is_flex_shape = contains(["VM.Standard.E3.Flex", "VM.Standard.E4.Flex", "VM.Optimized3.Flex", "VM.Standard.A1.Flex"], var.airflow_node_pool_shape)
}

module "bastion" {
  depends_on = [module.oke, module.oci-mysql, module.network, module.fss]
  source = "./modules/bastion"
  user_data = var.use_remote_exec ? base64encode(file("userdata/init.sh")) : base64encode(file("userdata/cloudinit.sh"))
  compartment_ocid = var.compartment_ocid
  availability_domain = var.availability_domain
  image_id = data.oci_core_images.oraclelinux7.images.0.id 
  instance_shape   = var.bastion_shape
  instance_name = var.bastion_name
  subnet_id =  var.useExistingVcn ? var.edgeSubnet : local.bastion_subnet
  ssh_public_key = var.use_remote_exec ? tls_private_key.oke_ssh_key.public_key_openssh : var.ssh_provided_public_key
  public_edge_node = var.public_edge_node
  image_name = var.image_name
  image_label = var.image_label
  oke_cluster_id = var.create_new_oke_cluster ? module.oke.cluster_id : var.existing_oke_cluster_id
  nodepool_id = module.oke.nodepool_id
  repo_name = var.repo_name
  registry = var.registry
  registry_user = var.username
  secret_id = var.vault_secret_id
  tenancy_ocid = var.tenancy_ocid
  admin_db_user = var.mysql_admin_username
  admin_db_password = var.mysql_admin_password
  airflow_db_user = var.airflow_username
  airflow_db_password = var.airflow_password
  db_name = var.db_name
  db_ip = module.oci-mysql.db_ip
  db_port = module.oci-mysql.db_port
  namespace = var.airflow_namespace
  kube_label = var.kube_label
  mount_target_id = module.fss.mount_target_id
  nfs_ip = module.fss.nfs_ip
  bastion_flex_gbs = var.bastion_flex_gbs
  bastion_flex_ocpus = var.bastion_flex_ocpus 
  is_flex_shape = contains(["VM.Standard.E3.Flex", "VM.Standard.E4.Flex", "VM.Optimized3.Flex", "VM.Standard.A1.Flex"], var.bastion_shape)
}

module "airflow" {
  count = var.use_remote_exec ? 1 : 0
  source                = "./modules/airflow"
  airflow_depends_on = [module.bastion, module.oke, module.oci-mysql, module.network]
  compartment_ocid       = var.compartment_ocid
  tenancy_ocid           = var.tenancy_ocid
  instance_ip          = module.bastion.public_ip
  cluster_id           = var.create_new_oke_cluster ? module.oke.cluster_id : var.existing_oke_cluster_id
  nodepool_id          = module.oke.nodepool_id
  region               = var.region
  ssh_public_key = var.use_remote_exec ? tls_private_key.oke_ssh_key.public_key_openssh : var.ssh_provided_public_key
  ssh_private_key = tls_private_key.oke_ssh_key.private_key_pem
  registry = var.registry
  repo_name = var.repo_name
  registry_user = var.username
  image_name = var.image_name
  image_label = var.image_label
  secret_id = var.vault_secret_id
  namespace = var.airflow_namespace
  kube_label = var.kube_label
  mount_target_id = module.fss.mount_target_id
  nfs_ip = module.fss.nfs_ip
  admin_db_user = var.mysql_admin_username
  admin_db_password = var.mysql_admin_password
  airflow_db_user = var.airflow_username
  airflow_db_password = var.airflow_password
  db_name = var.db_name
  db_ip = module.oci-mysql.db_ip
  db_port = module.oci-mysql.db_port
}
