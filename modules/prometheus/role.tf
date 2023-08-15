resource "kubernetes_role" "prometheus" {
  metadata {
    name      = local.app_name
    namespace = var.namespace
    labels    = local.labels
  }

  rule {
    api_groups = [""]
    resources  = ["namespaces"]
    verbs      = ["get"]
  }

  rule {
    api_groups = [""]
    resources  = ["configmaps", "pods", "secrets", "endpoints"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = [""]
    resources  = ["services"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = ["extensions", "networking.k8s.io"]
    resources  = ["ingresses"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = [""]
    resources  = ["configmaps"]
    verbs      = ["create", "update"]
  }

  rule {
    api_groups = [""]
    resources  = ["events"]
    verbs      = ["create", "patch"]
  }
}

