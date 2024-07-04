argocd_override:
  initial_application_gitrepo_tag: "${application_gitrepo_tag}"
  apps:        
    utils:
      application_gitrepo_tag: "${application_gitrepo_tag}"
      sub_apps:
        argocd_helm:
          dns_public_subdomain: "${dns_public_subdomain}"
          dns_private_subdomain: "${dns_private_subdomain}"
        istio:
          external_ingress_https_port: "'${external_ingress_https_port}'"
          external_ingress_http_port: "'${external_ingress_http_port}'"
          external_ingress_health_port: "'${external_ingress_health_port}'"
          internal_ingress_https_port: "'${internal_ingress_https_port}'"
          internal_ingress_http_port: "'${internal_ingress_http_port}'"
          internal_ingress_health_port: "'${internal_ingress_health_port}'"
    dns_utils:
      application_gitrepo_tag: "${application_gitrepo_tag}"
      sub_apps:
        ext_dns:
          dns_public_subdomain: "${dns_public_subdomain}"
          dns_private_subdomain: "${dns_private_subdomain}"
          dns_cloud_api_region: "${dns_cloud_api_region}"
        cr_config:
          internal_load_balancer_dns: "${internal_load_balancer_dns}"
          external_load_balancer_dns: "${external_load_balancer_dns}"
          dns_public_subdomain: "${dns_public_subdomain}"
          dns_private_subdomain: "${dns_private_subdomain}"
          ext_dns_cloud_policy: "${ext_dns_cloud_policy}"
          letsencrypt_email: "${letsencrypt_email}"
          ext_dns_cloud_policy: "${ext_dns_cloud_policy}"
    vault:
      application_gitrepo_tag: "${application_gitrepo_tag}"
      sub_apps:
        vault:
          vault_terraform_modules_tag: "${application_gitrepo_tag}"
          dns_public_subdomain: "${dns_public_subdomain}"
          dns_private_subdomain: "${dns_private_subdomain}"
          cloud_platform_api_client_id: "${cloud_platform_api_client_id}"
          cloud_platform_api_client_secret: "${cloud_platform_api_client_secret}"
    zitadel:
      application_gitrepo_tag: "${application_gitrepo_tag}"
      sub_apps:
        zitadel:
          terraform_modules_tag: "${application_gitrepo_tag}"
          dns_public_subdomain: "${dns_public_subdomain}"
          dns_private_subdomain: "${dns_private_subdomain}"
    netbird:
      application_gitrepo_tag: "${application_gitrepo_tag}"
      sub_apps:
        netbird:
          stunner_nodeport_port: "'${wireguard_ingress_port}'"
          terraform_modules_tag: "${application_gitrepo_tag}"
          dns_public_subdomain: "${dns_public_subdomain}"
          dns_private_subdomain: "${dns_private_subdomain}"
