resource "kubernetes_deployment" "kube_state_metrics" {
  metadata {
    name      = "kube-state-metrics"
    namespace = "kube-system"
    labels = {
      "app.kubernetes.io/name"       = "kube-state-metrics"
      "app.kubernetes.io/owner"      = "sre"
      "app.kubernetes.io/managed-by" = "Terraform"
      "app.kubernetes.io/component"  = "exporter"
      "app.kubernetes.io/version"    = "2.9.2"
    }
  }

  spec {
    replicas               = var.replicas.min
    revision_history_limit = var.revision_history_limit

    selector {
      match_labels = {
        "app.kubernetes.io/name" = "kube-state-metrics"
      }
    }

    template {
      metadata {
        labels = {
          "app.kubernetes.io/owner"      = "sre"
          "app.kubernetes.io/managed-by" = "Terraform"
          "app.kubernetes.io/component"  = "exporter"
          "app.kubernetes.io/version"    = "2.9.2"
        }
        annotations = {}
      }

      spec {
        service_account_name = kubernetes_service_account.kube_state_metrics.metadata.0.name
        node_selector        = var.deployment_node_selector
        priority_class_name  = var.priority_class_name

        affinity {
          node_affinity {
            preferred_during_scheduling_ignored_during_execution {
              weight = 1
              preference {
                match_expressions {
                  key      = "restart"
                  operator = "In"
                  values   = ["unlikely"]
                }
              }
            }
          }
        }

        toleration {
          effect   = "NoSchedule"
          key      = "onlyfor"
          operator = "Equal"
          value    = "highcpu"
        }

        toleration {
          effect   = "NoSchedule"
          key      = "dbonly"
          operator = "Equal"
          value    = "yes"
        }

        container {
          name              = "kube-state-metrics"
          image             = "quay.io/coreos/kube-state-metrics:v1.9.7"
          image_pull_policy = "IfNotPresent"

          port {
            container_port = 8080
            name           = "http-metrics"
          }

          port {
            container_port = 8081
            name           = "telemetry"
          }

          readiness_probe {
            http_get {
              path = "/healthz"
              port = 8080
            }

            initial_delay_seconds = 15
            timeout_seconds       = 5
          }

        }
      }
    }
  }
}