variable "availability_domain" {}
variable "compartment_ocid" {}
variable "subnet_id" {}
variable "instance_name" {}
variable "instance_shape" {}
variable "image_id" {}
variable "assign_public_ip" {}
variable "ssh_public_key" {}
variable "bastion_depends_on" {
  type    = any
  default = null
}