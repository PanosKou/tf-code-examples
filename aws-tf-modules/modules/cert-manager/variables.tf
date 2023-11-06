variable "chart_version" {
  type        = string
  description = "Cert Manager chart version"
  default     = "v1.0.4"
}

variable "helm_repo_url" {
  type        = string
  description = "Helm Repo url"
}

variable "namespace" {
  type        = string
  description = "Cert Manager Namespace"
  default     = "cert-manager"
}

variable "k8s_namespace_labels" {
  type        = map
  description = "K8S Namespace labels"
  default     = {}
}

variable "nbs_management_networking_ca_pem" {
  type        = string
  description = "Management Networking CA in PEM format"
}

variable "service_monitor_enabled" {
  type        = bool
  description = "Should service monitor be enabled? Only valid if prometheus is also enabled"
  default     = false
}

variable "vault_path" {
  description = "Path to pki vault role"
}

variable "vault_role" {
  description = "Vault role the k8s sa assumes"
}

variable "vault_mount_path" {
  description = "Path to valut role the k8s sa assumes"
}

variable "vault_backend_namespace" {
  description = "Namespace in vault backend"
}

variable "vault_addr" {
  description = "vault instance address"
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
