variable "account_name" {
  type        = string
  description = "Account Name"
}

variable "central_vpn_cidr_blocks" {
  type        = list(string)
  description = "VPN cidr blocks to access eks"
}

variable "cluster_ca_b64" {
  type        = string
  description = "Base64 encoded version of cluster CA"
}

variable "cluster_endpoint" {
  type        = string
  description = "Endpoint URL of the EKS cluster to be created"
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

variable "cluster_version" {
  type        = string
  description = "Version of the EKS cluster that was created"
}

variable "root_ca2_pem" {
  type        = string
  description = "Root CA2 in PEM format"
}

variable "nbs_management_networking_ca_pem" {
  type        = string
  description = "Management Networking CA in PEM format"
}

variable "ssh_public_key" {
  type        = string
  default     = ""
  description = "SSH Pubkey to for ssh access to worker nodes.. if not specified key named {var.cluster-name}-eks-workers will be created and its details are stored in secrets manager"
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnet ids for worker placement"
  default     = []
  validation {
    condition     = length(var.subnet_ids) > 0
    error_message = "You must supply a list of subnets."
  }
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags for the all the resources created in the module"
}

variable "tf_role" {
  default     = "app-creator"
  description = "Role used by terraform for null_resources"
}

variable "vpc_id" {
  type        = string
  description = "ID of the VPC where the cluster would be created"
}

variable "worker_groups" {
  type        = any
  description = "List of worker groups with each its own ASG and config"
}
