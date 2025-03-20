variable "common_platform_db_secret_name" {
}

variable "common_mojaloop_db_secret_name" {
}

variable "common_platform_db_external_name" {
}

variable "common_mojaloop_db_external_name"{
}

data "kubernetes_secret_v1" "common_platform_db_secret" {
  metadata {
      name      = var.common_platform_db_secret_name
      namespace = var.env_name
  }
}

data "kubernetes_secret_v1" "common_mojaloop_db_secret" {
  metadata {
      name      = var.common_mojaloop_db_secret_name
      namespace = var.env_name
  }
}

resource "vault_kv_secret_v2" "common_platform_db_secret" {
  mount               = var.kv_path
  name                = "${var.env_name}/common_platform_db_secret"
  delete_all_versions = true
  data_json = jsonencode(
    {
      value = try(data.kubernetes_secret_v1.common_platform_db_secret.data.password, "")
    }
  )
}


resource "vault_kv_secret_v2" "common_mojaloop_db_secret" {
  mount               = var.kv_path
  name                = "${var.env_name}/common_mojaloop_db_secret"
  delete_all_versions = true
  data_json = jsonencode(
    {
      value = try(data.kubernetes_secret_v1.common_mojaloop_db_secret.data.password, "")
    }
  )
}


data "kubernetes_service_v1" "common_platform_db_service" {
  metadata {
    name      = var.common_platform_db_external_name
    namespace = var.env_name
  }
}

data "kubernetes_service_v1" "common_mojaloop_db_service" {
  metadata {
    name      = var.common_mojaloop_db_external_name
    namespace = var.env_name
  }
}


resource "vault_kv_secret_v2" "common_platform_db_endpoint" {
  mount               = var.kv_path
  name                = "${var.env_name}/common_platform_db_endpoint"
  delete_all_versions = true
  data_json = jsonencode(
    {
      value = try(data.kubernetes_service_v1.common_platform_db_service.spec[0].external_name, "")
    }
  )
}


resource "vault_kv_secret_v2" "common_mojaloop_db_endpoint" {
  mount               = var.kv_path
  name                = "${var.env_name}/common_mojaloop_db_endpoint"
  delete_all_versions = true
  data_json = jsonencode(
    {
      value = try(data.kubernetes_service_v1.common_mojaloop_db_service.spec[0].external_name, "")
    }
  )
}