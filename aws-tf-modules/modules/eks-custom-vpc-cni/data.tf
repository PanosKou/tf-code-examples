data "aws_region" "current" {
}

data "aws_caller_identity" "current" {
}

locals {
  subnet_names   = toset(["${var.account_name}-vpc-tertiary-1", "${var.account_name}-vpc-tertiary-2", "${var.account_name}-vpc-tertiary-3"])
  tertiary_ids   = [for subnet in data.aws_subnet.tertiary_subnets : subnet.id]
  tertiary_cidrs = [for subnet in data.aws_subnet.tertiary_subnets : subnet.cidr_block]
}

data "aws_subnet" "tertiary_subnets" {
  for_each = local.subnet_names
  tags = {
    Name = each.value
  }
  vpc_id = var.vpc_id
}
