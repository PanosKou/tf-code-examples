resource "null_resource" "tertiary_subnet_tags" {
  triggers = {
    cluster-name        = var.cluster_name
    region              = data.aws_region.current.name
    role-arn            = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.tf_role}"
    tertiary-subnet-ids = join(" ", local.tertiary_ids)
  }

  provisioner "local-exec" {
    command = <<EOF
    set -x

    assumed_role_details=$(aws sts assume-role \
      --role-arn ${self.triggers.role-arn} \
      --role-session-name "TerraformAssumeRole-EKS-Tags" \
      --query "Credentials.[AccessKeyId,SecretAccessKey,SessionToken]" \
      --output text)

    # Null resources are ran within their own process, therefore safe to set these env vars
    AWS_ACCESS_KEY_ID=$(echo "$${assumed_role_details}" | cut -f1)
    AWS_SECRET_ACCESS_KEY=$(echo "$${assumed_role_details}" | cut -f2)
    AWS_SESSION_TOKEN=$(echo "$${assumed_role_details}" | cut -f3)
    export AWS_ACCESS_KEY_ID
    export AWS_SECRET_ACCESS_KEY
    export AWS_SESSION_TOKEN

    aws ec2 create-tags --region ${self.triggers.region} --resources ${self.triggers.tertiary-subnet-ids} --tags Key=kubernetes.io/cluster/${self.triggers.cluster-name},Value='shared'
EOF
  }

  provisioner "local-exec" {
    when    = destroy
    command = <<EOF
    set -x
    assumed_role_details=$(aws sts assume-role \
      --role-arn ${self.triggers.role-arn} \
      --role-session-name "TerraformAssumeRole-EKS-Tags" \
      --query "Credentials.[AccessKeyId,SecretAccessKey,SessionToken]" \
      --output text)

    # Null resources are ran within their own process, therefore safe to set these env vars
    AWS_ACCESS_KEY_ID=$(echo "$${assumed_role_details}" | cut -f1)
    AWS_SECRET_ACCESS_KEY=$(echo "$${assumed_role_details}" | cut -f2)
    AWS_SESSION_TOKEN=$(echo "$${assumed_role_details}" | cut -f3)
    export AWS_ACCESS_KEY_ID
    export AWS_SECRET_ACCESS_KEY
    export AWS_SESSION_TOKEN
    aws ec2 delete-tags --region ${self.triggers.region} --resources ${self.triggers.tertiary-subnet-ids} --tags Key=kubernetes.io/cluster/${self.triggers.cluster-name},Value='shared'
EOF
  }
}