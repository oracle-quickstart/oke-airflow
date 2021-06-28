output "BASTION_PUBLIC_IP" { value = var.public_edge_node ? module.bastion.public_ip : "No public IP assigned" }
output "INFO" { value = var.use_remote_exec ? "Remote Execution used for deployment, check output for SSH key to access bastion": "CloudInit on Bastion host drives Airflow deployment.  Login to Bastion host and check /var/log/OCI-airflow-initialize.log for status" }
output "SSH_PRIVATE_KEY" { value = var.use_remote_exec ? tls_private_key.oke_ssh_key.private_key_pem : "SSH Key provided by user" }
