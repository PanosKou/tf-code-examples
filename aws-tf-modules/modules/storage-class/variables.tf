variable "cluster_encryption_key_arn" {
  description = "The full Amazon Resource Name of the key to use when encrypting the volume"
  type        = string
}

variable "cluster_name" {
  type        = string
  description = "Name of the EKS cluster that this module is being used in"
}

variable "reclaim_policy" {
  description = "Reclaim policy of the storage class. Defaults to Delete as per kubernetes storage class default"
  type        = string
  default     = "Delete"
}

variable "tf_role" {
  default     = "app-creator"
  description = "Role used by terraform for null_resources"
}