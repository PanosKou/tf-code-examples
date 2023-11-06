output "cluster_id" {
  value       = module.eks[0].cluster_id
  description = "The name/id of the EKS cluster."
}
