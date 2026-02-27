apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  labels:
    istio.io/waypoint-for: service
  name: service-ingress-waypoint
spec:
  gatewayClassName: istio-waypoint
  listeners:
  - name: mesh
    port: 15008
    protocol: HBONE
# %{ if cluster.master_node_count + cluster.worker_node_count >= 3 }
  infrastructure:
    parametersRef:
      group: ""
      kind: ConfigMap
      name: service-ingress-waypoint
---
kind: ConfigMap
apiVersion: v1
metadata:
  name: service-ingress-waypoint
data:
  deployment: |
    spec:
      replicas: 3
      template:
        spec:
          topologySpreadConstraints:
          - maxSkew: 1
            topologyKey: "topology.kubernetes.io/zone"
            whenUnsatisfiable: ScheduleAnyway # Hard requirement for AZ spread
            labelSelector:
              matchLabels:
                gateway.networking.k8s.io/gateway-name: service-ingress-waypoint
          - maxSkew: 1
            topologyKey: "kubernetes.io/hostname"
            whenUnsatisfiable: DoNotSchedule # Soft requirement for node spread
            labelSelector:
              matchLabels:
                gateway.networking.k8s.io/gateway-name: service-ingress-waypoint
# %{ endif }
