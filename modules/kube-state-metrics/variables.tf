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

variable "retention" {
  type        = string
  description = "retention period (i.e.: 6h)"
  default     = "7d"
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






