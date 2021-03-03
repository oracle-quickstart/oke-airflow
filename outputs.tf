
output "BASTION_IP" { value = module.bastion.public_ip }
output "SSH_KEY_INFO" { value = var.provide_ssh_key ? "SSH Key Provided by user" : "See below for generated SSH private key." }
output "SSH_PRIVATE_KEY" { value = var.provide_ssh_key ? "SSH Key Provided by user" : tls_private_key.ssh_key.private_key_pem }

