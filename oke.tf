resource "oci_containerengine_cluster" "oke_airflow_cluster" {
  compartment_id     = var.compartment_ocid
  kubernetes_version = var.kubernetes_version
  name               = "${var.cluster_name}-${random_string.deploy_id.result}"
  vcn_id             = var.useExistingVcn ? var.myVcn : module.network.vcn-id

  options {
    add_ons {
      is_kubernetes_dashboard_enabled = var.cluster_options_add_ons_is_kubernetes_dashboard_enabled
      is_tiller_enabled               = false # Default is false, left here for reference
    }
    admission_controller_options {
      is_pod_security_policy_enabled = var.cluster_options_admission_controller_options_is_pod_security_policy_enabled
    }
  }

  count = var.create_new_oke_cluster ? 1 : 0
}

resource "oci_containerengine_node_pool" "airflow_webserver_node_pool" {
  cluster_id         = oci_containerengine_cluster.oke_airflow_cluster[0].id
  compartment_id     = var.compartment_ocid
  kubernetes_version = var.kubernetes_version
  name               = var.webserver_node_pool_name
  node_shape         = var.webserver_node_pool_shape
  ssh_public_key     = var.provide_ssh_key ? var.ssh_provided_key : tls_private_key.oke_ssh_key.public_key_openssh

  node_config_details {
    dynamic "placement_configs" {
      for_each = data.oci_identity_availability_domains.ADs.availability_domains

      content {
        availability_domain = placement_configs.value.name
        subnet_id           =  var.deploy_to_private_subnet ? module.network.private-id : module.network.edge-id 
      }
    }
    size = var.num_pool_webserver
  }

  node_source_details {
    source_type = "IMAGE"
    image_id    = var.OELImageOCID[var.region]
  }

  initial_node_labels {
    key   = "name"
    value = var.webserver_node_pool_name
  }

  count = var.create_new_oke_cluster ? 1 : 0
}

resource "oci_containerengine_node_pool" "airflow_scheduler_node_pool" {
  cluster_id         = oci_containerengine_cluster.oke_airflow_cluster[0].id
  compartment_id     = var.compartment_ocid
  kubernetes_version = var.kubernetes_version
  name               = var.scheduler_node_pool_name
  node_shape         = var.scheduler_node_pool_shape
  ssh_public_key     = var.provide_ssh_key ? var.ssh_provided_key : tls_private_key.oke_ssh_key.public_key_openssh

  node_config_details {
    dynamic "placement_configs" {
      for_each = data.oci_identity_availability_domains.ADs.availability_domains

      content {
        availability_domain = placement_configs.value.name
        subnet_id           = var.deploy_to_private_subnet ? module.network.private-id : module.network.edge-id
      }
    }
    size = var.num_pool_scheduler
  }

  node_source_details {
    source_type = "IMAGE"
    image_id    = var.OELImageOCID[var.region]
  }

  initial_node_labels {
    key   = "name"
    value = var.scheduler_node_pool_name
  }

  count = var.create_new_oke_cluster ? 1 : 0
}

resource "oci_containerengine_node_pool" "airflow_worker_node_pool" {
  cluster_id         = oci_containerengine_cluster.oke_airflow_cluster[0].id
  compartment_id     = var.compartment_ocid
  kubernetes_version = var.kubernetes_version
  name               = var.worker_node_pool_name
  node_shape         = var.worker_node_pool_shape
  ssh_public_key     = var.provide_ssh_key ? var.ssh_provided_key : tls_private_key.oke_ssh_key.public_key_openssh

  node_config_details {
    dynamic "placement_configs" {
      for_each = data.oci_identity_availability_domains.ADs.availability_domains

      content {
        availability_domain = placement_configs.value.name
        subnet_id           = var.deploy_to_private_subnet ? module.network.private-id : module.network.edge-id
      }
    }
    size = var.num_pool_worker
  }

  node_source_details {
    source_type = "IMAGE"
    image_id    = var.OELImageOCID[var.region]
  }

  initial_node_labels {
    key   = "name"
    value = var.worker_node_pool_name
  }

  count = var.create_new_oke_cluster ? 1 : 0
}

resource "oci_containerengine_node_pool" "airflow_mq_node_pool" {
  cluster_id         = oci_containerengine_cluster.oke_airflow_cluster[0].id
  compartment_id     = var.compartment_ocid
  kubernetes_version = var.kubernetes_version
  name               = var.mq_node_pool_name
  node_shape         = var.mq_node_pool_shape
  ssh_public_key     = var.provide_ssh_key ? var.ssh_provided_key : tls_private_key.oke_ssh_key.public_key_openssh

  node_config_details {
    dynamic "placement_configs" {
      for_each = data.oci_identity_availability_domains.ADs.availability_domains

      content {
        availability_domain = placement_configs.value.name
        subnet_id           = var.deploy_to_private_subnet ? module.network.private-id : module.network.edge-id
      }
    }
    size = var.num_pool_mq
  }

  node_source_details {
    source_type = "IMAGE"
    image_id    = var.OELImageOCID[var.region]
  }

  initial_node_labels {
    key   = "name"
    value = var.worker_node_pool_name
  }

  count = var.create_new_oke_cluster ? 1 : 0
}

# Local kubeconfig for when using Terraform locally. Not used by Oracle Resource Manager
resource "local_file" "kubeconfig" {
  content  = data.oci_containerengine_cluster_kube_config.oke_cluster_kube_config.content
  filename = "generated/kubeconfig"
}

# Generate ssh keys to access Worker Nodes, if generate_public_ssh_key=true, applies to the pool
resource "tls_private_key" "oke_worker_node_ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}
