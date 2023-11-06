variable "account_name" {
  type        = string
  description = "NBS Account Name"
}

variable "cluster_name" {
  type        = string
  description = "Name of the EKS cluster"
}

variable "helm_repo_url" {
  type        = string
  description = "Helm Repo url"
}

variable "chart_version" {
  type        = string
  description = "Helm chart version"
  default     = "9.3.0"
}

variable "psp_enabled" {
  type        = bool
  description = "Should PSPs be enabled in helm chart? Only valid if PSPs are enabled in cluster"
  default     = false
}

variable "container_registry" {
  type        = string
  description = "Artifactory repository for storing docker containers used by core components on the cluster"
}

variable "service_monitor_enabled" {
  type        = bool
  description = "Should service monitor be enabled? Only valid if prometheus is also enabled"
  default     = false
}