ingress-nginx:
  controller:
    kind: "DaemonSet"
    autoscaling: 
      enabled: false
    publishService:
      enabled: false
    ingressClassByName: true
    extraArgs:
      publish-status-address: ${internal_load_balancer_dns}
      enable-ssl-passthrough: false
      default-ssl-certificate: "default/${default_ssl_certificate}"
    service:
      externalTrafficPolicy: "Local"
      type: NodePort
      nodePorts:
        http: ${internal_ingress_http_port}
        https: ${internal_ingress_https_port}
    ingressClass: ${internal_ingress_class_name}
    ingressClassResource:
      enabled: true
      default: false
      name: ${internal_ingress_class_name}
      controllerValue: "k8s.io/${internal_ingress_class_name}"
    admissionWebhooks:
      failurePolicy: "Ignore"
    config:
      use-proxy-protocol: false
      enable-real-ip: false
      proxy-buffer-size: "16k"