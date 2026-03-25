%{ if cloud_provider == "private-cloud" ~}
engines:
  local:
    lvm:
      enabled: false
    zfs:
      enabled: false
  replicated:
    mayastor:
      enabled: false
alloy:
  enabled: false
  affinity:
    podAntiAffinity:
      preferredDuringSchedulingIgnoredDuringExecution:
        - weight: 100
          podAffinityTerm:
            labelSelector:
              matchLabels:
                app.kubernetes.io/name: alloy
            topologyKey: kubernetes.io/hostname
  controller:
    tolerations:
      - operator: "Exists"
loki:
  enabled: false
  singleBinary:
    podAntiAffinity: soft
    podAntiAffinityTopologyKey: kubernetes.io/hostname
    affinity:
      podAntiAffinity:
        requiredDuringSchedulingIgnoredDuringExecution: []
        preferredDuringSchedulingIgnoredDuringExecution:
          - weight: 100
            podAffinityTerm:
              labelSelector:
                matchLabels:
                  app.kubernetes.io/component: single-binary
              topologyKey: kubernetes.io/hostname
%{ endif ~}
