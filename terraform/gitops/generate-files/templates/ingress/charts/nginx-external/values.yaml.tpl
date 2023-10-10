ingress-nginx:
  serviceAccount:
    name: ${external_nginx_service_account_name}
  controller:
    kind: "DaemonSet"
    autoscaling: 
      enabled: false
    publishService:
      enabled: false
    ingressClassByName: true
    extraArgs:
      publish-status-address: ${external_load_balancer_dns}
      enable-ssl-passthrough: false
      default-ssl-certificate: "default/${default_ssl_certificate}"
    service:
      externalTrafficPolicy: "Local"
      type: NodePort
      nodePorts:
        http: ${external_ingress_http_port}
        https: ${external_ingress_https_port}
    ingressClass: ${external_ingress_class_name}
    ingressClassResource:
      enabled: true
      default: false
      name: ${external_ingress_class_name}
      controllerValue: "k8s.io/${external_ingress_class_name}"
    admissionWebhooks:
      failurePolicy: "Ignore"
    config:
      use-proxy-protocol: true
      enable-real-ip: true
      real-ip-header: "proxy_protocol"
      proxy-buffer-size: "16k"
