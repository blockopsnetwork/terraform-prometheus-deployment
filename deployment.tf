## Terraform statefulset resource definition for prometheus
resource "kubernetes_deployment" "prometheus" {
  metadata {
    name      = local.app_name
    namespace = var.namespace
    labels    = local.labels
  }

  spec {
    replicas               = var.replicas.min
    revision_history_limit = var.revision_history_limit

    selector {
      match_labels = local.selectorLabels
    }

    template {
      metadata {
        labels      = local.selectorLabels
        annotations = {}
      }

      spec {
        service_account_name = kubernetes_service_account.prometheus.metadata.0.name
        node_selector        = var.deployment_node_selector
        priority_class_name  = var.priority_class_name

        affinity {
          pod_anti_affinity {
            required_during_scheduling_ignored_during_execution {
              topology_key = "kubernetes.io/hostname"
              label_selector {
                match_expressions {
                  key      = "app.kubernetes.io/app"
                  operator = "In"
                  values   = [local.app_name]
                }
              }
            }
          }

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

        container {
          name              = "prometheus-server"
          image             = "prom/prometheus:v2.44.0"
          image_pull_policy = "IfNotPresent"

          args = [
            "--config.file=/etc/config/prometheus.yml",
            "--web.console.libraries=/etc/prometheus/console_libraries",
            "--web.console.templates=/etc/prometheus/consoles",
            "--web.enable-lifecycle",
            "--storage.tsdb.retention=${var.retention}",
          ]

          port {
            container_port = 9090
          }

          env {
            name  = "GRAFANA_SECRET"
            value = "kubepromsecret"
          }

          env {
            name = "GRAFANA_USERNAME"
            value_from {
              secret_key_ref {
                name = "kubepromsecret"
                key  = "username"
              }
            }
          }

          env {
            name = "GRAFANA_PASSWORD"
            value_from {
              secret_key_ref {
                name = "kubepromsecret"
                key  = "password"
              }
            }
          }

          resources {
            limits = {
              cpu    = var.prometheus_resource.limits.cpu
              memory = var.prometheus_resource.limits.memory
            }
            requests = {
              cpu    = var.prometheus_resource.requests.cpu
              memory = var.prometheus_resource.requests.memory
            }
          }

          volume_mount {
            name       = "config-volume"
            mount_path = "/etc/config/prometheus.yml"
            sub_path   = "prometheus.yml"
          }

          volume_mount {
            name       = "config-volume"
            mount_path = "/etc/config/prometheus.rules"
            sub_path   = "prometheus.rules"
          }

          volume_mount {
            name       = "grafana-secret"
            mount_path = "/etc/config/grafana-secret"
            read_only  = true
          }

          readiness_probe {
            http_get {
              path = "/"
              port = 9090
            }

            initial_delay_seconds = 15
            timeout_seconds       = 5
          }

          liveness_probe {
            http_get {
              path = "/"
              port = 9090
              # scheme = "HTTPS"
            }

            initial_delay_seconds = 15
            timeout_seconds       = 5
          }
        }

        termination_grace_period_seconds = 300

        volume {
          name = "grafana-secret"

          secret {
            secret_name = var.kubernetes_grafana_secret_name
            items {
              key  = var.kubernetes_grafana_secret_key
              path = var.kubernetes_grafana_secret_path
            }
          }
        }

        volume {
          name = "config-volume"

          config_map {
            name = kubernetes_config_map.global-config.metadata.0.name
            items {
              key  = "prometheus.yml"
              path = "prometheus.yml"
            }
          }
        }

        volume {
          name = "alert-rules"

          config_map {
            name = kubernetes_config_map.global-config.metadata.0.name
            items {
              key  = "prometheus.rules"
              path = "prometheus.rules"
            }
          }
        }
      }
    }
  }
}


resource "kubernetes_deployment" "kube_state_metrics" {
  metadata {
    name      = "kube-state-metrics"
    namespace = var.namespace
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
      match_labels = local.selectorLabels
    }

    template {
      metadata {
        labels      = local.selectorLabels
        annotations = {}
      }

      spec {
        service_account_name = kubernetes_service_account.kube_state_metrics.metadata.0.name
        node_selector        = var.deployment_node_selector
        priority_class_name  = var.priority_class_name

        affinity {
          pod_anti_affinity {
            required_during_scheduling_ignored_during_execution {
              topology_key = "kubernetes.io/hostname"
              label_selector {
                match_expressions {
                  key      = "app.kubernetes.io/app"
                  operator = "In"
                  values   = [local.app_name]
                }
              }
            }
          }

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