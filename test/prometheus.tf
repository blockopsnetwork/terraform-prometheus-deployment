data "google_client_config" "default" {}

data "google_container_cluster" "sandbox" {
  name     = "sandbox-dev"
  location = "europe-west1"
  project  = "evident-bedrock-387111"
}

provider "kubernetes" {
  host  = "https://${data.google_container_cluster.sandbox.endpoint}"
  token = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(
    data.google_container_cluster.sandbox.master_auth[0].cluster_ca_certificate,
  )
}

# Module for prometheus deployment
module "prometheus" {
  source                         = "../modules/prometheus"
  name                           = "prometheus"
  namespace                      = "monitoring"
  prometheus_domain              = "prometheus.birozuru.tech"
  kubernetes_grafana_secret_name = "kubepromsecret"
  kubernetes_grafana_secret_key  = "password"
  kubernetes_grafana_secret_path = "password"

}