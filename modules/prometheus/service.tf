resource "kubernetes_service" "prometheus" {
  metadata {
    name      = local.app_name
    namespace = var.namespace
    labels    = local.selectorLabels
  }

  spec {
    type     = var.service_type
    selector = local.selectorLabels

    port {
      name        = "prom"
      port        = 9090
      target_port = 9090
    }

    port {
      name        = "gprc"
      port        = 10901
      target_port = 10901
    }

    port {
      name        = "http"
      port        = 10902
      target_port = 10902
    }
  }
}

