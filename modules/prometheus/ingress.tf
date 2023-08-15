### Ingress definition for prometheus deployment
resource "kubernetes_ingress_v1" "ingress" {
  metadata {
    name        = local.app_name
    namespace   = var.namespace
    labels      = local.selectorLabels
    annotations = {}
  }

  spec {
    rule {
      host = var.prometheus_domain
      http {
        path {
          path = "/"
          backend {
            service {
              name = kubernetes_service.prometheus.metadata.0.name
              port {
                number = kubernetes_service.prometheus.spec.0.port.0.port
              }
            }
          }
        }
      }
    }
  }
}