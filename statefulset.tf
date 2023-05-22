## Terraform statefulset resource definition for prometheus
resource "kubernetes_stateful_set" "prometheus" {
  metadata {
    name      = local.app_name
    namespace = var.namespace
    labels    = local.labels
  }

  spec {
    pod_management_policy  = var.pod_management_policy
    replicas               = var.replicas.min
    revision_history_limit = var.revision_history_limit

    selector {
      match_labels = local.selectorLabels
    }

    service_name = local.app_name

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

        init_container {
          name              = "init-chown-data"
          image             = "busybox:latest"
          image_pull_policy = "IfNotPresent"
          command           = ["chown", "-R", "65534:65534", "/data"]

          volume_mount {
            name       = var.volume_mount_name
            mount_path = "/data"
            sub_path   = ""
          }
        }

        init_container {
          name              = "init-prometheus-config"
          image             = "busybox:latest"
          image_pull_policy = "IfNotPresent"
          command           = ["sh", "-c", "./init-config.sh"]

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


          volume_mount {
            name       = "init-config"
            mount_path = "/init-config.sh"
            sub_path   = "init-config.sh"
          }

          volume_mount {
            name       = "config-volume"
            mount_path = "/etc/config/prometheus.yml"
            sub_path   = "prometheus.yml"
          }
        }

        container {
          name              = "prometheus-server"
          image             = "prom/prometheus:v2.44.0"
          image_pull_policy = "IfNotPresent"

          args = [
            "--config.file=/etc/config/prometheus.yml",
            "--storage.tsdb.path=/data",
            "--web.console.libraries=/etc/prometheus/console_libraries",
            "--web.console.templates=/etc/prometheus/consoles",
            "--web.enable-lifecycle",
            "--storage.tsdb.retention=${var.retention}",
          ]

          port {
            container_port = 9090
          }

          env {
            name = "GRAFANA_SECRET"
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
            name       = "prometheus-data"
            mount_path = "/data"
            sub_path   = ""
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
          name = "init-config"

          config_map {
            name = kubernetes_config_map.prometheus-init-script.metadata.0.name
            items {
              key  = "init-config.sh"
              path = "init-config.sh"
            }
            default_mode = "0777"
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
          name = var.volume_mount_name

          persistent_volume_claim {
            claim_name = var.volume_mount_name
          }
        }
      }
    }

    update_strategy {
      type = "RollingUpdate"

      rolling_update {
        partition = 1
      }
    }

    volume_claim_template {
      metadata {
        name = var.volume_mount_name
      }

      spec {
        access_modes       = ["ReadWriteOnce"]
        storage_class_name = local.app_name

        resources {
          requests = {
            storage = var.volume_size
          }
        }
      }
    }
  }
}