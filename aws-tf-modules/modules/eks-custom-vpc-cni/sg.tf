locals {
  tertiary_subnet_cidr = [for subnet_key, subnet in data.aws_subnet.tertiary_subnets : subnet.cidr_block]
}

resource "aws_security_group_rule" "cluster_ingress_intra_subnet_https" {
  description       = "Allow secondary subnet to communicate with the cluster API Server"
  from_port         = 443
  protocol          = "tcp"
  security_group_id = var.worker_security_group_id
  cidr_blocks       = local.tertiary_cidrs
  to_port           = 443
  type              = "ingress"
}