variable "container_registry" {
  type        = string
  description = "Artifactory repository for storing docker containers used by core components on the cluster"
}

variable "helm_repo_url" {
  type        = string
  description = "Helm Repo url"
}