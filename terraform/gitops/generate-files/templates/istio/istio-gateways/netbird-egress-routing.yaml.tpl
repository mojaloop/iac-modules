# ServiceEntry for internal domain traffic (ambient mode with waypoint)
apiVersion: networking.istio.io/v1beta1
kind: ServiceEntry
metadata:
  name: netbird-traffic-wildcard
  namespace: istio-system
  annotations:
    argocd.argoproj.io/sync-wave: "${istio_gateways_sync_wave}"
  labels:
    istio.io/use-waypoint: ${istio_nb_egress_waypoint_name}
    istio.io/use-waypoint-namespace: ${istio_nb_egress_waypoint_namespace}
spec:
  exportTo:
    - "*" # Make it available mesh-wide
  hosts:
%{ for host in netbird_traffic_hosts ~}
  - "${host}"
%{ endfor ~}
  ports:
    - number: 443
      name: https
      protocol: HTTPS
  location: MESH_EXTERNAL
  resolution: DNS
---
# Waypoint proxy for ambient mode egress routing (cross-namespace with netbird sidecar)
apiVersion: gateway.networking.k8s.io/v1beta1
kind: Gateway
metadata:
  name: ${istio_nb_egress_waypoint_name}
  namespace: ${istio_nb_egress_waypoint_namespace}
  annotations:
    argocd.argoproj.io/sync-wave: "${istio_gateways_sync_wave}"
    #netbird.io/setup-key: istio-netbird-setup-key
spec:
  gatewayClassName: istio-waypoint
  listeners:
  - name: mesh
    port: 15008
    protocol: HBONE
    allowedRoutes:
      namespaces:
        from: All  # Allow cross-namespace usage
# %{ if cluster.master_node_count + cluster.agent_node_count >= 3 }
  infrastructure:
    parametersRef:
      group: ""
      kind: ConfigMap
      name: nb-egress-waypoint
---
kind: ConfigMap
apiVersion: v1
metadata:
  name: nb-egress-waypoint
data:
  deployment: |
    spec:
      replicas: 3
      template:
        spec:
          topologySpreadConstraints:
          - maxSkew: 1
            topologyKey: "topology.kubernetes.io/zone"
            whenUnsatisfiable: ScheduleAnyway
            labelSelector:
              matchLabels:
                gateway.networking.k8s.io/gateway-name: nb-egress-waypoint
          - maxSkew: 1
            topologyKey: "kubernetes.io/hostname"
            whenUnsatisfiable: DoNotSchedule
            labelSelector:
              matchLabels:
                gateway.networking.k8s.io/gateway-name: nb-egress-waypoint
# %{ endif }
---
# apiVersion: external-secrets.io/v1beta1
# kind: ExternalSecret
# metadata:
#   annotations:
#     argocd.argoproj.io/sync-wave: "${external_secret_sync_wave}"
#   name: istio-netbird-setup-key
#   namespace: ${istio_nb_egress_waypoint_namespace}
# spec:
#   refreshInterval: 5m

#   secretStoreRef:
#     kind: ClusterSecretStore
#     name: tenant-vault-secret-store

#   target:
#     name: istio-netbird-setup-key
#     creationPolicy: Owner
#     template:
#       data:
#         setup-key: "{{ .NB_SETUP_KEY  | toString }}"

#   data:
#     - secretKey: NB_SETUP_KEY
#       remoteRef:
#         key: ${netbird_setup_key_vault_path}
#         property: value
# ---
# apiVersion: netbird.io/v1
# kind: NBSetupKey
# metadata:
#   name: istio-netbird-setup-key
#   namespace: ${istio_nb_egress_waypoint_namespace}
#   annotations:
#     argocd.argoproj.io/sync-wave: "${istio_gateways_sync_wave}"
# spec:
#   managementURL: ${netbird_management_url}
#   secretKeyRef:
#     name: istio-netbird-setup-key
#     key: setup-key
