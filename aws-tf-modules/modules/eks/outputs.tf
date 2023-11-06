output "kubeconfig" {
  value       = local.kubeconfig
  description = "kubeconfig"
}

output "cluster_id" {
  value       = aws_eks_cluster.cluster.id
  description = "The name/id of the EKS cluster."
}

output "cluster_security_group_id" {
  value       = aws_security_group.cluster.id
  description = "cluster security group id"
}

output "worker_security_group_id" {
  value       = aws_security_group.node.id
  description = "cluster security group id"
}

output "cluster_ca_b64" {
  value       = aws_eks_cluster.cluster.certificate_authority.0.data
  description = "Base64 encoded version of cluster CA"
}

output "cluster_endpoint" {
  value       = aws_eks_cluster.cluster.endpoint
  description = "Endpoint URL of the EKS cluster to be created"
}

output "cluster_version" {
  value       = aws_eks_cluster.cluster.version
  description = "Version of the EKS cluster that was created"
}
