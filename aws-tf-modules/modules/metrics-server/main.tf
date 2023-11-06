
resource "helm_release" "metrics_server" {
  name        = "metrics-server"
  chart       = "${path.module}/charts/metrics-server"
  namespace   = "kube-system"
  values      = [data.template_file.metrics_server_values.rendered]
  max_history = 5
}
