variable "account_name" {
  type        = string
  description = "Account Name"
}

variable "central_vpn_cidr_blocks" {
  type        = list(string)
  default     = ["10.160.68.0/24", "10.160.69.0/24", "10.160.70.0/24"]
  description = "VPN cidr blocks to access eks"
}

variable "cluster_enabled_log_types" {
  default     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  description = "A list of the desired control plane logging to enable. For more information, see Amazon EKS Control Plane Logging documentation (https://docs.aws.amazon.com/eks/latest/userguide/control-plane-logs.html)"
  type        = list(string)
}

variable "cluster_log_kms_key_id" {
  default     = ""
  description = "If a KMS Key ARN is set, this key will be used to encrypt the corresponding log group. Please be sure that the KMS Key has an appropriate key policy (https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/encrypt-log-data-kms.html)"
  type        = string
}

variable "cluster_log_retention_in_days" {
  default     = 30
  description = "Number of days to retain log events. Default retention - 30 days."
  type        = number
}

variable "cluster_create_timeout" {
  description = "Timeout value when creating the EKS cluster."
  type        = string
  default     = "30m"
}

variable "cluster_delete_timeout" {
  description = "Timeout value when deleting the EKS cluster."
  type        = string
  default     = "15m"
}

variable "cluster_name" {
  type        = string
  description = "Name of the EKS cluster to be created"
}

variable "cluster_role" {
  type        = string
  default     = ""
  description = "Custom IAM role to be used by EKS cluster..if not provided..{var.account_name}-role-eks-cluster will be used"
}

variable "cluster_sg" {
  type        = string
  default     = ""
  description = "Custom SG role to be used by EKS cluster..if not provided ..{var.account_name}-role-eks-cluster will be used"
}

variable "cluster_version" {
  description = "Kubernetes version to use for the EKS cluster."
  type        = string
  default     = "1.18"
}


variable "provisioning_account_cidr" {
  type        = list(string)
  default     = ["10.160.52.0/24", "10.160.53.0/24", "10.160.54.0/24"]
  description = "CIDR blocks to access the cluster from provisioning account"
}

variable "subnet_ids" {
  type        = list(string)
  description = "Subnets ids for worker nodes"
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

variable "vpc_cidrs" {
  type        = list(string)
  description = "VPC CIDR"
}

variable "cluster_encryption_key_arn" {
  type        = string
  description = "KMS Key ARN to be used for secret encryption within the cluster"
}
