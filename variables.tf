# ---------------------------------------------------------------------------------------------------------------------
# AD Settings. By default uses AD1 
# ---------------------------------------------------------------------------------------------------------------------
variable "availability_domain" {
  default = "1"
}

# ---------------------------------------------------------------------------------------------------------------------
# SSH Keys - Put this to top level because they are required
# ---------------------------------------------------------------------------------------------------------------------

# Create a new or use an existing SSK key
variable "provide_ssh_key" {
  default = "false"
}

# Path to existing private and public SSH key files. Leave both blank if you want TF to generate a new key

variable "ssh_provided_private_key" {
  default = ""
}
variable "ssh_provided_public_key" {
  default = ""
}


# ---------------------------------------------------------------------------------------------------------------------
# Network Settings
# --------------------------------------------------------------------------------------------------------------------- 

# If you want to use an existing VCN set useExistingVcn = "true" and configure OCID(s) of myVcn, privateSubnet and edgeSubnet

variable "useExistingVcn" {
  default = "false"
}

variable "myVcn" {
  default = " "
}
variable "privateSubnet" {
  default = " "
}
variable "edgeSubnet" {
  default = " "
}

# If useExistingVcn = "false" (default) terraform will create a new VCN. Set VCN and subnets paramameters below

variable "network_params" {
  type = map(string)
  default = {
    VCN_CIDR = "10.0.0.0/16"
    edge_cidr = "10.0.1.0/24"
    private_cidr = "10.0.2.0/24"
    vcn_dns_label  = "airflowvcn"
    service_port = "8080"
  }
}


# ---------------------------------------------------------------------------------------------------------------------
# OKE Settings
# ---------------------------------------------------------------------------------------------------------------------

variable "create_new_oke_cluster" {
  default = "true"
}


variable "existing_oke_cluster_id" {
  default = " "
}

variable "oke_params" {
  type = map(string)
  default = {
    cluster_name = "airflow-cluster"
    kubernetes_version  = "v1.18.10"
    airflow_node_pool_name = "Airflow-Node-Pool"
    airflow_node_pool_shape = "VM.Standard2.2"
    airflow_node_pool_size = 1
    airflow_namespace = "airflow"
    kube_label = "airflow"
    cluster_options_add_ons_is_kubernetes_dashboard_enabled = false
    cluster_options_admission_controller_options_is_pod_security_policy_enabled = "false"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# OCI registry settings
# ---------------------------------------------------------------------------------------------------------------------

variable "registry_params" {
  type = map(string)
  default = {
    registry = "iad.ocir.io"
    repo_name = "airflow"
    username  = "<enter OCI user account>"
    image_name = "airflow"
    image_label = "2.0"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# OCI vault secret ID where authentication key is stored 
# it is used for authenticatoin when pushing/pulling images to/from OCIR registry )
# ---------------------------------------------------------------------------------------------------------------------
variable "vault_secret_id" {
  default = "<enter vault secret ocid>"
}


# ---------------------------------------------------------------------------------------------------------------------
# DB settings
# ---------------------------------------------------------------------------------------------------------------------

variable "meta_db_type" {
  default = "OCI Mysql"
}

variable "mysql_params" {
  type = map(string)
  default = {
    admin_username = "mysqladmin"
    admin_password  = "A@flow1234"
    shape = "VM.Standard.E2.2"
    enable_backups = false
    private_ip_address = ""
    db_name = "airflow"
    airflow_username = "airflow"
    airflow_password = "A@flow1234"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# Bastion VM Settings
# ---------------------------------------------------------------------------------------------------------------------

variable "bastion_params" {
  type = map(string)
  default = {
    name = "bastion"
    shape  = "VM.Standard2.1"
  }
}


# ---------------------------------------------------------------------------------------------------------------------
# Environmental variables
# You probably want to define these as environmental variables.
# Instructions on that are here: https://github.com/oracle/oci-quickstart-prerequisites
# ---------------------------------------------------------------------------------------------------------------------

variable "compartment_ocid" {}

# Required by the OCI Provider

variable "tenancy_ocid" {}
variable "region" {}



// See https://docs.oracle.com/en-us/iaas/images/image/3318ef81-3970-4d69-92bc-e91392f87a13/
// Oracle-provided image "Oracle-Linux-7.9-2020.11.10-1"
// Kernel Version: 5.4.17-2036.100.6.1.el7uek.x86_64
// Release Date: Nov. 13, 2020
variable "OELImageOCID" {
  type = map
  default = {
    ap-chuncheon-1 = "ocid1.image.oc1.ap-chuncheon-1.aaaaaaaaelfp7gtaodq3w6sq3s3dqwtgr7b2ofo6z5tkh6nsp6622xopmeja"
    ap-hyderabad-1 = "ocid1.image.oc1.ap-hyderabad-1.aaaaaaaav7gmok247t2jngmtyahgcktphcj5gin7bpyc2fjg3bzho47ws7ea"
    ap-melbourne-1 = "ocid1.image.oc1.ap-melbourne-1.aaaaaaaausio3ssmcxawnqwzyolpbvakwt7jsdps7o4edzxhs4gol5kd2d4a"
    ap-mumbai-1 = "ocid1.image.oc1.ap-mumbai-1.aaaaaaaazw753qijtnuynq6wrd3rmiayquc3kpijc7j5akprmvyzhcdhxsxq"
    ap-osaka-1 = "ocid1.image.oc1.ap-osaka-1.aaaaaaaahfv5tiogcrhesqedn7bfp2bm65eszn47bv6fgsepenscf2bz4bga"
    ap-seoul-1 = "ocid1.image.oc1.ap-seoul-1.aaaaaaaa5df7nz7fgtiqfbnx2fyefgsqvr5z7me4g2snwwmhgiwxgs5iozsq"
    ap-sydney-1 = "ocid1.image.oc1.ap-sydney-1.aaaaaaaa47h6zbuz3glgprnlftbzaq47b2egblcqzllshzjvotfgj7oyfnya"
    ap-tokyo-1 = "ocid1.image.oc1.ap-tokyo-1.aaaaaaaazgoy6klsxzbi5jh5kx2qwxw6l6mqtlbo4c4kak4zes7zwytd4z2q"
    ca-montreal-1 = "ocid1.image.oc1.ca-montreal-1.aaaaaaaaom7gj5nbeedakcg5ivoli2t6634o3ymyyf3sdikatskfwt4bfzja"
    ca-toronto-1 = "ocid1.image.oc1.ca-toronto-1.aaaaaaaadsv6are52igmc63fe7xkdtj22uqqzibkps6ukhupac6dwuiqby4a"
    eu-amsterdam-1 = "ocid1.image.oc1.eu-amsterdam-1.aaaaaaaahxjr3fbnv62kt5pvsblj5u7t3tfoa5bga4rv6nbapafen4ft4bua"
    eu-frankfurt-1 = "ocid1.image.oc1.eu-frankfurt-1.aaaaaaaaf6gm7xvn7rhll36kwlotl4chm25ykgsje7zt2b4w6gae4yqfdfwa"
    eu-zurich-1 = "ocid1.image.oc1.eu-zurich-1.aaaaaaaaddo5ksklg5ctvwhkncxv675ah3a5n7r7hti234ty46jt7o4i5owq"
    me-dubai-1 = "ocid1.image.oc1.me-dubai-1.aaaaaaaapjwkms5kb637ddq7ew5tjflxtgyyxted2zvzn7klnid77mjtiowa"
    me-jeddah-1 = "ocid1.image.oc1.me-jeddah-1.aaaaaaaamaasqxfymhi3ppcqn4onqjiu7wpz4gjbeem4ww3mtfq3zflruzya"
    sa-saopaulo-1 = "ocid1.image.oc1.sa-saopaulo-1.aaaaaaaa7inha53kcyutiqdbz3w4gvms2ab5z3bc624loheugh7fbvg4wada"
    uk-cardiff-1 = "ocid1.image.oc1.uk-cardiff-1.aaaaaaaakiyy4e47557phn4cymjgmaauodty7imys47vrzvdzyhci4stgm7q"
    uk-london-1 = "ocid1.image.oc1.uk-london-1.aaaaaaaai2rckqhxpvhjb6vtxdgzga3nomcqb3rl54o7wdotnof2qm2ek55a"
    us-ashburn-1 = "ocid1.image.oc1.iad.aaaaaaaaf2wxqc6ee5axabpbandk6ji27oyxyicatqw5iwkrk76kecqrrdyq"
    us-gov-ashburn-1 = "ocid1.image.oc3.us-gov-ashburn-1.aaaaaaaadqzao57flqwkih4uoocghkgwp7qelrgj5vyih4ptuuah3alkgsta"
    us-gov-chicago-1 = "ocid1.image.oc3.us-gov-chicago-1.aaaaaaaanploag6l4h653ct2r4xvqn2xwfntsjuzhmypbqpqqfuyf43qo2va"
    us-gov-phoenix-1 = "ocid1.image.oc3.us-gov-phoenix-1.aaaaaaaablheqkh4k2mo4l5wfnpg2t5zuokmgai5cex6kell4epiio5yi6lq"
    us-langley-1 = "ocid1.image.oc2.us-langley-1.aaaaaaaan444pc2rvauh4xsi47g3bffub5ow4o7uz72yxc7sb5dbobrg4yia"
    us-luke-1 = "ocid1.image.oc2.us-luke-1.aaaaaaaa7sffhf7uouur6t6amby4nuntt3r76f3z4i4jg3z6dm7m5oe4n4xq"
    us-phoenix-1 = "ocid1.image.oc1.phx.aaaaaaaaxdnx3den32vwplngpeu44zakw7lxup7vcdd3jmke4pfleaug3m6q"
    us-sanjose-1 = "ocid1.image.oc1.us-sanjose-1.aaaaaaaaunhdpihc57bc6dzipgwvhr2ouoxw65tgabx6pwgmk5qqpjtzm5oq"
  }
}
