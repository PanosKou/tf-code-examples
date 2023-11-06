# Allow-all to handle all variety of the requests 
resource "kubernetes_network_policy" "allow-all" {
  metadata {
    name      = "allow-all"
    namespace = kubernetes_namespace.ingress_nginx_namespace.id
  }
  spec {
    pod_selector {}
    ingress {} # single empty rule to allow all ingress traffic
    egress {}  # single empty rule to allow all egress traffic
    policy_types = ["Ingress", "Egress"]
  }
}