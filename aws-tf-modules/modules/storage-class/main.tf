resource "kubernetes_storage_class" "sc" {
  metadata {
    annotations = {
      "storageclass.kubernetes.io/is-default-class" = "true"
    }
    name = "gp3-encrypted"
  }
  storage_provisioner = "kubernetes.io/aws-ebs"
  reclaim_policy      = var.reclaim_policy
  parameters = {
    encrypted = "true"
    type      = "gp3"
    kmsKeyId  = data.aws_kms_key.cluster_encryption_key.key_id
  }
}

resource "null_resource" "remove_default_eks_sc" {

  triggers = {
    cluster_name = var.cluster_name
    region       = data.aws_region.current.name
    role_arn     = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.tf_role}"
  }

  provisioner "local-exec" {
    command = <<EOF
    set -x
    assumed_role_details=$(aws sts assume-role \
      --role-arn "${self.triggers.role_arn}" \
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
    aws eks update-kubeconfig --name ${self.triggers.cluster_name} --region ${self.triggers.region}

    kubectl patch storageclass gp2 -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}' || true
EOF
  }

  depends_on = [kubernetes_storage_class.sc] # Only unset default storage class when new one provided
}