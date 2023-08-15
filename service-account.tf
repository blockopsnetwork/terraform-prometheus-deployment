resource "kubernetes_service_account" "prometheus" {
  metadata {
    name      = local.app_name
    namespace = var.namespace
    labels    = local.labels
  }
}

resource "kubernetes_service_account" "kube_state_metrics" {
  metadata {
    name      = "kube-state-metrics"
    namespace = "kube-system"
    labels = {
      "app.kubernetes.io/app"        = "kube-state-metrics"
      "app.kubernetes.io/owner"      = "sre"
      "app.kubernetes.io/managed-by" = "Terraform"
      "app.kubernetes.io/component"  = "exporter"
      "app.kubernetes.io/version"    = "2.9.2"
    }
  }
}