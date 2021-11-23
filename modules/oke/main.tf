resource "oci_containerengine_cluster" "oke_airflow_cluster" {
  compartment_id     = var.compartment_ocid
  kubernetes_version = var.kubernetes_version
  name               = var.cluster_name
  vcn_id             = var.vcn_id

  endpoint_config {
    is_public_ip_enabled = var.cluster_endpoint_config_is_public_ip_enabled
    # nsg_ids = var.cluster_endpoint_config_nsg_ids
    subnet_id = var.endpoint_subnet_id
  }

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

  dynamic "node_shape_config" {
    for_each = local.flex_shape
      content {
        memory_in_gbs = node_shape_config.value.memory_in_gbs
        ocpus = node_shape_config.value.ocpus
      }
  }

  node_source_details {
    source_type = "IMAGE"
    image_id    = var.image_id
  }

  initial_node_labels {
    key   = "name"
    value = var.airflow_node_pool_name
  }
}
