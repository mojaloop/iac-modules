argocd_override:
  initial_application_gitrepo_tag: "${iac_terraform_modules_tag}"
  apps:        
    utils:
      application_gitrepo_tag: "${iac_terraform_modules_tag}"
      sub_apps:
        argocd_helm:
          public_ingress_access_domain: "${argocd_public_access}"
          helm_version: "${argocd_helm_version}"
        rook_ceph:
          helm_version: "${rook_ceph_helm_version}"
        reflector:
          helm_version: "${reflector_helm_version}"
        reloader:
          helm_version: "${reloader_helm_version}"
        crossplane:
          helm_version: "${crossplane_helm_version}"
          debug: "${crossplane_log_level}"
        kubernetes_secret_generator:
          helm_version: "${kubernetes_secret_generator_helm_version}"
        external_secrets:
          helm_version: "${external_secrets_helm_version}"
        istio:
          proxy_log_level: "${istio_proxy_log_level}"
          helm_version: "${istio_helm_version}"
          external_ingress_https_port: "'${external_ingress_https_port}'"
          external_ingress_http_port: "'${external_ingress_http_port}'"
          external_ingress_health_port: "'${external_ingress_health_port}'"
          internal_ingress_https_port: "'${internal_ingress_https_port}'"
          internal_ingress_http_port: "'${internal_ingress_http_port}'"
          internal_ingress_health_port: "'${internal_ingress_health_port}'"
        cert_manager:
          helm_version: "${cert_manager_helm_version}"
        consul:
          helm_version: "${consul_helm_version}"
          replicas: "'${consul_replica_count}'"
          storage_size: "${consul_storage_size}"
        post_config:
          vault_crossplane_modules_version: "${vault_crossplane_modules_version}"
          terraform_crossplane_modules_version: "${terraform_crossplane_modules_version}"
          ansible_crossplane_modules_version: "${ansible_crossplane_modules_version}"
    dns_utils:
      application_gitrepo_tag: "${iac_terraform_modules_tag}"
      sub_apps:
        ext_dns:
          helm_version: "${external_dns_helm_version}"
        cr_config:
          internal_load_balancer_dns: "${internal_load_balancer_dns}"
          external_load_balancer_dns: "${external_load_balancer_dns}"
          dns_public_subdomain: "${dns_public_subdomain}"
          dns_private_subdomain: "${dns_private_subdomain}"
          ext_dns_cloud_policy: "${ext_dns_cloud_policy}"
          letsencrypt_email: "${letsencrypt_email}"
          ext_dns_cloud_policy: "${ext_dns_cloud_policy}"
          dns_cloud_api_region: "${cloud_region}"
    vault:
      application_gitrepo_tag: "${iac_terraform_modules_tag}"
      sub_apps:
        vault:
          helm_version: "${vault_helm_version}"
          public_ingress_access_domain: "${vault_public_access}"
          vault_tf_provider_version: "${vault_tf_provider_version}"
          vault_terraform_modules_tag: "${iac_terraform_modules_tag}"
          vault_log_level: "${vault_log_level}"
          cloud_platform_api_client_id: "${cloud_platform_api_client_id}"
          cloud_platform_api_client_secret: "${cloud_platform_api_client_secret}"
        vault_config_operator:
          helm_version: "${vault_config_operator_helm_version}"
    security:
      application_gitrepo_tag: "${iac_terraform_modules_tag}"
      sub_apps:
        zitadel:
          public_ingress_access_domain: "${zitadel_public_access}"
          terraform_modules_tag: "${iac_terraform_modules_tag}"
          helm_version: "${zitadel_helm_version}"
          zitadel_tf_provider_version: "${zitadel_tf_provider_version}"
          vault_rbac_admin_group: "${vault_rbac_admin_group}"
          argocd_user_rbac_group: "${argocd_user_rbac_group}"
          argocd_admin_rbac_group: "${argocd_admin_rbac_group}"
        cockroachdb:
          helm_version: "${cockroachdb_helm_version}"
          pvc_size: "${cockroachdb_storage_size}"
        netbird:
          stunner_nodeport_port: "'${wireguard_ingress_port}'"
          terraform_modules_tag: "${iac_terraform_modules_tag}"
          public_ingress_access_domain: "${netbird_public_access}"
          helm_version: "${netbird_helm_version}"
          dashboard_chart_version: "${netbird_dashboard_helm_version}"
          image_version: "${netbird_image_version}"
        
    nexus:
      application_gitrepo_tag: "${iac_terraform_modules_tag}"
      sub_apps:
        nexus:
          helm_version: "${nexus_helm_version}"
          public_ingress_access_domain: "${nexus_public_access}"
        post_config:
          ansible_collection_tag: ${nexus_ansible_collection_tag}
