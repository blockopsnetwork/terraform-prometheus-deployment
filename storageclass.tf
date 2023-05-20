resource "kubernetes_storage_class" "prometheus" {
  metadata {
    name   = local.app_name
    labels = local.labels
  }

  storage_provisioner    = var.storage_provisioner
  reclaim_policy         = var.reclaim_policy
  allow_volume_expansion = var.allow_volume_expansion
  volume_binding_mode    = var.volume_binding_mode

  parameters = {
    type = var.storage_class_type
  }
}
