data "oci_identity_tenancy" "my_tenancy" {
    #Required
    tenancy_id = var.tenancy_ocid
}

# Lookup namespace
data "oci_objectstorage_namespace" "lookup" {
  compartment_id = var.compartment_ocid
}
