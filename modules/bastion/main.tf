resource "oci_core_instance" "bastion" {
  availability_domain = var.availability_domain
  compartment_id      = var.compartment_ocid
  shape               = var.instance_shape
  display_name        = var.instance_name

  source_details {
    source_id   = var.image_id
    source_type = "image"
  }

  create_vnic_details {
    subnet_id        = var.subnet_id
    assign_public_ip = var.public_edge_node
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
    user_data = var.user_data
  }

  extended_metadata = {
    image_name = var.image_name
    image_label = var.image_label
    oke_cluster_id = var.oke_cluster_id
    nodepool_id = var.nodepool_id
    repo_name = var.repo_name
    registry = var.registry
    registry_user = var.registry_user
    secret_id = var.secret_id
    tenancy_ocid = var.tenancy_ocid
    sql_alchemy_conn = local.sql_alchemy_conn
    namespace = var.namespace
    kube_label = var.kube_label
    mount_target_id = var.mount_target_id
    nfs_ip = var.nfs_ip
    admin_db_user = var.admin_db_user
    admin_db_password = base64encode(var.admin_db_password)
    db_ip = var.db_ip
    db_name = var.db_name
    airflow_db_user = var.airflow_db_user
    airflow_db_password = base64encode(var.airflow_db_password)
  }
}

