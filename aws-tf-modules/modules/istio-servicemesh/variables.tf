##istio-servicemesh variables
variable "chart_version" {
  type        = string
  description = "Istio Service Mesh Operator chart version"
  default     = "v1.7.4"
}

variable "namespace" {
  type        = string
  description = "Istio Service Mesh Components Namespace"
  default     = "istio-system"
}

variable "k8s_namespace_labels" {
  type        = map
  description = "K8S Namespace labels"
  default     = {}
}

variable "istio_operator_profile" {
  default     = "default"
  description = "Name of the istio-operator profile to install, set to null to skip profile installation"
}

variable "cluster_name" {
  type        = string
  description = "Name of the EKS cluster"
}

variable "container_registry" {
  type        = string
  description = "Artifactory repository for storing docker containers used by core components on the cluster"
}

variable "ingress_class" {
  type        = string
  description = "Ingress class to register monitoring ingress endpoints against"
}

variable "kiali_version" {
  type    = string
  default = "1.25.0"
}

variable "kiali_auth_method" {
  type    = string
  default = "token"
}

variable "feature_istio_kiali" {
  default     = 1
  description = "Feature flag to enable kiali deployment."
}

variable "private_hosted_zone" {
  description = "Route 53 DNS zone to register endpoints"
}
