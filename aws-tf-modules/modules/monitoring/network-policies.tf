
# Egress to scrape all variety of resources  
resource "kubernetes_network_policy" "allow_egress" {
  metadata {
    name      = "allow-egress"
    namespace = kubernetes_namespace.monitoring_namespace.id
  }
  spec {
    pod_selector {}
    egress {}
    policy_types = ["Egress"]
  }
}

# Ingress for Prometheus Stack (Grafan,Prometheus,AlertManager Etc)
resource "kubernetes_network_policy" "allow_ingress" {
  metadata {
    name      = "allow-ingress"
    namespace = kubernetes_namespace.monitoring_namespace.id
  }
  spec {
    pod_selector {}
    ingress {
      ports {
        port     = "3000"
        protocol = "TCP"
      }
      ports {
        port     = "8080"
        protocol = "TCP"
      }
      ports {
        port     = "9090"
        protocol = "TCP"
      }
      ports {
        port     = "9093"
        protocol = "TCP"
      }
      ports {
        port     = "9100"
        protocol = "TCP"
      }
    }
    policy_types = ["Ingress"]
  }
}