variable "nginx_ingress_namespace" {
  type        = string
  description = "namespace for nginx ingress"
  default     = "ingress-nginx"
}

variable "k8s_namespace_labels" {
  type        = map
  description = "K8S Namespace labels"
  default     = {}
}

variable "helm_repo_url" {
  type        = string
  description = "Helm Repo url"
}

variable "ingress_chart_version" {
  type        = string
  description = "Helm chart version for vault"
  default     = "3.10.1"
}

variable "service_monitor_enabled" {
  type        = bool
  description = "Should service monitor be enabled? Only valid if prometheus is also enabled"
  default     = false
}

variable "psp_enabled" {
  type        = bool
  description = "Should PSPs be enabled in ingress-nginx helm chart? Only valid if PSPs are enabled in cluster"
  default     = false
}

variable "container_registry" {
  type        = string
  description = "Artifactory repository for storing docker containers used by core components on the cluster"
}

variable "ingress_class" {
  type        = string
  description = "Name of ingress class assigned to the ingress controller. Ingress objects will reference this using ingressClassName"
}