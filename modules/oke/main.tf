resource "oci_containerengine_cluster" "oke_airflow_cluster" {
  compartment_id     = var.compartment_ocid
  kubernetes_version = var.kubernetes_version
#  name               = "${var.cluster_name}-${random_string.deploy_id.result}"
  name               = var.cluster_name
  vcn_id             = var.vcn_id

  options {
    add_ons {
      is_kubernetes_dashboard_enabled = var.cluster_options_add_ons_is_kubernetes_dashboard_enabled
      is_tiller_enabled               = false # Default is false, left here for reference
    }
    admission_controller_options {
      is_pod_security_policy_enabled = var.cluster_options_admission_controller_options_is_pod_security_policy_enabled
    }
      service_lb_subnet_ids = [var.lb_subnet_id]
  }

  count = var.create_new_oke_cluster ? 1 : 0
}

resource "oci_containerengine_node_pool" "airflow_node_pool" {
  cluster_id         = var.create_new_oke_cluster ? oci_containerengine_cluster.oke_airflow_cluster[0].id : var.existing_oke_cluster_id
  compartment_id     = var.compartment_ocid
  kubernetes_version = var.kubernetes_version
  name               = var.airflow_node_pool_name
  node_shape         = var.airflow_node_pool_shape
  ssh_public_key     = var.ssh_public_key

  node_config_details {
    dynamic "placement_configs" {
      for_each = data.oci_identity_availability_domains.ads.availability_domains

      content {
        availability_domain = placement_configs.value.name
        subnet_id           =  var.subnet_id
      }
    }
    size = var.airflow_node_pool_size
  }

  node_source_details {
    source_type = "IMAGE"
    image_id    = var.image_id
  }

  initial_node_labels {
    key   = "name"
    value = var.airflow_node_pool_name
  }

#  count = var.create_new_oke_cluster ? 1 : 0
}

# Local kubeconfig for when using Terraform locally. Not used by Oracle Resource Manager
resource "local_file" "kubeconfig" {
  content  = data.oci_containerengine_cluster_kube_config.oke_cluster_kube_config.content
  filename = "generated/kubeconfig"
}

# Generate ssh keys to access Worker Nodes, if provide_ssh_key=false, applies to the pool
resource "tls_private_key" "oke_worker_node_ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}
