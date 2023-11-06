# Egress to communicate with AWS APIs
resource "kubernetes_network_policy" "allow_egress_autoscaler" {
  metadata {
    name      = "allow-egress-autoscaler"
    namespace = "kube-system"
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
        "app.kubernetes.io/instance" = "cluster-autoscaler"
      }
    }
  }
}

resource "kubernetes_network_policy" "allow_prometheus_scraper_cluster_autoscaler" {
  metadata {
    name      = "allow-prometheus-ingress-autoscaler"
    namespace = "kube-system"
  }
  spec {
    ingress {
      ports {
        port     = 8085
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
        "app.kubernetes.io/instance" = "cluster-autoscaler"
      }
    }
  }
}
