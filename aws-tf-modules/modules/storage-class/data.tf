data "aws_region" "current" {
}

data "aws_caller_identity" "current" {
}

data "aws_kms_key" "cluster_encryption_key" {
  key_id = var.cluster_encryption_key_arn
}