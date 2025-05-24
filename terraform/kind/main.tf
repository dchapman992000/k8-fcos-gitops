terraform {
  required_version = ">= 1.7.0"

  required_providers {
    kind = {
      source  = "tehcyx/kind"
      version = ">= 0.4"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = ">= 2.33.0"
    }
  }
}

data "kubectl_file_documents" "gotk-components" {
    content = file("${path.module}/../../clusters/cluster3/flux-system/gotk-components.yaml")
}

data "kubectl_file_documents" "gotk-sync" {
    content = file("${path.module}/../../clusters/cluster3/flux-system/gotk-sync.yaml")
}

resource "kind_cluster" "this" {
  name = var.kind_cluster_name
  node_image = var.kind_node_image
  wait_for_ready = true
}

resource "kubectl_manifest" "gotk-components" {
  depends_on = [ kind_cluster.this ]
  for_each  = data.kubectl_file_documents.gotk-components.manifests
  yaml_body = each.value
}

resource "kubernetes_secret" "sops" {
  depends_on = [kubectl_manifest.gotk-components]
  metadata {
    name = "sops-age"
    namespace = "flux-system"
  }
  data = {
    "age.agekey" = file(var.sops_age_key_path)
  }
}

resource "kubectl_manifest" "gotk-sync" {
  depends_on = [ kind_cluster.this, kubernetes_secret.sops ]
  for_each  = data.kubectl_file_documents.gotk-sync.manifests
  yaml_body = each.value
}