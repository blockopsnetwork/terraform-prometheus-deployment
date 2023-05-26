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

resource "kubernetes_role" "kube_state_metrics" {
  metadata {
    name      = "kube-state-metrics"
    namespace = var.namespace
    labels    = local.labels
  }

  rule {
    api_groups = [""]
    resources  = ["configmaps", "secrets", "nodes", "pods", "services", "resourcequotas", "replicationcontrollers", "limitranges", "persistentvolumeclaims", "persistentvolumes", "namespaces", "endpoints", "events", "nodes/proxy", "nodes/metrics", "nodes/spec", "nodes/stats", "nodes/log", "serviceaccounts", "replicasets", "daemonsets", "deployments", "statefulsets", "jobs", "cronjobs", "configmaps", "ingresses", "horizontalpodautoscalers", "certificatesigningrequests", "leases", "roles", "rolebindings", "podsecuritypolicies", "clusterrolebindings", "clusterroles"]
    verbs      = ["get"]
  }

  rule {
    api_groups     = ["extensions", "networking.k8s.io"]
    resources      = ["ingresses", "deployments"]
    verbs          = ["get", "update"]
    resource_names = ["kube-state-metrics"]
  }
}

resource "kubernetes_role_binding" "kube_state_metrics" {
  metadata {
    name      = "kube-state-metrics"
    namespace = var.namespace
    labels    = local.labels
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.kube_state_metrics.metadata.0.name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.kube_state_metrics.metadata.0.name
    namespace = kubernetes_service_account.kube_state_metrics.metadata.0.namespace
  }
}