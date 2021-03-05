data "oci_core_services" "net_services" {
#  count = var.useExistingVcn ? 0 : 1
  filter {
    name   = "name"
    values = ["All .* Services In Oracle Services Network"]
    regex  = true
  }
}


# Randoms
resource "random_string" "deploy_id" {
  length  = 4
  special = false
}

