apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt
  annotations:
    argocd.argoproj.io/sync-wave: "${cert_manager_issuer_sync_wave}"
spec:
  acme:
    # You must replace this email address with your own.
    # Let's Encrypt will use this to contact you about expiring
    # certificates, and issues related to your account.
    email: ${letsencrypt_email}
    server: ${letsencrypt_server}
    privateKeySecretRef:
      # Secret resource that will be used to store the account's private key.
      name: letsencrypt-issuer-account-key
    solvers:
    - selector:
        dnsZones:
          - "${public_domain}"
      dns01:
        route53:
          region: ${cloud_region}
          accessKeyIDSecretRef:
            name: ${cert_manager_credentials_secret}
            key: AWS_ACCESS_KEY_ID
          secretAccessKeySecretRef:
            name: ${cert_manager_credentials_secret}
            key: AWS_SECRET_ACCESS_KEY