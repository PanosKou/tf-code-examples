
data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_iam_policy" "custom-boundary" {
  arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/${var.account_name}-policy-custom-role-boundary"
}

data "aws_eks_cluster" "cluster" {
  name = var.cluster_name
}

locals {
  cluster_id = regex("([^/]+)?$", data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer)
}

data "aws_iam_policy_document" "policy" {
  statement {
    sid    = "Allowautoscaler"
    effect = "Allow"
    actions = ["autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeAutoScalingInstances",
      "autoscaling:DescribeLaunchConfigurations",
      "autoscaling:DescribeTags",
      "autoscaling:SetDesiredCapacity",
      "autoscaling:TerminateInstanceInAutoScalingGroup"
    ]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "trust_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "oidc.eks.${data.aws_region.current.name}.amazonaws.com/id/${local.cluster_id[0]}:sub"
      values   = ["system:serviceaccount:kube-system:cluster-autoscaler-aws-cluster-autoscaler"]
    }

    principals {
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/oidc.eks.${data.aws_region.current.name}.amazonaws.com/id/${local.cluster_id[0]}"]
      type        = "Federated"
    }
  }
}

data "template_file" "values" {
  template = file("${path.module}/files/values.yaml")
  vars = {
    region                  = data.aws_region.current.name
    cluster_name            = var.cluster_name
    service_monitor_enabled = var.service_monitor_enabled
    psp_enabled             = var.psp_enabled
    container_registry      = var.container_registry
    role_arn                = aws_iam_role.role.arn
  }
}