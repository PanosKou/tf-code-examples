variable "account_name" {
  type        = string
  description = "NBS Account Name"
}

variable "cluster_name" {
  type        = string
  description = "Name of the EKS cluster"
}

variable "k8s_namespace_labels" {
  type        = map
  description = "K8S Namespace labels"
  default     = {}
}

variable "enable_default_rbac_roles" {
  type        = number
  description = "Enable default rbac roles"
  default     = 1
  validation {
    condition     = var.enable_default_rbac_roles == 0 || var.enable_default_rbac_roles == 1
    error_message = "The enable_default_rbac_roles value must '0' or '1'."
  }
}

variable "custom_rbac_mappings" {
  description = "Additional IAM roles to be add to the aws-auth configmap."
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))
  default = []
}