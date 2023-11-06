resource "helm_release" "psp" {
  name        = "psp"
  chart       = "${path.module}/charts/psp"
  namespace   = "kube-system"
  max_history = 5
}

resource "null_resource" "remove_default_psp_privileged" {

  triggers = {
    cluster_version = var.cluster_version
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

    kubectl delete psp eks.privileged || true
    kubectl delete clusterrole eks:podsecuritypolicy:privileged || true
    kubectl delete clusterrolebindings eks:podsecuritypolicy:authenticated || true
EOF
  }
}