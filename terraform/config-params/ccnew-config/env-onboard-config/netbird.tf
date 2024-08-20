#setup key for bastion host(s) to use for acting as gw to env private cluster
resource "netbird_setup_key" "env_gw" {
  name        = "${var.env_name}-gw"
  type        = "reusable"
  auto_groups = [netbird_group.env_gw.id]
  ephemeral   = false
  usage_limit = 0
  expires_in  = 86400
}
#setup key for k8s peers to use to connect to cc priv network
resource "netbird_setup_key" "env_k8s" {
  name        = "${var.env_name}-k8s"
  type        = "reusable"
  auto_groups = [local.env_k8s_peers_group_id]
  ephemeral   = true
  usage_limit = 0
  expires_in  = 86400
}

resource "netbird_group" "env_gw" {
  name = "${var.env_name}-gw"
}
#make group for vpn users for just this env cluster private network
resource "netbird_group" "env_users" {
  name = "${local.netbird_project_id}:${var.env_name}-vpn-users"
}
#route to allow private traffic into en k8s network from cc user group and the env_users group, env gw is the gateway peer
resource "netbird_route" "env_k8s" {
  description = "${var.env_name}-k8s"
  enabled     = true
  groups      = [netbird_group.env_users.id, local.cc_user_group_id]
  keep_route  = true
  masquerade  = true
  metric      = 9999
  peer_groups = [netbird_group.env_gw.id]
  network     = var.env_cidr
  network_id  = "${var.env_name}-k8s"
}
#use this to grab the group ids
data "netbird_groups" "all" {
}
locals {
  cc_user_group_id       = [for group in data.netbird_groups.all.groups : group.id if strcontains(group.name, "${local.netbird_project_id}:${var.netbird_user_rbac_group}")][0]
  env_k8s_peers_group_id = [for group in data.netbird_groups.all.groups : group.id if strcontains(group.name, "${var.env_name}-k8s-peers")][0]
}


resource "vault_kv_secret_v2" "env_netbird_gw_setup_key" {
  mount               = var.kv_path
  name                = "${var.env_name}/netbird_gw_setup_key"
  delete_all_versions = true
  data_json = jsonencode(
    {
      value = netbird_setup_key.env_gw.key

    }
  )
}

resource "vault_kv_secret_v2" "env_netbird_k8s_setup_key" {
  mount               = var.kv_path
  name                = "${var.env_name}/netbird_k8s_setup_key"
  delete_all_versions = true
  data_json = jsonencode(
    {
      value = netbird_setup_key.env_k8s.key

    }
  )
}
