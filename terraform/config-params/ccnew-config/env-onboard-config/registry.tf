data "kubernetes_secret_v1" "nexus_readonly_password" {
  metadata {
    name      = var.nexus_readonly_password_secret_name
    namespace = var.nexus_readonly_password_secret_namespace
  }
}

resource "vault_kv_secret_v2" "nexus_readonly_password" {
  mount               = var.kv_path
  name                = "${var.env_name}/nexus_readonly_password"
  delete_all_versions = true
  data_json = jsonencode(
    {
      value = try(data.kubernetes_secret_v1.nexus_readonly_password.data.external-docker-nexus-password, "")
    }
  )
}

data "kubernetes_secret_v1" "registry_mirror_readonly_password" {
  metadata {
    name      = var.registry_mirror_readonly_password_secret_name
    namespace = var.registry_mirror_readonly_password_secret_namespace
  }
}

resource "vault_kv_secret_v2" "registry_mirror_readonly_password" {
  mount               = var.kv_path
  name                = "${var.env_name}/registry_mirror_readonly_password"
  delete_all_versions = true
  data_json = jsonencode(
    {
      value = try(data.kubernetes_secret_v1.registry_mirror_readonly_password.data.external-docker-harbor-password, "")
    }
  )
}
