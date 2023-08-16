resource "kubernetes_role" "kube_state_metrics" {
  metadata {
    name      = "kube-state-metrics"
    namespace = "kube-system"
    labels    = {
        "app.kubernetes.io/app"        = "kube-state-metrics"
        "app.kubernetes.io/owner"      = "sre"
        "app.kubernetes.io/managed-by" = "Terraform"
    }
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
    namespace = "kube-system"
    labels    = {
        "app.kubernetes.io/app"        = "kube-state-metrics"
        "app.kubernetes.io/owner"      = "sre"
        "app.kubernetes.io/managed-by" = "Terraform"
    } 
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