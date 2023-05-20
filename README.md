# terraform-prometheus-deployment
Terraform prometheus deployment for GKE

### Preparing to run the module

```hcl

#
# Get kubernetes cluster info.
#
data "google_client_config" "default" {}

data "google_container_cluster" "sandbox" {
  name     = "<REPLACE_ME>"
  location = "<REPLACE_ME>"
  project  = "<REPLACE_ME>"
}


#
# Connect to the kubernetes cluster using the standard provider.
#
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

    source            = ""

    name              = ""
    namespace         = ""
    prometheus_domain = ""

}
```