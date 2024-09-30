# netbird group for managed service gateway 
resource "netbird_group" "ms_env_gw" {
  count = local.ms_enabled ? 1 : 0
  name  = "${var.env_name}-managed-svc-gw"
  lifecycle {
    create_before_destroy = true
  }
}

#setup key for bastion host(s) in managed service vpc to use for acting as gw to env managed sevice cluster
resource "netbird_setup_key" "ms_env_gw" {
  count       = local.ms_enabled ? 1 : 0
  name        = "${var.env_name}-managed-svc-gw"
  type        = "reusable"
  auto_groups = [netbird_group.ms_env_gw[0].id]
  ephemeral   = false
  usage_limit = 0
  expires_in  = 7776000
  rotation_id = time_rotating.setup_key_rotation.id
}

# netbird route for allowing access to managed vpc cidr ( subnets of rds, msk and others )
resource "netbird_route" "env_managed_svc_route" {
  count       = local.ms_enabled ? 1 : 0
  description = "${var.env_name}-managed-svc"
  enabled     = true
  groups      = [netbird_group.env_users.id, local.env_k8s_peers_group_id, local.cc_user_group_id]
  keep_route  = true
  masquerade  = true
  metric      = 9999
  peer_groups = [netbird_group.ms_env_gw[0].id]
  network     = var.managed_services_env_cidr
  network_id  = "${var.env_name}-managed-svc"
}

locals {
  ms_enabled = tobool(var.managed_svc_enabled)
}

resource "vault_kv_secret_v2" "env_netbird_ms_gw_setup_key" {
  count               = local.ms_enabled ? 1 : 0
  mount               = var.kv_path
  name                = "${var.env_name}/netbird_ms_gw_setup_key"
  delete_all_versions = true
  data_json = jsonencode(
    {
      value = netbird_setup_key.ms_env_gw[0].key

    }
  )
}
