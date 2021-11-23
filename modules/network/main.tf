resource "oci_core_vcn" "airflow_vcn" {
  count = var.useExistingVcn ? 0 : 1
  cidr_block     = var.VCN_CIDR
  compartment_id = var.compartment_ocid
  display_name   = "OKE Airflow VCN - ${random_string.deploy_id.result}" 
  dns_label      = var.vcn_dns_label
}

resource "oci_core_internet_gateway" "airflow_internet_gateway" {
  count = var.useExistingVcn ? 0 : 1
  compartment_id = var.compartment_ocid
  display_name   = "airflow_internet_gateway"
  vcn_id         = var.useExistingVcn ? var.custom_vcn[0] : oci_core_vcn.airflow_vcn.0.id
}

resource "oci_core_nat_gateway" "nat_gateway" {
  count = var.useExistingVcn ? 0 : 1
  compartment_id = var.compartment_ocid
  vcn_id         = var.useExistingVcn ? var.custom_vcn[0] : oci_core_vcn.airflow_vcn.0.id
  display_name   = "nat_gateway"
}

resource "oci_core_service_gateway" "airflow_service_gateway" {
  count = var.useExistingVcn ? 0 : 1
  compartment_id = var.compartment_ocid
  services {
  service_id = data.oci_core_services.net_services.services[0]["id"]
  }
  vcn_id = var.useExistingVcn ? var.custom_vcn[0] : oci_core_vcn.airflow_vcn.0.id
  display_name = "Airflow Service Gateway"
}

resource "oci_core_route_table" "RouteForComplete" {
  count = var.useExistingVcn ? 0 : 1
  compartment_id = var.compartment_ocid
  vcn_id         = var.useExistingVcn ? var.custom_vcn[0] : oci_core_vcn.airflow_vcn.0.id
  display_name   = "RouteTableForComplete"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.airflow_internet_gateway.*.id[count.index]
  }
}

resource "oci_core_route_table" "private" {
  count = var.useExistingVcn ? 0 : 1
  compartment_id = var.compartment_ocid
  vcn_id         = var.useExistingVcn ? var.custom_vcn[0] : oci_core_vcn.airflow_vcn.0.id
  display_name   = "private"

  route_rules {
#      destination       = var.oci_service_gateway
      destination       = data.oci_core_services.net_services.services[0]["cidr_block"]
      destination_type  = "SERVICE_CIDR_BLOCK"
      network_entity_id = oci_core_service_gateway.airflow_service_gateway.*.id[count.index]
    }
  
  route_rules {
      destination       = "0.0.0.0/0"
      destination_type  = "CIDR_BLOCK"
      network_entity_id = oci_core_nat_gateway.nat_gateway.*.id[count.index]
    }
}

resource "oci_core_security_list" "EdgeSubnet" {
  count = var.useExistingVcn ? 0 : 1
  compartment_id = var.compartment_ocid
  display_name   = "Edge Subnet"
  vcn_id         = var.useExistingVcn ? var.custom_vcn[0] : oci_core_vcn.airflow_vcn.0.id

  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
  }

  ingress_security_rules {
    tcp_options {
      max = 22
      min = 22
    }

    protocol = "6"
    source   = "0.0.0.0/0"
  }
  
  ingress_security_rules {
    tcp_options {
      max = var.service_port
      min = var.service_port
    }

    protocol = "6"
    source   = "0.0.0.0/0"
  }

  ingress_security_rules {
    protocol = "all"
    source   = var.VCN_CIDR
  }
}

resource "oci_core_security_list" "PrivateSubnet" {
  count = var.useExistingVcn ? 0 : 1
  compartment_id = var.compartment_ocid
  display_name   = "Private"
  vcn_id         = var.useExistingVcn ? var.custom_vcn[0] : oci_core_vcn.airflow_vcn.0.id

  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
  }
#  egress_security_rules {
#    protocol    = "6"
#    destination = var.VCN_CIDR
#  }

  ingress_security_rules {
    protocol = "all"
    source   = var.VCN_CIDR
  }
}

resource "oci_core_subnet" "edge" {
  count = var.useExistingVcn ? 0 : 1
  cidr_block          = var.edge_cidr
  display_name        = "edge"
  compartment_id      = var.compartment_ocid
  vcn_id              = var.useExistingVcn ? var.custom_vcn[0] : oci_core_vcn.airflow_vcn.0.id
  route_table_id      = oci_core_route_table.RouteForComplete[count.index].id
  security_list_ids   = [oci_core_security_list.EdgeSubnet.*.id[count.index]]
  dhcp_options_id     = oci_core_vcn.airflow_vcn[count.index].default_dhcp_options_id
  dns_label           = "edge"
}

resource "oci_core_subnet" "private" {
  count = var.useExistingVcn ? 0 : 1
  cidr_block          = var.private_cidr
  display_name        = "private"
  compartment_id      = var.compartment_ocid
  vcn_id              = var.useExistingVcn ? var.custom_vcn[0] : oci_core_vcn.airflow_vcn.0.id
  route_table_id      = oci_core_route_table.private[count.index].id
  security_list_ids   = [oci_core_security_list.PrivateSubnet.*.id[count.index]]
  dhcp_options_id     = oci_core_vcn.airflow_vcn[count.index].default_dhcp_options_id
  prohibit_public_ip_on_vnic = "true"
  dns_label = "private"
}
