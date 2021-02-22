# Required for the OCI Provider
export TF_VAR_tenancy_ocid="ocid1.tenancy.oc1..aaaaaaaaiyavtwbz4kyu7g7b6wglllccbflmjx2lzk5nwpbme44mv54xu7dq"
export TF_VAR_compartment_ocid="ocid1.compartment.oc1..aaaaaaaamqf5vin6ujhryxleibauw6fvpecfsyjsx2wll3bv6famvzx6tn6a"
export TF_VAR_user_ocid="ocid1.user.oc1..aaaaaaaa67xarept2vu32zy6cyhem4xea4v5yiijiolmpaitjg5hu5i7cmzq"
export TF_VAR_fingerprint=$(cat ~/.oci/oci_api_key.fingerprint)
export TF_VAR_private_key_path="~/.oci/oci_api_key.pem"
export TF_VAR_region="us-ashburn-1"

# Keys used to SSH to OCI VMs
export TF_VAR_ssh_public_key=$(cat ~/.ssh/oci.pub)
export TF_VAR_ssh_private_key=$(cat ~/.ssh/oci.pem)
