realm: dfsps
enabled: true
clients:
  - clientId: connection-manager-api-service
    secret: ${dfsp_api_service_secret}
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
      access.token.lifespan: "43200"
  - clientId: connection-manager-auth-client
    secret: ${dfsp_auth_client_secret}
    enabled: true
    clientAuthenticatorType: client-secret
    redirectUris:
      - "https://${mcm_fqdn}/api/auth/callback"
      - "https://${mcm_fqdn}/*"
    webOrigins:
      - "https://${mcm_fqdn}"
    publicClient: false
    protocol: openid-connect
    serviceAccountsEnabled: false
    standardFlowEnabled: true
    directAccessGrantsEnabled: false
    authorizationServicesEnabled: false
    implicitFlowEnabled: false
    attributes:
      access.token.lifespan: "43200"
    protocolMappers:
      - name: groups
        protocol: openid-connect
        protocolMapper: oidc-group-membership-mapper
        consentRequired: false
        config:
          full.path: "true"
          id.token.claim: "true"
          access.token.claim: "true"
          claim.name: groups
          userinfo.token.claim: "true"
      - name: realm roles
        protocol: openid-connect
        protocolMapper: oidc-usermodel-realm-role-mapper
        consentRequired: false
        config:
          multivalued: "true"
          id.token.claim: "true"
          access.token.claim: "true"
          claim.name: realm_roles
          userinfo.token.claim: "true"
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
    - name: hub-admin
      description: Administrator role for hub operations
groups:
  - name: Application
    subGroups:
      - name: MTA
        attributes:
          description: 
            - "Mojabox Technical Administrators"
      - name: PTA
        attributes:
          description: 
            - "Portal Technical Administrators"
users:
  - username: service-account-connection-manager-api-service
    emailVerified: false
    enabled: true
    totp: false
    serviceAccountClientId: connection-manager-api-service
    disableableCredentialTypes: []
    requiredActions: []
    realmRoles:
      - default-roles-dfsps
      - dfsp-admin
    clientRoles: {}
    notBefore: 0
    groups: []
  - username: ${dfsps_admin_username}
    email: ${dfsps_admin_email}
    emailVerified: true
    enabled: true
    firstName: DFSP
    lastName: Admin
    credentials:
      - type: password
        value: ${dfsps_admin_password}
        temporary: true
    clientRoles: {}
    requiredActions: []
    notBefore: 0
    groups: 
      - "Application/PTA"
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
  contentSecurityPolicyReportOnly: ""
  xContentTypeOptions: nosniff
  xRobotsTag: none
  xFrameOptions: SAMEORIGIN
  contentSecurityPolicy: "frame-src 'self'; frame-ancestors 'self'; object-src 'none';"
  xXSSProtection: "1; mode=block"
  strictTransportSecurity: "max-age=31536000; includeSubDomains"
smtpServer:
  from: ${smtp_from}
  fromDisplayName: ${smtp_from_display_name}
  replyTo: ${smtp_reply_to}
  host: ${smtp_host}
  port: ${smtp_port}
  ssl: ${smtp_ssl}
  starttls: ${smtp_starttls}
  auth: ${smtp_auth}
eventsEnabled: true
eventsListeners:
  - jboss-logging
enabledEventTypes: []
adminEventsEnabled: true
adminEventsDetailsEnabled: true 