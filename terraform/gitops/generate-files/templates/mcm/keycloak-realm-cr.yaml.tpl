apiVersion: k8s.keycloak.org/v2alpha1
kind: KeycloakRealmImport
metadata:
  name: ${keycloak_dfsp_realm_name}
  namespace: ${keycloak_namespace}
spec:
  keycloakCRName: ${keycloak_name}
  realm:
    realm: ${keycloak_dfsp_realm_name}
    displayName: ${keycloak_dfsp_realm_display_name}
    enabled: true
    registrationEmailAsUsername: true
    clients:
    - clientId: connection-manager-api-service
      secret: ${mcm_dfsp_admin_client_secret_name}
      enabled: true
      clientAuthenticatorType: client-secret
      redirectUris: []
      webOrigins: []
      publicClient: false
      protocol: openid-connect
      serviceAccountsEnabled: true
      standardFlowEnabled: false
      directAccessGrantsEnabled: false
      authorizationServicesEnabled: false
      implicitFlowEnabled: false
      attributes:
        access.token.lifespan: "${keycloak_access_token_lifespan}"
    - clientId: ${dfsp_oidc_client_id}
      secret: ${dfsp_oidc_client_secret_name}
      enabled: true
      clientAuthenticatorType: client-secret
      redirectUris:
      - "*"
      - https://${mcm_fqdn}/api/auth/callback
      - https://${mcm_fqdn}/*
      - https://${auth_fqdn}/*
      webOrigins:
      - "*"
      - https://${mcm_fqdn}
      - https://${auth_fqdn}
      publicClient: false
      protocol: openid-connect
      serviceAccountsEnabled: false
      standardFlowEnabled: true
      directAccessGrantsEnabled: false
      authorizationServicesEnabled: false
      implicitFlowEnabled: false
      attributes:
        access.token.lifespan: "${keycloak_access_token_lifespan}"
      protocolMappers:
      - name: groups
        protocol: openid-connect
        protocolMapper: oidc-group-membership-mapper
        consentRequired: false
        config:
          full.path: 'true'
          id.token.claim: 'true'
          access.token.claim: 'true'
          claim.name: groups
          userinfo.token.claim: 'true'
      - name: realm roles
        protocol: openid-connect
        protocolMapper: oidc-usermodel-realm-role-mapper
        consentRequired: false
        config:
          multivalued: 'true'
          id.token.claim: 'true'
          access.token.claim: 'true'
          claim.name: realm_roles
          userinfo.token.claim: 'true'
    roles:
      realm:
      - name: dfsp-admin
        description: Administrator role for DFSP users
        composite: true
        composites:
          client:
            realm-management:
            - manage-users
            - view-users
            - manage-clients
            - view-clients
    groups:
    - name: Application
      subGroups:
      - name: DFSP
        attributes:
          description:
          - DFSP parent group for MCM-managed DFSP subgroups
    users:
    - username: service-account-connection-manager-api-service
      emailVerified: false
      enabled: true
      totp: false
      serviceAccountClientId: connection-manager-api-service
      disableableCredentialTypes: []
      requiredActions: []
      realmRoles:
      - default-roles-${keycloak_dfsp_realm_name}
      - dfsp-admin
      clientRoles: {}
      notBefore: 0
      groups: []
    clientScopeMappings:
      connection-manager-api-service:
      - client: realm-management
        roles:
        - dfsp-admin
    otpPolicyType: totp
    otpPolicyAlgorithm: HmacSHA1
    otpPolicyInitialCounter: 0
    otpPolicyDigits: 6
    otpPolicyLookAheadWindow: 1
    otpPolicyPeriod: 30
    browserSecurityHeaders:
      contentSecurityPolicyReportOnly: ''
      xContentTypeOptions: nosniff
      xRobotsTag: none
      xFrameOptions: SAMEORIGIN
      contentSecurityPolicy: frame-src 'self'; frame-ancestors 'self'; object-src 'none';
      xXSSProtection: 1; mode=block
      strictTransportSecurity: max-age=31536000; includeSubDomains
    smtpServer:
      from: "${smtp_from}"
      fromDisplayName: "${smtp_from_display_name}"
      replyTo: "${smtp_reply_to}"
      host: "${smtp_host}"
      port: "${smtp_port}"
      ssl: "${smtp_ssl}"
      starttls: "${smtp_starttls}"
      auth: "${smtp_auth}"
%{ if smtp_auth ~}
      user: "$${smtp_credentials_user}"
      password: "$${smtp_credentials_password}"
%{ endif ~}

    eventsEnabled: true
    eventsListeners:
    - jboss-logging
    enabledEventTypes: []
    adminEventsEnabled: true
    adminEventsDetailsEnabled: true
