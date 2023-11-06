data "aws_region" "current" {
}

data "aws_caller_identity" "current" {
}

data "aws_ami" "eks-nodes" {
  for_each = local.worker_groups

  filter {
    name   = "name"
    values = lookup(each.value, "worker-version", null) == null ? ["nbs-lz-eksworker-*"] : ["nbs-lz-eksworker-${each.value.worker-version}-*"]
  }

  filter {
    name   = "tag:release-type"
    values = ["master"]
  }

  most_recent = true
  owners      = ["391635538753"]
}

data "aws_iam_role" "node-role" {
  name = "${var.account_name}-role-eks-node"
}

data "aws_iam_instance_profile" "node-profile" {
  name = "${var.account_name}-ip-eks-node"
}