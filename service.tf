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

resource "kubernetes_service" "kube_state_metrics" {
  metadata {
    name      = "kube-state-metrics"
    namespace = var.namespace
    labels = {
      "app.kubernetes.io/app"        = "kube-state-metrics"
      "app.kubernetes.io/owner"      = "sre"
      "app.kubernetes.io/managed-by" = "Terraform"
    }
  }

  spec {
    type     = var.service_type
    selector = local.selectorLabels

    port {
      name        = "http"
      port        = 8080
      target_port = 8080
    }

    port {
      name        = "telemetry"
      port        = 8081
      target_port = 8081
    }
  }
}