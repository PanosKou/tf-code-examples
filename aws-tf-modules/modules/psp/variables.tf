variable "cluster_name" {
  type        = string
  description = "Name of the EKS cluster that this module is being used in"
}

variable "cluster_version" {
  type        = string
  description = "Version of the EKS cluster that was created"
}

variable "tf_role" {
  type        = string
  description = "Role used by terraform for null_resources"
}