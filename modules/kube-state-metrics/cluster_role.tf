resource "kubernetes_cluster_role" "kube_state_metrics" {
  metadata {
    name = "kube-state-metrics"
    labels = {
      "app.kubernetes.io/app"        = "kube-state-metrics"
      "app.kubernetes.io/owner"      = "sre"
      "app.kubernetes.io/managed-by" = "Terraform"
      "app.kubernetes.io/component"  = "exporter"
      "app.kubernetes.io/version"    = "2.9.2"
    }
  }

  rule {
    api_groups = [""]
    resources  = ["configmaps", "secrets", "nodes", "pods", "services", "resourcequotas", "replicationcontrollers", "limitranges", "persistentvolumeclaims", "persistentvolumes", "namespaces", "endpoints", "events", "nodes/proxy", "nodes/metrics", "nodes/spec", "nodes/stats", "nodes/log", "serviceaccounts", "replicasets", "daemonsets", "deployments", "statefulsets", "jobs", "cronjobs", "configmaps", "ingresses", "horizontalpodautoscalers", "certificatesigningrequests", "leases", "roles", "rolebindings", "podsecuritypolicies", "clusterrolebindings", "clusterroles"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = ["extensions", "apps"]
    resources  = ["replicasets", "deployments", "daemonsets", "statefulsets"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = ["batch"]
    resources  = ["jobs", "cronjobs"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = ["autoscaling"]
    resources  = ["horizontalpodautoscalers"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = ["policy"]
    resources  = ["poddisruptionbudgets"]
    verbs      = ["get", "list", "watch"]
  }
}

resource "kubernetes_cluster_role_binding" "kube_state_metrics" {
  metadata {
    name = "kube-state-metrics"
    labels = {
      "app.kubernetes.io/app"        = "kube-state-metrics"
      "app.kubernetes.io/owner"      = "sre"
      "app.kubernetes.io/managed-by" = "Terraform"
      "app.kubernetes.io/component"  = "exporter"
      "app.kubernetes.io/version"    = "2.9.2"
    }
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.kube_state_metrics.metadata.0.name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.kube_state_metrics.metadata.0.name
    namespace = kubernetes_service_account.kube_state_metrics.metadata.0.namespace
  }
}