ml-testing-toolkit-backend:
  ingress:
    enabled: false
ml-testing-toolkit-frontend:
  ingress:
    enabled: false
  config:
    API_BASE_URL: https://${ttk_backend_public_fqdn}