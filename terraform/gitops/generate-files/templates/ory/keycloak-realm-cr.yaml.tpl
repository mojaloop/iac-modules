apiVersion: k8s.keycloak.org/v2alpha1
kind: KeycloakRealmImport
metadata:
  name: ${keycloak_hubop_realm_name}
  namespace: ${keycloak_namespace}
spec:
  keycloakCRName: ${keycloak_name}
  realm:
    realm: ${keycloak_hubop_realm_name}
    displayName: ${keycloak_hubop_realm_display_name}
    enabled: true
    registrationEmailAsUsername: true
    clients:
    - clientId: ${hubop_oidc_client_id}
      secret: ${hubop_oidc_client_secret_secret_name}
      enabled: true
      clientAuthenticatorType: client-secret
      redirectUris:
      - "*"
      - https://${auth_fqdn}/*
      webOrigins:
      - "*"
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
      - name: hub-admin
        description: Administrator role for hub operations
    groups:
    - name: Application
      subGroups:
      - name: MTA
        attributes:
          description:
          - Mojabox Technical Administrators
      - name: PTA
        attributes:
          description:
          - Portal Technical Administrators
    users:
    - username: ${role_assign_svc_user}
      enabled: true
      email: ${role_assign_svc_user}@none.com
      firstName: Role
      lastName: Assign
      credentials:
      - type: password
        value: ${role_assign_svc_secret_name}
      clientRoles:
        realm-management:
        - view-users
      groups: []
    - username: "${portal_admin_user}"
      email: ${portal_admin_user}@none.com
      emailVerified: true
      enabled: true
      firstName: Portal
      lastName: Admin
      credentials:
      - type: password
        value: ${portal_admin_secret_name}
      clientRoles: {}
      requiredActions: []
      notBefore: 0
      groups:
      - Application/PTA
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
