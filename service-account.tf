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
    namespace = var.namespace
    labels    = local.labels
  }
}