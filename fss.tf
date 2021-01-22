module "fss" {
  source = "./modules/fss"
  compartment_ocid = var.compartment_ocid
  subnet_id =  var.useExistingVcn ? var.privateSubnet : module.network.private-id
  availability_domain = var.availability_domain
  vcn_cidr = data.oci_core_vcn.vcn_info.cidr_block
}

