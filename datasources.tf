# Gets VCN ID
# Gets a list of Availability Domains
data "oci_identity_availability_domains" "ADs" {
  compartment_id = var.tenancy_ocid
}

# Gets kubeconfig
data "oci_containerengine_cluster_kube_config" "oke_cluster_kube_config" {
  cluster_id = var.create_new_oke_cluster ? oci_containerengine_cluster.oke_airflow_cluster[0].id : var.existing_oke_cluster_id
}


locals {
  # Helm repos
  helm_repository = {
    stable        = "https://kubernetes-charts.storage.googleapis.com"
    ingress-nginx = "https://kubernetes.github.io/ingress-nginx"
    jetstack      = "https://charts.jetstack.io"                        # cert-manager
    svc-cat       = "https://svc-catalog-charts.storage.googleapis.com" # Service Catalog
  }
}

### Kubernetes Service: airflow-utils-ingress-nginx-controller
#data "kubernetes_service" "airflow_ingress" {
#  metadata {
#    name      = "airflow-utils-ingress-nginx-controller" # airflow-utils name included to be backwards compatible to the docs and setup chart install
#    namespace = kubernetes_namespace.airflow_utilities_namespace.id
#  }
#  depends_on = [helm_release.ingress-nginx]
#}

# OCI Services
## Available Services
data "oci_core_services" "all_services" {
  filter {
    name   = "name"
    values = ["All .* Services In Oracle Services Network"]
    regex  = true
  }
}

## Object Storage
data "oci_objectstorage_namespace" "ns" {
  compartment_id = var.compartment_ocid
}

# Randoms
resource "random_string" "deploy_id" {
  length  = 4
  special = false
}

data "null_data_source" "subnet" {
  inputs = {
    edge = var.useExistingVcn ? var.edgeSubnet :  module.network.edge-id 
  }
}
