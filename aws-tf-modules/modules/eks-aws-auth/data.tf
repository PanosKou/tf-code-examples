data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_iam_role" "node_role" {
  name = "${var.account_name}-role-eks-node"
}