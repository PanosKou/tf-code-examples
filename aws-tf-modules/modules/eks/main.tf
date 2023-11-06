resource "aws_cloudwatch_log_group" "cluster_cwlg" {
  count             = length(var.cluster_enabled_log_types) > 0 ? 1 : 0
  name              = "/aws/eks/${var.cluster_name}/cluster"
  retention_in_days = var.cluster_log_retention_in_days
  kms_key_id        = var.cluster_log_kms_key_id
  tags              = var.tags
}

resource "aws_eks_cluster" "cluster" {
  name                      = var.cluster_name
  enabled_cluster_log_types = var.cluster_enabled_log_types #checkov:skip=CKV_AWS_37:Logs enabled check not working correctly
  role_arn                  = data.aws_iam_role.cluster_role.arn
  version                   = var.cluster_version
  tags                      = var.tags

  timeouts {
    create = var.cluster_create_timeout
    delete = var.cluster_delete_timeout
  }

  vpc_config {
    security_group_ids      = [aws_security_group.cluster.id]
    subnet_ids              = var.subnet_ids
    endpoint_private_access = true
    endpoint_public_access  = false
  }

  encryption_config {
    provider {
      key_arn = var.cluster_encryption_key_arn
    }
    resources = ["secrets"]
  }

  depends_on = [aws_cloudwatch_log_group.cluster_cwlg]
}

resource "null_resource" "eks_cluster_disable_logging" {
  triggers = {
    cluster_enabled_log_types = jsonencode(var.cluster_enabled_log_types)
    cluster_name              = var.cluster_name
    region                    = data.aws_region.current.name
    role_arn                  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.tf_role}"
  }

  provisioner "local-exec" {
    when    = destroy
    command = <<EOF
    set -x
    assumed_role_details=$(aws sts assume-role \
      --role-arn ${self.triggers.role_arn} \
      --role-session-name "TerraformAssumeRole-EKS-Logging" \
      --query "Credentials.[AccessKeyId,SecretAccessKey,SessionToken]" \
      --output text)

    # Null resources are ran within their own process, therefore safe to set these env vars
    AWS_ACCESS_KEY_ID=$(echo "$${assumed_role_details}" | cut -f1)
    AWS_SECRET_ACCESS_KEY=$(echo "$${assumed_role_details}" | cut -f2)
    AWS_SESSION_TOKEN=$(echo "$${assumed_role_details}" | cut -f3)
    export AWS_ACCESS_KEY_ID
    export AWS_SECRET_ACCESS_KEY
    export AWS_SESSION_TOKEN
    aws eks update-cluster-config --region ${self.triggers.region} --name ${self.triggers.cluster_name} --logging '{"clusterLogging":[{"types": ${self.triggers.cluster_enabled_log_types}, "enabled":false}]}'
EOF
  }

  depends_on = [aws_eks_cluster.cluster]
}
