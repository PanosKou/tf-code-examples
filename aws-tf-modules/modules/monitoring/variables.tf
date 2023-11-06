variable "cluster_name" {
  type        = string
  description = "Name of the EKS cluster"
}

variable "monitoring_namespace" {
  type        = string
  description = "namespace for monitoring components"
  default     = "monitoring"
}

variable "k8s_namespace_labels" {
  type        = map
  description = "K8S Namespace labels"
  default     = {}
}

variable "private_hosted_zone" {
  description = "Route 53 DNS zone to register endpoints"
}

variable "prometheus_chart_version" {
  type        = string
  description = "Helm chart version for vault"
  default     = "10.3.4"
}

variable "helm_repo_url" {
  type        = string
  description = "Helm Repo url"
}

variable "container_registry" {
  type        = string
  description = "Artifactory repository for storing docker containers used by core components on the cluster"
}

variable "ingress_class" {
  type        = string
  description = "Ingress class to register monitoring ingress endpoints against"
}

variable "psp_enabled" {
  type        = bool
  description = "Should PSPs be enabled in prometheus operator helm chart? Only valid if PSPs are enabled in cluster"
  default     = false
}
