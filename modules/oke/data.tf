# Gets a list of Availability Domains
data "oci_identity_availability_domains" "ads" {
  compartment_id = var.tenancy_ocid
}

locals {
  flex_shape = var.is_flex_shape ? [{ memory_in_gbs = var.node_pool_node_shape_config_memory_in_gbs, ocpus = var.node_pool_node_shape_config_ocpus }] : []
}
