resource "oci_core_instance" "bastion" {
  #Required
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[var.availability_domain - 1].name
  compartment_id      = var.compartment_ocid
  shape               = var.instance_shape
  display_name        = var.instance_name

  #Optional
  source_details {
    source_id   = var.image_id
    source_type = "image"
  }

  #Optional
  create_vnic_details {
    subnet_id        = var.subnet_id
    assign_public_ip = var.assign_public_ip
  }
  metadata = {
    ssh_authorized_keys = var.ssh_public_key
#    user_data = base64encode(data.template_file.airflow.rendered)
  }
}

