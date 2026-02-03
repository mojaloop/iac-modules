# Enable ambient profile
profile: ambient

global:
  # Default hub for Istio images.
  hub: docker.io/istio
  # Default tag for Istio images.
  # Specify image pull policy if default behavior isn't desired.
  # Default behavior: latest images will be Always else IfNotPresent.
  imagePullPolicy: ""
  # Default logging level for Istio components
  logging:
    level: ${istio_proxy_log_level}
  logAsJson: false
  # Default resources allocated
  defaultResources:
    requests:
      cpu: 100m
      memory: 100Mi
%{ if istio_cni_platform != "none" ~}
  platform: ${istio_cni_platform}
%{ endif ~}

# CNI-and-platform specific path defaults.
cni:
%{ if istio_cni_platform == "none" ~}
  cniBinDir: /opt/cni/bin
  cniConfDir: /etc/cni/net.d
  cniConfFileName: ""
  cniNetnsDir: "/var/run/netns"
  istioOwnedCNIConfig : true
%{ elseif istio_cni_platform == "microk8s" ~}
  cniBinDir: /var/snap/microk8s/current/opt/cni/bin
  cniConfDir: /var/snap/microk8s/current/args/cni-network
  cniConfFileName: ""
  cniNetnsDir: "/var/run/netns"
  istioOwnedCNIConfig : false
%{ endif ~}

excludeNamespaces:
  - kube-system
  - istio-system

# Configure ambient settings
ambient:
  # If enabled, ambient redirection will be enabled
  enabled: true
  # Set ambient config dir path: defaults to /etc/ambient-config
  configDir: ""
  # If enabled, and ambient is enabled, DNS redirection will be enabled
  dnsCapture: true
  # If enabled, and ambient is enabled, enables ipv6 support
  ipv6: false
  # If enabled, and ambient is enabled, the CNI agent will reconcile incompatible iptables rules and chains at startup.
  reconcileIptablesOnStartup: true
  # If enabled, and ambient is enabled, the CNI agent will always share the network namespace of the host node it is running on
  shareHostNetworkNamespace: false

repair:
  enabled: true
  deletePods: true
