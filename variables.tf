variable "namespace" {
  description = "Prometheus operated namespace"
  type        = string
}

variable "replicas" {
  description = "Number of deployment replicas"
  type = object({
    max = number
    min = number
  })
  default = {
    max = 2
    min = 1
  }
}

variable "pod_management_policy" {
  description = "Value for podManagementPolicy"
  type        = string
  default     = "Parallel"
}

variable "revision_history_limit" {
  type        = number
  description = "Value for revisionHistoryLimit"
  default     = 5
}

variable "prometheus_scrape" {
  description = "Enable prometheus scraping"
  type        = bool
  default     = true
}

variable "prometheus_resource" {
  description = "prometheus container resource configuration"
  type = object({
    limits = object({
      cpu    = string
      memory = string
    })
    requests = object({
      cpu    = string
      memory = string
    })
  })
  default = {
    limits = {
      cpu    = "500m"
      memory = "512Mi"
    }
    requests = {
      cpu    = "500m"
      memory = "512Mi"
    }
  }
}

variable "deployment_node_selector" {
  description = "Map of label names and values to assign the podspec's nodeSelector property"
  type        = map(string)
  default     = null
}

variable "priority_class_name" {
  description = "The priority class to attach to the deployment"
  type        = string
  default     = null
}

variable "name" {
  type        = string
  description = "prometheus operated name"
}

variable "retention" {
  type        = string
  description = "retention period (i.e.: 6h)"
  default     = "7d"
}

variable "image" {
  type        = string
  description = "https://github.com/prometheus/prometheus/releases"
  default     = "quay.io/prometheus/prometheus:v2.44.0"
}

variable "scrape_interval" {
  type        = string
  description = "how often to scrape targets"
  default     = "15s"
}

variable "node_selector" {
  type        = map(string)
  description = "labels to determine which node we run on"
  default     = {}
}

variable "service_type" {
  type        = string
  description = "service type (i.e.: LoadBalancer or ClusterIP"
  default     = "ClusterIP"
}

variable "additional_scrape_configs" {
  description = "additional scrape configs (see: https://prometheus.io/docs/prometheus/latest/configuration/configuration/#scrape_config)"
  default     = null
}

variable "volume_size" {
  type        = string
  description = "persistent volume size"
  default     = "16Gi"
}

variable "default_ingress_scrape_targets" {
  type        = list(string)
  description = "Default ingress scrape targets"
  default     = ["ingress-controller-metrics.default.svc.cluster.local:10254"]
}

variable "volume_mount_name" {
  type        = string
  description = "volume mount name"
  default     = "prometheus-data"
}

variable "whitelist_source_range" {
  type        = string
  description = "whitelist source range"
  default     = "0.0.0.0/0"
}

variable "ingress_enabled" {
  type        = bool
  description = "Enable ingress"
  default     = true
}

variable "storage_provisioner" {
  type        = string
  description = "storage provisioner for storage class"
  default     = "pd.csi.storage.gke.io"
}

variable "volume_binding_mode" {
  type        = string
  description = "volume binding mode for storage class"
  default     = "Immediate"
}

variable "reclaim_policy" {
  type        = string
  description = "reclaim policy for storage class"
  default     = "Delete"
}

variable "storage_class_type" {
  type        = string
  description = "storage class type"
  default     = "pd-standard"
}

variable "allow_volume_expansion" {
  type        = bool
  description = "allow volume expansion for storage class"
  default     = true
}

variable "prometheus_domain" {
  type        = string
  description = "dns domain for prometheus ingress"
  default     = "prometheus.birozuru.tech"
}