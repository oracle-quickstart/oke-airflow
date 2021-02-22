data "oci_identity_availability_domains" "ads" {
  compartment_id = var.compartment_ocid
}
data "template_file" "airflow" {
  template = "${file("./scripts/init.sh")}"
}