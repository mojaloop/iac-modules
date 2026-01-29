image:
  repository: mojaloop/ml-ory-iam-services
  tag: "${ml_ory_services_image_version}"

ketoBatchAuth:
  enabled: true
  env:
    KETO_READ_URL: "${keto_read_url}"

kratosRoleWebhook:
  enabled: true
  env:
    KRATOS_ADMIN_URL: "http://kratos-admin.${ory_namespace}.svc.cluster.local:80"
    KETO_READ_URL: "${keto_read_url}"
