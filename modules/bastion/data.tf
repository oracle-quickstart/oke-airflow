data "oci_identity_availability_domains" "ads" {
  compartment_id = var.compartment_ocid
}

locals {
  flex_shape = var.is_flex_shape ? [{ memory_in_gbs = var.bastion_flex_gbs, ocpus = var.bastion_flex_ocpus }] : []
}
