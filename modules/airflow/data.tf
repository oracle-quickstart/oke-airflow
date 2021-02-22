data "oci_identity_tenancy" "my_tenancy" {
    #Required
    tenancy_id = var.tenancy_ocid
}

