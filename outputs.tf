output "BASTION_IP" { value = module.bastion.public_ip }
output "SSH_KEY_INFO" { value = "See below for generated SSH private key used for remote-exec." }
output "SSH_PRIVATE_KEY" { value = tls_private_key.oke_ssh_key.private_key_pem }
