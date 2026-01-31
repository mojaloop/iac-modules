variable "argocd_override" {
  type        = any
  description = "ArgoCD apps configuration (from argoapps.yaml.tpl)"
}

variable "cluster_name" {
  type        = string
  description = "Name of the cluster"
}

variable "cloud_provider" {
  type        = string
  description = "Cloud provider (aws, azure, private-cloud)"
}

variable "dynamic_secret_platform" {
  type        = string
  description = "Dynamic secret platform (vault)"
  default     = "vault"
}

variable "gitrepo_host_fqdn" {
  type        = string
  description = "GitLab server host FQDN (e.g., gitlab.cc.example.com)"
}

variable "gitrepo_owner" {
  type        = string
  description = "GitLab group/owner for the repo"
}

variable "gitrepo_repo" {
  type        = string
  description = "GitLab repo name (iac-modules)"
  default     = "iac-modules"
}

variable "ansible_gitrepo" {
  type        = string
  description = "Ansible collection repo name"
  default     = "iac-ansible-collection-roles"
}

variable "ansible_collection_path" {
  type        = string
  description = "Path to ansible collection within repo"
  default     = "mojaloop/iac"
}

variable "root_app_gitrepo_path" {
  type        = string
  description = "Path to root app templates within iac-modules"
  default     = "gitops/argo-apps/base"
}

variable "helm_version" {
  type        = string
  description = "Helm version for ArgoCD"
  default     = "v3.16.0"
}

variable "helmfile_version" {
  type        = string
  description = "Helmfile version"
  default     = "v0.167.1"
}

variable "argocd_namespace" {
  type        = string
  description = "ArgoCD namespace"
  default     = "argocd"
}

variable "dns_public_subdomain" {
  type        = string
  description = "Public DNS subdomain (e.g., cc.example.com)"
}

variable "dns_private_subdomain" {
  type        = string
  description = "Private DNS subdomain (e.g., int.cc.example.com)"
}

variable "istio_external_gateway_namespace" {
  type        = string
  description = "Istio external gateway namespace"
  default     = "istio-external-gateway"
}

variable "istio_internal_gateway_namespace" {
  type        = string
  description = "Istio internal gateway namespace"
  default     = "istio-internal-gateway"
}

variable "istio_external_wildcard_gateway_name" {
  type        = string
  description = "Istio external wildcard gateway name"
  default     = "external-wildcard-gateway"
}

variable "istio_internal_wildcard_gateway_name" {
  type        = string
  description = "Istio internal wildcard gateway name"
  default     = "internal-wildcard-gateway"
}

variable "output_dir" {
  type        = string
  description = "Directory to write generated files"
}
