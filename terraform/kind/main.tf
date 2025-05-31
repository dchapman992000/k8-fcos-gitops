terraform {
  required_version = ">= 1.7.0"

  required_providers {
    kind = {
      source  = "tehcyx/kind"
      version = ">= 0.4"
    }
    null = {
      source = "hashicorp/null"
      version = ">= 3.2.4"
    }
  }
}

locals {
    k8s_config_path = pathexpand("~/.kube/config")
}

resource "kind_cluster" "this" {
  name = var.kind_cluster_name
  node_image = var.kind_node_image
  wait_for_ready = true
}

resource "null_resource" "kubectl_apply_flux_gotk_components" {
  provisioner "local-exec" {
    command = "kubectl apply -f ${path.module}/../../clusters/cluster3/flux-system/gotk-components.yaml --kubeconfig=${local.k8s_config_path} --context=kind-${var.kind_cluster_name}"
  }

  triggers = {
    always_run = timestamp()
  }

  depends_on = [kind_cluster.this]
}

resource "null_resource" "kubectl_create_sops_secret" {
  provisioner "local-exec" {
    command = <<EOT
      kubectl --kubeconfig=${local.k8s_config_path} --context=kind-${var.kind_cluster_name} \
        -n flux-system create secret generic sops-age \
        --from-file=age.agekey=${var.sops_age_key_path} \
        --dry-run=client -o yaml | kubectl --kubeconfig=${local.k8s_config_path} --context=kind-${var.kind_cluster_name} apply -f -
    EOT
  }

  triggers = {
    always_run = timestamp()
  }

  depends_on = [null_resource.kubectl_apply_flux_gotk_components]
}

resource "null_resource" "kubectl_apply_flux_gotk_sync" {
  provisioner "local-exec" {
    command = "kubectl apply -f ${path.module}/../../clusters/cluster3/flux-system/gotk-sync.yaml --kubeconfig=${local.k8s_config_path} --context=kind-${var.kind_cluster_name}"
  }

  triggers = {
    always_run = timestamp()
  }

  depends_on = [null_resource.kubectl_create_sops_secret]
}