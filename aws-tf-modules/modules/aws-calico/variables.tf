
variable "helm_repo_url" {
  type        = string
  description = "Helm Repo url"
}

variable "chart_version" {
  type        = string
  description = "Helm chart version"
  default     = "0.3.4"
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