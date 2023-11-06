data "aws_vpc" "vpc" {
  filter {
    name   = "tag:Name"
    values = ["${var.account_name}-vpc"]
  }
}

data "aws_subnet_ids" "private_subnets" {
  vpc_id = data.aws_vpc.vpc.id

  filter {
    name   = "tag:Name"
    values = ["${var.account_name}-vpc-private*"]
  }
}

data "local_file" "nationwide_root_ca2_pem" {
  filename = "${path.module}/files/nationwide-root-ca2.pem"
}

data "local_file" "nbs_management_networking_ca_pem" {
  filename = "${path.module}/files/nbs-management-networking-ca.pem"
}