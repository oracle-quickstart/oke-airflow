data "oci_identity_availability_domains" "ads" {
  compartment_id = var.compartment_ocid
}
data "template_file" "airflow" {
  template = file("${path.module}/../../userdata/init.sh")
}
