resource "kubernetes_service" "kube_state_metrics" {
  metadata {
    name      = "kube-state-metrics"
    namespace = "kube-system"
    labels = {
      "app.kubernetes.io/app"        = "kube-state-metrics"
      "app.kubernetes.io/owner"      = "sre"
      "app.kubernetes.io/managed-by" = "Terraform"
    }
  }

  spec {
    type = var.service_type
    selector = {
      "app.kubernetes.io/name" = "kube-state-metrics"
    }

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