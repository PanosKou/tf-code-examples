# Egress to communicate with AWS APIs
resource "kubernetes_network_policy" "allow_egress_externaldns" {
  metadata {
    name      = "allow-egress-externaldns"
    namespace = kubernetes_namespace.external_dns_namespace.id
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
        "app.kubernetes.io/instance" = "external-dns"
      }
    }
  }
}

resource "kubernetes_network_policy" "allow_prometheus_scraper_external_dns" {
  metadata {
    name      = "allow-prometheus-ingress"
    namespace = kubernetes_namespace.external_dns_namespace.id
  }
  spec {
    ingress {
      ports {
        port     = 7979
        protocol = "TCP"
      }
      from {
        namespace_selector {}
        pod_selector {
          match_labels = {
            app = "prometheus"
          }
        }
      }
    }
    policy_types = ["Ingress"]
    pod_selector {
      match_labels = {
        "app.kubernetes.io/instance" = "external-dns"
      }
    }
  }
}
