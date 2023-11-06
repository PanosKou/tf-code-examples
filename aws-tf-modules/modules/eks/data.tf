data "aws_region" "current" {
}

data "aws_caller_identity" "current" {
}

data "aws_iam_role" "cluster_role" {
  name = var.cluster_role == "" ? "${var.account_name}-role-eks-cluster" : var.cluster_role
}

data "aws_iam_role" "node_role" {
  name = "${var.account_name}-role-eks-node"
}
