resource "kubernetes_cluster_role" "prometheus" {
  metadata {
    name   = local.app_name
    labels = local.labels
  }

  rule {
    api_groups = [""]
    resources  = ["configmaps", "endpoints", "nodes", "pods", "secrets", "services", "nodes/proxy", "nodes/metrics"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = ["extensions", "networking.k8s.io"]
    resources  = ["ingresses"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = [""]
    resources  = ["events"]
    verbs      = ["create", "patch"]
  }

  rule {
    non_resource_urls = ["/metrics"]
    verbs             = ["get"]
  }
}

resource "kubernetes_cluster_role_binding" "prometheus" {
  metadata {
    name   = local.app_name
    labels = local.labels
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.prometheus.metadata.0.name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.prometheus.metadata.0.name
    namespace = kubernetes_service_account.prometheus.metadata.0.namespace
  }
}

