output "vcn-id" {
	value = var.useExistingVcn ? var.myVcn : oci_core_vcn.airflow_vcn.0.id
}

output "private-id" {
	value = var.useExistingVcn ? var.OKESubnet : oci_core_subnet.private.0.id
}

output "edge-id" {
        value = var.useExistingVcn ? var.edgeSubnet : oci_core_subnet.edge.0.id
}
