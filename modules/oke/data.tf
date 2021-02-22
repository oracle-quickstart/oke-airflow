# Gets a list of Availability Domains
data "oci_identity_availability_domains" "ads" {
  compartment_id = var.tenancy_ocid
}

# Gets kubeconfig
data "oci_containerengine_cluster_kube_config" "oke_cluster_kube_config" {
  cluster_id = var.create_new_oke_cluster ? oci_containerengine_cluster.oke_airflow_cluster[0].id : var.existing_oke_cluster_id
}