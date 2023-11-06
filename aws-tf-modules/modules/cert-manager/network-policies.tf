# Egress to Kube API and Vault endpoints
resource "kubernetes_network_policy" "allow_egress_cert_manager" {
  metadata {
    name      = "allow-egress-cert-manager"
    namespace = kubernetes_namespace.cert_manager_namespace.id
  }
  spec {
    egress {
      ports {
        port     = 443
        protocol = "TCP"
      }
    }
    policy_types = ["Egress"]
    pod_selector {
      match_labels = {
        "app.kubernetes.io/instance" = "cert-manager"
      }
    }
  }
}

# Ingress to webhook from Kube API
resource "kubernetes_network_policy" "allow_ingress_webhook" {
  metadata {
    name      = "allow-ingress-webhook"
    namespace = kubernetes_namespace.cert_manager_namespace.id
  }
  spec {
    pod_selector {
      match_labels = {
        "app.kubernetes.io/component" = "webhook"
      }
    }
    ingress {
      ports {
        port     = "10250"
        protocol = "TCP"
      }
    }
    policy_types = ["Ingress"]
  }
}

# Ingress to monitor cert-manager 
resource "kubernetes_network_policy" "allow_ingress_monitoring" {
  metadata {
    name      = "allow-ingress-monitoring"
    namespace = kubernetes_namespace.cert_manager_namespace.id
  }
  spec {
    pod_selector {}
    ingress {
      ports {
        port     = "9402"
        protocol = "TCP"
      }
    }
    policy_types = ["Ingress"]
  }
}