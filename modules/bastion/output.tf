output "bastion" {
  value = oci_core_instance.bastion
}

locals {

  private_ip = oci_core_instance.bastion.private_ip

  public_ip = oci_core_instance.bastion.public_ip

  instance_id = oci_core_instance.bastion.id
    
}

output "private_ip" {
  value = local.private_ip
}

output "public_ip" {
  value = local.public_ip
}

output "instance_id" {
  value = local.instance_id
}
