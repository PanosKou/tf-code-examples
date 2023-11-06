output "secret_manager_private_key_name" {
  value       = local.secret_manager_private_key_name
  description = "SSH private key secret name in aws secret manager"
}

output "secret_manager_public_key_name" {
  value       = local.secret_manager_public_key_name
  description = "SSH public key secret name in aws secret manager"
}

# output "worker_security_group_id" {
#   value       = aws_security_group.node.id
#   description = "workers security group id"
# }