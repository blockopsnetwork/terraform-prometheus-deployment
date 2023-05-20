resource "kubernetes_service_account" "prometheus" {
  metadata {
    name      = local.app_name
    namespace = var.namespace
    labels    = local.labels
  }
}