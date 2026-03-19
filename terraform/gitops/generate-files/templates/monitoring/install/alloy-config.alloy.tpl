// Discover all Kubernetes pods
discovery.kubernetes "pods" {
role = "pod"
}

// Relabel metadata into log labels
discovery.relabel "pod_logs" {
targets = discovery.kubernetes.pods.targets

rule {
    source_labels = ["__meta_kubernetes_namespace"]
    action        = "replace"
    target_label  = "namespace"
}

rule {
    source_labels = ["__meta_kubernetes_pod_name"]
    action        = "replace"
    target_label  = "pod"
}

rule {
    source_labels = ["__meta_kubernetes_pod_container_name"]
    action        = "replace"
    target_label  = "container"
}

rule {
    source_labels = ["__meta_kubernetes_pod_label_app_kubernetes_io_name"]
    action        = "replace"
    target_label  = "app"
}

rule {
    source_labels = ["__meta_kubernetes_pod_label_app_kubernetes_io_component", "__meta_kubernetes_pod_label_component"]
    action        = "replace"
    target_label  = "component"
    regex         = "^;*([^;]+)(;.*)?$"
}

rule {
    source_labels = ["__meta_kubernetes_namespace", "__meta_kubernetes_pod_container_name"]
    action        = "replace"
    target_label  = "job"
    separator     = "/"
    replacement   = "$1"
}

rule {
    source_labels = ["__meta_kubernetes_pod_node_name"]
    action        = "replace"
    target_label  = "node_name"
}
}

// Collect container logs
loki.source.kubernetes "pod_logs" {
targets    = discovery.relabel.pod_logs.output
forward_to = [loki.process.pod_logs.receiver]
}

// Process logs: parse CRI format, apply rate limits, and tag cluster
loki.process "pod_logs" {
stage.cri {}

stage.limit {
    rate          = 200     // logs per second per pod
    burst         = 500
    drop          = true
    by_label_name = "pod"
}

stage.static_labels {
    values = {
    cluster = "${cluster_label}",
    }
}
forward_to = [loki.write.local_loki.receiver, loki.process.central_loki_filter.receiver]
}

// Push to Local Loki Gateway
loki.write "local_loki" {
endpoint {
    url = "http://${loki_release_name}-gateway.monitoring.svc.cluster.local/loki/api/v1/push"
}
}

loki.process "central_loki_filter" {
%{if enable_central_loki_write ~}

  stage.match {
    selector            = "{namespace!~\"${namespaces_to_central_loki}\"}"
    action              = "drop"
    drop_counter_reason = "non_allowed_namespace"
  }

%{else ~}
  stage.drop {
    expression          = ".*"
    drop_counter_reason = "central_loki_disabled"
  }

%{endif ~}
  forward_to = [loki.write.central_loki.receiver]
}

// Push to Central Loki
loki.write "central_loki" {
  endpoint {
    url = "${central_loki_endpoint}/loki/api/v1/push"
  }
}
