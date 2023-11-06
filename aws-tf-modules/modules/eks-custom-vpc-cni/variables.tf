variable "account_name" {
  type        = string
  description = "NBS Account Name"
}

variable "aws_node_config" {
  default = {
    AWS_VPC_K8S_CNI_CUSTOM_NETWORK_CFG = "true",
    ENI_CONFIG_LABEL_DEF               = "failure-domain.beta.kubernetes.io/zone"
  }
  description = "Set configuration values on aws_node daemonset. See https://docs.aws.amazon.com/eks/latest/userguide/cni-env-vars.html for options"
}

variable "cluster_name" {
  type        = string
  description = "Name of the EKS cluster to be created"
}

variable "cluster_security_group_id" {
  description = "Security Group assigned to the cluster."
}

variable "worker_security_group_id" {
  description = "Security Group assigned to the workers."
}

variable "tf_role" {
  default     = "app-creator"
  description = "Role used by terraform for null_resources"
}

variable "vpc_id" {
  type        = string
  description = "ID of the VPC where the cluster would be created"
}
