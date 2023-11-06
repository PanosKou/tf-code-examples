locals {
  eniconfig_values = {
    availabilityZones : [
      for subnet_key, subnet in data.aws_subnet.tertiary_subnets : {
        name : subnet.availability_zone
        id : subnet.id
      }
    ]
    eksPodSecurityGroup : var.worker_security_group_id
  }
}

resource "helm_release" "vpc_cni_eniconfig" {
  name        = "vpc-cni-eniconfig"
  chart       = "${path.module}/charts/vpc-cni-eniconfig"
  values      = [yamlencode(local.eniconfig_values)]
  namespace   = "kube-system"
  max_history = 5
}

resource "null_resource" "set_aws_node_config" {
  for_each = var.aws_node_config

  triggers = {
    aws_node_config = jsonencode(var.aws_node_config)
  }

  provisioner "local-exec" {
    command = <<EOF
    set -x
    assumed_role_details=$(aws sts assume-role \
      --role-arn "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.tf_role}" \
      --role-session-name "TerraformAssumeRole-Apply-Config" \
      --query "Credentials.[AccessKeyId,SecretAccessKey,SessionToken]" \
      --output text)

    # Null resources are ran within their own process, therefore safe to set these env vars
    AWS_ACCESS_KEY_ID=$(echo "$${assumed_role_details}" | cut -f1)
    AWS_SECRET_ACCESS_KEY=$(echo "$${assumed_role_details}" | cut -f2)
    AWS_SESSION_TOKEN=$(echo "$${assumed_role_details}" | cut -f3)
    export AWS_ACCESS_KEY_ID
    export AWS_SECRET_ACCESS_KEY
    export AWS_SESSION_TOKEN

    # Apply kube config through this method needs aws and kubectl as part of docker image.
    aws eks update-kubeconfig --name ${var.cluster_name} --region ${data.aws_region.current.name}

    kubectl set env daemonset aws-node -n kube-system ${each.key}=${each.value}
EOF
  }
}
