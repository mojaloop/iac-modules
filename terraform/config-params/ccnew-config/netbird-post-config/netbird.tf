resource "netbird_setup_key" "cc_gw_setup_key" {
  name        = "cc bastion gateway setup key"
  type        = "reusable"
  auto_groups = [netbird_group.cc_gateway.id]
  ephemeral   = false
  usage_limit = 0
  expires_in  = 86400
}

resource "netbird_setup_key" "build_server_setup_key" {
  name        = "build host setup key"
  type        = "one-off"
  auto_groups = [netbird_group.user_group_id.id]
  ephemeral   = true
  usage_limit = 1
  expires_in  = 86400
}

resource "netbird_group" "cc_gateway" {
  name = "${var.cc_cluster_name}-gateway"
}
#create groups for each env k8s peers so we can add to the peer groups list
resource "netbird_group" "cc_env_k8s_peers" {
  for_each = local.environment_list
  name     = "${each.key}-k8s-peers"
}


resource "netbird_route" "cc_k8s_access" {
  description = "${var.cc_cluster_name}-cluster-access"
  enabled     = true
  groups      = local.cc_peers_list
  keep_route  = true
  masquerade  = true
  metric      = 9999
  peer_groups = [netbird_group.cc_gateway.id]
  network     = var.cc_cluster_cidr
  network_id  = "${var.cc_cluster_name}-cluster-access"
}

data "netbird_groups" "all" {}
locals {
  #first time the netbird api user logs in, the admin and users groups get created because the api user is a member of those, so we grab them from the groups datasource
  user_group_id    = [for group in data.netbird_groups.all.groups : group.id if strcontains(group.name, var.user_rbac_group)][0]
  environment_list = toset(split(",", var.environment_list))
  cc_peers_list    = concat([local.user_group_id], netbird_group.cc_env_k8s_peers.*.id)
}

resource "kubernetes_secret_v1" "setup_keys" {
  metadata {
    name      = var.setup_key_secret_name
    namespace = var.setup_key_secret_namespace
  }
  data = {
    "${var.gw_setup_key_secret_key}"    = netbird_setup_key.cc_gw_setup_key.key
    "${var.build_setup_key_secret_key}" = netbird_setup_key.build_server_setup_key.key
  }
  type = "Opaque"
}
