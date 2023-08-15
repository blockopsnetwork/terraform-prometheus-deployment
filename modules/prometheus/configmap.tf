resource "kubernetes_config_map" "global-config" {
  metadata {
    name      = "${var.name}-global-config"
    namespace = var.namespace
  }

  data = {
    "prometheus.yml"   = file("${path.module}/files/prometheus.yml")
    "prometheus.rules" = file("${path.module}/files/prometheus.rules")
  }
}
