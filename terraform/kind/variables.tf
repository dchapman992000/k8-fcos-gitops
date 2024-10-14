variable "github_org" {
  description = "GitHub organization"
  type        = string
  default     = "dcatwoohoo"
}

variable "github_repository" {
  description = "GitHub repository"
  type        = string
  default     = "k8-fcos-gitops"
}

variable "kind_node_image" {
    description = "Docker Image"
    type = string
    default = "kindest/node:v1.31.1"
}

variable "kind_cluster_name" {
    description = "The name of the Kind Cluster"
    type = string
    default = "test"
}

variable "sops_age_key_path" {
    description = "Location of the sops age.key"
    type = string
    default = ""
}

variable "gotk-components_path" {
    description = "Path within repository to the gotk-components"
    type = string
    default = "clusters/cluster1/flux-system/gotk-components.yaml"
}

variable "gotk-sync_path" {
    description = "Path within repository to the gotk-sync"
    type = string
    default = "clusters/cluster1/flux-system/gotk-sync.yaml"
}