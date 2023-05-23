# terraform-prometheus-deployment
Terraform prometheus deployment for GKE

### Prerequisites

```hcl


# Get kubernetes cluster info.
data "google_client_config" "default" {}

data "google_container_cluster" "sandbox" {
  name     = "<REPLACE_ME>"
  location = "<REPLACE_ME>"
  project  = "<REPLACE_ME>"
}

# Connect to the kubernetes cluster using the standard provider.
provider "kubernetes" {
  host  = "https://${data.google_container_cluster.sandbox.endpoint}"
  token = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(
    data.google_container_cluster.sandbox.master_auth[0].cluster_ca_certificate,
  )
}

```

### Usage

```hcl
module "prometheus" {

    source                         = "git@github.com:blockops-sh/terraform-prometheus-deployment"

    name                           = "prometheus"
    namespace                      = "monitoring"
    prometheus_domain              = "prometheus.example.com"
    volume_size                    = "10Gi"
    retention                      = "7d"
    service_type                   = "ClusterIP"
    kubernetes_grafana_secret_name = "<secret_name>"
    kubernetes_grafana_secret_key  = "<secret_key>"
    kubernetes_grafana_secret_path = "<secret_path>"

    replicas = {
        min = "1"
        max = "2"
    }
}
```