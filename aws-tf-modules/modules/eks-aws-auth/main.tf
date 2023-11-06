
resource "kubernetes_namespace" "rbac_namespace" {
  count = var.enable_default_rbac_roles
  metadata {
    name   = "epaas-rbac"
    labels = merge(var.k8s_namespace_labels, { name = "epaas-rbac" })
  }
}

resource "helm_release" "rbac" {
  count       = var.enable_default_rbac_roles
  name        = "rbac-roles"
  chart       = "${path.module}/charts/rbac-roles"
  namespace   = kubernetes_namespace.rbac_namespace[0].id
  max_history = 5
}

resource "kubernetes_config_map" "aws_auth" {

  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
    labels = {
      "app.kubernetes.io/managed-by" = "Terraform"
      "terraform.io/module"          = "eks-epaas"
    }
  }

  data = {
    mapRoles = yamlencode(
      distinct(concat(
        local.aws_auth_map_roles
      ))
    )
  }
}
