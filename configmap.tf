resource "kubernetes_config_map" "global-config" {
  metadata {
    name      = "${var.name}-global-config"
    namespace = var.namespace
  }

  data = {
    "prometheus.yml" = file("${path.module}/files/prometheus.yml")
  }
}

resource "kubernetes_config_map" "prometheus-init-script" {
  metadata {
    name      = "${var.name}-init-script"
    namespace = var.namespace
  }

  data = {
    "init-config.sh" = file("${path.module}/files/init-config.sh")
  }
}