#!/bin/bash
# sudo curl -L -O https://raw.githubusercontent.com/oracle/oci-cli/master/scripts/install/install.sh && sudo chmod a+x install.sh && sudo ./install.sh --accept-all-defaults
curl -L -O https://raw.githubusercontent.com/oracle/oci-cli/master/scripts/install/install.sh && chmod a+x install.sh && ./install.sh --accept-all-defaults

echo "export OCI_CLI_AUTH=instance_principal" >> ~/.bash_profile
echo "export OCI_CLI_AUTH=instance_principal" >> ~/.bashrc