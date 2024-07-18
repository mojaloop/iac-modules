apiVersion: k8s.keycloak.org/v2alpha1
kind: KeycloakRealmImport
metadata:
  name: ${keycloak_dfsp_realm_name}
  namespace: ${keycloak_namespace}
spec:
  keycloakCRName: ${keycloak_name}
  realm:
    realm: ${keycloak_dfsp_realm_name}
    notBefore: 0
    defaultSignatureAlgorithm: RS256
    revokeRefreshToken: false
    refreshTokenMaxReuse: 0
    accessTokenLifespan: 300
    accessTokenLifespanForImplicitFlow: 900
    ssoSessionIdleTimeout: 1800
    ssoSessionMaxLifespan: 36000
    ssoSessionIdleTimeoutRememberMe: 0
    ssoSessionMaxLifespanRememberMe: 0
    offlineSessionIdleTimeout: 2592000
    offlineSessionMaxLifespanEnabled: false
    offlineSessionMaxLifespan: 5184000
    clientSessionIdleTimeout: 0
    clientSessionMaxLifespan: 0
    clientOfflineSessionIdleTimeout: 0
    clientOfflineSessionMaxLifespan: 0
    accessCodeLifespan: 60
    accessCodeLifespanUserAction: 300
    accessCodeLifespanLogin: 1800
    actionTokenGeneratedByAdminLifespan: 43200
    actionTokenGeneratedByUserLifespan: 300
    oauth2DeviceCodeLifespan: 600
    oauth2DevicePollingInterval: 5
    enabled: true
    sslRequired: external
    registrationAllowed: false
    registrationEmailAsUsername: false
    rememberMe: false
    verifyEmail: false
    loginWithEmailAllowed: true
    duplicateEmailsAllowed: false
    resetPasswordAllowed: false
    editUsernameAllowed: false
    bruteForceProtected: false
    permanentLockout: false
    maxFailureWaitSeconds: 900
    minimumQuickLoginWaitSeconds: 60
    waitIncrementSeconds: 60
    quickLoginCheckMilliSeconds: 1000
    maxDeltaTimeSeconds: 43200
    failureFactor: 30
    defaultRole:
      name: default-roles-${keycloak_dfsp_realm_name}
      description: '$${role_default-roles}'
      composite: true
      clientRole: false
    requiredCredentials:
    - password
    otpPolicyType: totp
    otpPolicyAlgorithm: HmacSHA1
    otpPolicyInitialCounter: 0
    otpPolicyDigits: 6
    otpPolicyLookAheadWindow: 1
    otpPolicyPeriod: 30
    otpPolicyCodeReusable: false
    otpSupportedApplications:
    - totpAppMicrosoftAuthenticatorName
    - totpAppFreeOTPName
    - totpAppGoogleName
    webAuthnPolicyRpEntityName: keycloak
    webAuthnPolicySignatureAlgorithms:
    - ES256
    webAuthnPolicyRpId: ''
    webAuthnPolicyAttestationConveyancePreference: not specified
    webAuthnPolicyAuthenticatorAttachment: not specified
    webAuthnPolicyRequireResidentKey: not specified
    webAuthnPolicyUserVerificationRequirement: not specified
    webAuthnPolicyCreateTimeout: 0
    webAuthnPolicyAvoidSameAuthenticatorRegister: false
    webAuthnPolicyAcceptableAaguids: []
    webAuthnPolicyPasswordlessRpEntityName: keycloak
    webAuthnPolicyPasswordlessSignatureAlgorithms:
    - ES256
    webAuthnPolicyPasswordlessRpId: ''
    webAuthnPolicyPasswordlessAttestationConveyancePreference: not specified
    webAuthnPolicyPasswordlessAuthenticatorAttachment: not specified
    webAuthnPolicyPasswordlessRequireResidentKey: not specified
    webAuthnPolicyPasswordlessUserVerificationRequirement: not specified
    webAuthnPolicyPasswordlessCreateTimeout: 0
    webAuthnPolicyPasswordlessAvoidSameAuthenticatorRegister: false
    webAuthnPolicyPasswordlessAcceptableAaguids: []
    users:
    - createdTimestamp: 1690377454835
      username: service-account-dfsp-jwt
      enabled: true
      totp: false
      emailVerified: false
      serviceAccountClientId: dfsp-jwt
      disableableCredentialTypes: []
      requiredActions: []
      notBefore: 0
    scopeMappings:
    - clientScope: offline_access
      roles:
      - offline_access
    clientScopeMappings:
      account:
      - client: account-console
        roles:
        - manage-account
        - view-groups
    clients:
    - clientId: account
      name: '$${client_account}'
      rootUrl: '$${authBaseUrl}'
      baseUrl: /realms/${keycloak_dfsp_realm_name}/account/
      surrogateAuthRequired: false
      enabled: true
      alwaysDisplayInConsole: false
      clientAuthenticatorType: client-secret
      redirectUris:
      - /realms/${keycloak_dfsp_realm_name}/account/*
      webOrigins: []
      notBefore: 0
      bearerOnly: false
      consentRequired: false
      standardFlowEnabled: true
      implicitFlowEnabled: false
      directAccessGrantsEnabled: false
      serviceAccountsEnabled: false
      publicClient: true
      frontchannelLogout: false
      protocol: openid-connect
      attributes:
        post.logout.redirect.uris: +
      authenticationFlowBindingOverrides: {}
      fullScopeAllowed: false
      nodeReRegistrationTimeout: 0
      defaultClientScopes:
      - web-origins
      - acr
      - profile
      - roles
      - email
      optionalClientScopes:
      - address
      - phone
      - offline_access
      - microprofile-jwt
    - clientId: account-console
      name: '$${client_account-console}'
      rootUrl: '$${authBaseUrl}'
      baseUrl: /realms/${keycloak_dfsp_realm_name}/account/
      surrogateAuthRequired: false
      enabled: true
      alwaysDisplayInConsole: false
      clientAuthenticatorType: client-secret
      redirectUris:
      - /realms/${keycloak_dfsp_realm_name}/account/*
      webOrigins: []
      notBefore: 0
      bearerOnly: false
      consentRequired: false
      standardFlowEnabled: true
      implicitFlowEnabled: false
      directAccessGrantsEnabled: false
      serviceAccountsEnabled: false
      publicClient: true
      frontchannelLogout: false
      protocol: openid-connect
      attributes:
        post.logout.redirect.uris: +
        pkce.code.challenge.method: S256
      authenticationFlowBindingOverrides: {}
      fullScopeAllowed: false
      nodeReRegistrationTimeout: 0
      protocolMappers:
      - name: audience resolve
        protocol: openid-connect
        protocolMapper: oidc-audience-resolve-mapper
        consentRequired: false
        config: {}
      defaultClientScopes:
      - web-origins
      - acr
      - profile
      - roles
      - email
      optionalClientScopes:
      - address
      - phone
      - offline_access
      - microprofile-jwt
    - clientId: admin-cli
      name: '$${client_admin-cli}'
      surrogateAuthRequired: false
      enabled: true
      alwaysDisplayInConsole: false
      clientAuthenticatorType: client-secret
      redirectUris: []
      webOrigins: []
      notBefore: 0
      bearerOnly: false
      consentRequired: false
      standardFlowEnabled: false
      implicitFlowEnabled: false
      directAccessGrantsEnabled: true
      serviceAccountsEnabled: false
      publicClient: true
      frontchannelLogout: false
      protocol: openid-connect
      attributes:
        post.logout.redirect.uris: "+"
      authenticationFlowBindingOverrides: {}
      fullScopeAllowed: false
      nodeReRegistrationTimeout: 0
      defaultClientScopes:
      - web-origins
      - acr
      - profile
      - roles
      - email
      optionalClientScopes:
      - address
      - phone
      - offline_access
      - microprofile-jwt
    - clientId: broker
      name: '$${client_broker}'
      surrogateAuthRequired: false
      enabled: true
      alwaysDisplayInConsole: false
      clientAuthenticatorType: client-secret
      redirectUris: []
      webOrigins: []
      notBefore: 0
      bearerOnly: true
      consentRequired: false
      standardFlowEnabled: true
      implicitFlowEnabled: false
      directAccessGrantsEnabled: false
      serviceAccountsEnabled: false
      publicClient: false
      frontchannelLogout: false
      protocol: openid-connect
      attributes:
        post.logout.redirect.uris: "+"
      authenticationFlowBindingOverrides: {}
      fullScopeAllowed: false
      nodeReRegistrationTimeout: 0
      defaultClientScopes:
      - web-origins
      - acr
      - profile
      - roles
      - email
      optionalClientScopes:
      - address
      - phone
      - offline_access
      - microprofile-jwt
    - clientId: dfsp-jwt
      name: dfsp-jwt
      description: ''
      rootUrl: ''
      adminUrl: ''
      baseUrl: ''
      surrogateAuthRequired: false
      enabled: true
      alwaysDisplayInConsole: false
      clientAuthenticatorType: client-secret
      secret: ${jwt_client_secret_secret_name}
      redirectUris:
      - /*
      webOrigins:
      - /*
      notBefore: 0
      bearerOnly: false
      consentRequired: false
      standardFlowEnabled: true
      implicitFlowEnabled: false
      directAccessGrantsEnabled: true
      serviceAccountsEnabled: true
      publicClient: false
      frontchannelLogout: true
      protocol: openid-connect
      attributes:
        oidc.ciba.grant.enabled: 'false'
        oauth2.device.authorization.grant.enabled: 'false'
        client.secret.creation.time: '1690377454'
        backchannel.logout.session.required: 'true'
        post.logout.redirect.uris: "+"
        backchannel.logout.revoke.offline.tokens: 'false'
      authenticationFlowBindingOverrides: {}
      fullScopeAllowed: true
      nodeReRegistrationTimeout: -1
      protocolMappers:
      - name: Client Host
        protocol: openid-connect
        protocolMapper: oidc-usersessionmodel-note-mapper
        consentRequired: false
        config:
          user.session.note: clientHost
          userinfo.token.claim: 'true'
          id.token.claim: 'true'
          access.token.claim: 'true'
          claim.name: clientHost
          jsonType.label: String
      - name: Client ID
        protocol: openid-connect
        protocolMapper: oidc-usersessionmodel-note-mapper
        consentRequired: false
        config:
          user.session.note: client_id
          userinfo.token.claim: 'true'
          id.token.claim: 'true'
          access.token.claim: 'true'
          claim.name: client_id
          jsonType.label: String
      - name: Client IP Address
        protocol: openid-connect
        protocolMapper: oidc-usersessionmodel-note-mapper
        consentRequired: false
        config:
          user.session.note: clientAddress
          userinfo.token.claim: 'true'
          id.token.claim: 'true'
          access.token.claim: 'true'
          claim.name: clientAddress
          jsonType.label: String
      defaultClientScopes:
      - web-origins
      - acr
      - profile
      - roles
      - email
      optionalClientScopes:
      - address
      - phone
      - offline_access
      - microprofile-jwt
    - clientId: '${mcm_oidc_client_id}'
      name: '${mcm_oidc_client_id}'
      description: ''
      rootUrl: ''
      adminUrl: ''
      baseUrl: ''
      surrogateAuthRequired: false
      enabled: true
      alwaysDisplayInConsole: false
      clientAuthenticatorType: client-secret
      secret: ${mcm_oidc_client_secret_secret_name}
      redirectUris:
        - https://${mcm_fqdn}/login-callback
      webOrigins:
        - /*
      notBefore: 0
      bearerOnly: false
      consentRequired: false
      standardFlowEnabled: true
      implicitFlowEnabled: false
      directAccessGrantsEnabled: true
      serviceAccountsEnabled: false
      publicClient: false
      frontchannelLogout: true
      protocol: openid-connect
      attributes:
        oidc.ciba.grant.enabled: 'false'
        oauth2.device.authorization.grant.enabled: 'false'
        client.secret.creation.time: '1691150922'
        backchannel.logout.session.required: 'true'
        login_theme: keycloak
        post.logout.redirect.uris: "+"
        display.on.consent.screen: 'false'
        backchannel.logout.revoke.offline.tokens: 'false'
      authenticationFlowBindingOverrides: {}
      fullScopeAllowed: true
      nodeReRegistrationTimeout: -1
      defaultClientScopes:
        - web-origins
        - acr
        - profile
        - roles
        - email
      optionalClientScopes:
        - address
        - phone
        - offline_access
        - microprofile-jwt
    - clientId: realm-management
      name: '$${client_realm-management}'
      surrogateAuthRequired: false
      enabled: true
      alwaysDisplayInConsole: false
      clientAuthenticatorType: client-secret
      redirectUris: []
      webOrigins: []
      notBefore: 0
      bearerOnly: true
      consentRequired: false
      standardFlowEnabled: true
      implicitFlowEnabled: false
      directAccessGrantsEnabled: false
      serviceAccountsEnabled: false
      publicClient: false
      frontchannelLogout: false
      protocol: openid-connect
      attributes:
        post.logout.redirect.uris: "+"
      authenticationFlowBindingOverrides: {}
      fullScopeAllowed: false
      nodeReRegistrationTimeout: 0
      defaultClientScopes:
      - web-origins
      - acr
      - profile
      - roles
      - email
      optionalClientScopes:
      - address
      - phone
      - offline_access
      - microprofile-jwt
    - clientId: security-admin-console
      name: '$${client_security-admin-console}'
      rootUrl: '$${authAdminUrl}'
      baseUrl: /admin/${keycloak_dfsp_realm_name}/console/
      surrogateAuthRequired: false
      enabled: true
      alwaysDisplayInConsole: false
      clientAuthenticatorType: client-secret
      redirectUris:
      - /admin/${keycloak_dfsp_realm_name}/console/*
      webOrigins:
      - +
      notBefore: 0
      bearerOnly: false
      consentRequired: false
      standardFlowEnabled: true
      implicitFlowEnabled: false
      directAccessGrantsEnabled: false
      serviceAccountsEnabled: false
      publicClient: true
      frontchannelLogout: false
      protocol: openid-connect
      attributes:
        post.logout.redirect.uris: +
        pkce.code.challenge.method: S256
      authenticationFlowBindingOverrides: {}
      fullScopeAllowed: false
      nodeReRegistrationTimeout: 0
      protocolMappers:
      - name: locale
        protocol: openid-connect
        protocolMapper: oidc-usermodel-attribute-mapper
        consentRequired: false
        config:
          userinfo.token.claim: 'true'
          user.attribute: locale
          id.token.claim: 'true'
          access.token.claim: 'true'
          claim.name: locale
          jsonType.label: String
      defaultClientScopes:
      - web-origins
      - acr
      - profile
      - roles
      - email
      optionalClientScopes:
      - address
      - phone
      - offline_access
      - microprofile-jwt
# %{ for id, client in pm4mls }
    - clientId: ${id}
      name: ${id}
      enabled: ${client.pm4ml_enabled}
      clientAuthenticatorType: client-secret
      redirectUris: ['/*']
      webOrigins: ['/*']
      serviceAccountsEnabled: true
      protocol: openid-connect
# %{ endfor }
    clientScopes:
    - name: web-origins
      description: OpenID Connect scope for add allowed web origins to the access token
      protocol: openid-connect
      attributes:
        include.in.token.scope: 'false'
        display.on.consent.screen: 'false'
        consent.screen.text: ''
      protocolMappers:
      - name: allowed web origins
        protocol: openid-connect
        protocolMapper: oidc-allowed-origins-mapper
        consentRequired: false
        config: {}
    - name: offline_access
      description: 'OpenID Connect built-in scope: offline_access'
      protocol: openid-connect
      attributes:
        consent.screen.text: '$${offlineAccessScopeConsentText}'
        display.on.consent.screen: 'true'
    - name: profile
      description: 'OpenID Connect built-in scope: profile'
      protocol: openid-connect
      attributes:
        include.in.token.scope: 'true'
        display.on.consent.screen: 'true'
        consent.screen.text: '$${profileScopeConsentText}'
      protocolMappers:
      - name: nickname
        protocol: openid-connect
        protocolMapper: oidc-usermodel-attribute-mapper
        consentRequired: false
        config:
          userinfo.token.claim: 'true'
          user.attribute: nickname
          id.token.claim: 'true'
          access.token.claim: 'true'
          claim.name: nickname
          jsonType.label: String
      - name: middle name
        protocol: openid-connect
        protocolMapper: oidc-usermodel-attribute-mapper
        consentRequired: false
        config:
          userinfo.token.claim: 'true'
          user.attribute: middleName
          id.token.claim: 'true'
          access.token.claim: 'true'
          claim.name: middle_name
          jsonType.label: String
      - name: updated at
        protocol: openid-connect
        protocolMapper: oidc-usermodel-attribute-mapper
        consentRequired: false
        config:
          userinfo.token.claim: 'true'
          user.attribute: updatedAt
          id.token.claim: 'true'
          access.token.claim: 'true'
          claim.name: updated_at
          jsonType.label: long
      - name: birthdate
        protocol: openid-connect
        protocolMapper: oidc-usermodel-attribute-mapper
        consentRequired: false
        config:
          userinfo.token.claim: 'true'
          user.attribute: birthdate
          id.token.claim: 'true'
          access.token.claim: 'true'
          claim.name: birthdate
          jsonType.label: String
      - name: gender
        protocol: openid-connect
        protocolMapper: oidc-usermodel-attribute-mapper
        consentRequired: false
        config:
          userinfo.token.claim: 'true'
          user.attribute: gender
          id.token.claim: 'true'
          access.token.claim: 'true'
          claim.name: gender
          jsonType.label: String
      - name: given name
        protocol: openid-connect
        protocolMapper: oidc-usermodel-attribute-mapper
        consentRequired: false
        config:
          userinfo.token.claim: 'true'
          user.attribute: firstName
          id.token.claim: 'true'
          access.token.claim: 'true'
          claim.name: given_name
          jsonType.label: String
      - name: website
        protocol: openid-connect
        protocolMapper: oidc-usermodel-attribute-mapper
        consentRequired: false
        config:
          userinfo.token.claim: 'true'
          user.attribute: website
          id.token.claim: 'true'
          access.token.claim: 'true'
          claim.name: website
          jsonType.label: String
      - name: profile
        protocol: openid-connect
        protocolMapper: oidc-usermodel-attribute-mapper
        consentRequired: false
        config:
          userinfo.token.claim: 'true'
          user.attribute: profile
          id.token.claim: 'true'
          access.token.claim: 'true'
          claim.name: profile
          jsonType.label: String
      - name: full name
        protocol: openid-connect
        protocolMapper: oidc-full-name-mapper
        consentRequired: false
        config:
          id.token.claim: 'true'
          access.token.claim: 'true'
          userinfo.token.claim: 'true'
      - name: family name
        protocol: openid-connect
        protocolMapper: oidc-usermodel-attribute-mapper
        consentRequired: false
        config:
          userinfo.token.claim: 'true'
          user.attribute: lastName
          id.token.claim: 'true'
          access.token.claim: 'true'
          claim.name: family_name
          jsonType.label: String
      - name: zoneinfo
        protocol: openid-connect
        protocolMapper: oidc-usermodel-attribute-mapper
        consentRequired: false
        config:
          userinfo.token.claim: 'true'
          user.attribute: zoneinfo
          id.token.claim: 'true'
          access.token.claim: 'true'
          claim.name: zoneinfo
          jsonType.label: String
      - name: locale
        protocol: openid-connect
        protocolMapper: oidc-usermodel-attribute-mapper
        consentRequired: false
        config:
          userinfo.token.claim: 'true'
          user.attribute: locale
          id.token.claim: 'true'
          access.token.claim: 'true'
          claim.name: locale
          jsonType.label: String
      - name: username
        protocol: openid-connect
        protocolMapper: oidc-usermodel-attribute-mapper
        consentRequired: false
        config:
          userinfo.token.claim: 'true'
          user.attribute: username
          id.token.claim: 'true'
          access.token.claim: 'true'
          claim.name: preferred_username
          jsonType.label: String
      - name: picture
        protocol: openid-connect
        protocolMapper: oidc-usermodel-attribute-mapper
        consentRequired: false
        config:
          userinfo.token.claim: 'true'
          user.attribute: picture
          id.token.claim: 'true'
          access.token.claim: 'true'
          claim.name: picture
          jsonType.label: String
    - name: email
      description: 'OpenID Connect built-in scope: email'
      protocol: openid-connect
      attributes:
        include.in.token.scope: 'true'
        display.on.consent.screen: 'true'
        consent.screen.text: '$${emailScopeConsentText}'
      protocolMappers:
      - name: email
        protocol: openid-connect
        protocolMapper: oidc-usermodel-attribute-mapper
        consentRequired: false
        config:
          userinfo.token.claim: 'true'
          user.attribute: email
          id.token.claim: 'true'
          access.token.claim: 'true'
          claim.name: email
          jsonType.label: String
      - name: email verified
        protocol: openid-connect
        protocolMapper: oidc-usermodel-property-mapper
        consentRequired: false
        config:
          userinfo.token.claim: 'true'
          user.attribute: emailVerified
          id.token.claim: 'true'
          access.token.claim: 'true'
          claim.name: email_verified
          jsonType.label: boolean
    - name: roles
      description: OpenID Connect scope for add user roles to the access token
      protocol: openid-connect
      attributes:
        include.in.token.scope: 'false'
        display.on.consent.screen: 'true'
        consent.screen.text: '$${rolesScopeConsentText}'
      protocolMappers:
      - name: audience resolve
        protocol: openid-connect
        protocolMapper: oidc-audience-resolve-mapper
        consentRequired: false
        config: {}
      - name: realm roles
        protocol: openid-connect
        protocolMapper: oidc-usermodel-realm-role-mapper
        consentRequired: false
        config:
          user.attribute: foo
          access.token.claim: 'true'
          claim.name: realm_access.roles
          jsonType.label: String
          multivalued: 'true'
      - name: client roles
        protocol: openid-connect
        protocolMapper: oidc-usermodel-client-role-mapper
        consentRequired: false
        config:
          user.attribute: foo
          access.token.claim: 'true'
          claim.name: 'resource_access.$${client_id}.roles'
          jsonType.label: String
          multivalued: 'true'
    - name: microprofile-jwt
      description: Microprofile - JWT built-in scope
      protocol: openid-connect
      attributes:
        include.in.token.scope: 'true'
        display.on.consent.screen: 'false'
      protocolMappers:
      - name: upn
        protocol: openid-connect
        protocolMapper: oidc-usermodel-attribute-mapper
        consentRequired: false
        config:
          userinfo.token.claim: 'true'
          user.attribute: username
          id.token.claim: 'true'
          access.token.claim: 'true'
          claim.name: upn
          jsonType.label: String
      - name: groups
        protocol: openid-connect
        protocolMapper: oidc-usermodel-realm-role-mapper
        consentRequired: false
        config:
          multivalued: 'true'
          userinfo.token.claim: 'true'
          user.attribute: foo
          id.token.claim: 'true'
          access.token.claim: 'true'
          claim.name: groups
          jsonType.label: String
    - name: acr
      description: >-
        OpenID Connect scope for add acr (authentication context class reference) to the token
      protocol: openid-connect
      attributes:
        include.in.token.scope: 'false'
        display.on.consent.screen: 'false'
      protocolMappers:
      - name: acr loa level
        protocol: openid-connect
        protocolMapper: oidc-acr-mapper
        consentRequired: false
        config:
          id.token.claim: 'true'
          access.token.claim: 'true'
          userinfo.token.claim: 'true'
    - name: role_list
      description: SAML role list
      protocol: saml
      attributes:
        consent.screen.text: '$${samlRoleListScopeConsentText}'
        display.on.consent.screen: 'true'
      protocolMappers:
      - name: role list
        protocol: saml
        protocolMapper: saml-role-list-mapper
        consentRequired: false
        config:
          single: 'false'
          attribute.nameformat: Basic
          attribute.name: Role
    - name: phone
      description: 'OpenID Connect built-in scope: phone'
      protocol: openid-connect
      attributes:
        include.in.token.scope: 'true'
        display.on.consent.screen: 'true'
        consent.screen.text: '$${phoneScopeConsentText}'
      protocolMappers:
      - name: phone number
        protocol: openid-connect
        protocolMapper: oidc-usermodel-attribute-mapper
        consentRequired: false
        config:
          userinfo.token.claim: 'true'
          user.attribute: phoneNumber
          id.token.claim: 'true'
          access.token.claim: 'true'
          claim.name: phone_number
          jsonType.label: String
      - name: phone number verified
        protocol: openid-connect
        protocolMapper: oidc-usermodel-attribute-mapper
        consentRequired: false
        config:
          userinfo.token.claim: 'true'
          user.attribute: phoneNumberVerified
          id.token.claim: 'true'
          access.token.claim: 'true'
          claim.name: phone_number_verified
          jsonType.label: boolean
    - name: address
      description: 'OpenID Connect built-in scope: address'
      protocol: openid-connect
      attributes:
        include.in.token.scope: 'true'
        display.on.consent.screen: 'true'
        consent.screen.text: '$${addressScopeConsentText}'
      protocolMappers:
      - name: address
        protocol: openid-connect
        protocolMapper: oidc-address-mapper
        consentRequired: false
        config:
          user.attribute.formatted: formatted
          user.attribute.country: country
          user.attribute.postal_code: postal_code
          userinfo.token.claim: 'true'
          user.attribute.street: street
          id.token.claim: 'true'
          user.attribute.region: region
          access.token.claim: 'true'
          user.attribute.locality: locality
    defaultDefaultClientScopes:
    - role_list
    - profile
    - email
    - roles
    - web-origins
    - acr
    defaultOptionalClientScopes:
    - offline_access
    - address
    - phone
    - microprofile-jwt
    browserSecurityHeaders:
      contentSecurityPolicyReportOnly: ''
      xContentTypeOptions: nosniff
      referrerPolicy: no-referrer
      xRobotsTag: none
      xFrameOptions: SAMEORIGIN
      contentSecurityPolicy: frame-src 'self'; frame-ancestors 'self'; object-src 'none';
      xXSSProtection: 1; mode=block
      strictTransportSecurity: max-age=31536000; includeSubDomains
    smtpServer: {}
    eventsEnabled: false
    eventsListeners:
    - jboss-logging
    enabledEventTypes: []
    adminEventsEnabled: false
    adminEventsDetailsEnabled: false
    identityProviders: []
    identityProviderMappers: []
    components:
      org.keycloak.services.clientregistration.policy.ClientRegistrationPolicy:
      - name: Consent Required
        providerId: consent-required
        subType: anonymous
        subComponents: {}
        config: {}
      - name: Max Clients Limit
        providerId: max-clients
        subType: anonymous
        subComponents: {}
        config:
          max-clients:
          - '200'
      - name: Allowed Client Scopes
        providerId: allowed-client-templates
        subType: authenticated
        subComponents: {}
        config:
          allow-default-scopes:
          - 'true'
      - name: Allowed Protocol Mapper Types
        providerId: allowed-protocol-mappers
        subType: authenticated
        subComponents: {}
        config:
          allowed-protocol-mapper-types:
          - oidc-sha256-pairwise-sub-mapper
          - oidc-usermodel-property-mapper
          - oidc-address-mapper
          - saml-user-attribute-mapper
          - oidc-usermodel-attribute-mapper
          - saml-role-list-mapper
          - saml-user-property-mapper
          - oidc-full-name-mapper
      - name: Allowed Client Scopes
        providerId: allowed-client-templates
        subType: anonymous
        subComponents: {}
        config:
          allow-default-scopes:
          - 'true'
      - name: Trusted Hosts
        providerId: trusted-hosts
        subType: anonymous
        subComponents: {}
        config:
          host-sending-registration-request-must-match:
          - 'true'
          client-uris-must-match:
          - 'true'
      - name: Allowed Protocol Mapper Types
        providerId: allowed-protocol-mappers
        subType: anonymous
        subComponents: {}
        config:
          allowed-protocol-mapper-types:
          - oidc-full-name-mapper
          - oidc-address-mapper
          - oidc-sha256-pairwise-sub-mapper
          - saml-role-list-mapper
          - saml-user-property-mapper
          - saml-user-attribute-mapper
          - oidc-usermodel-attribute-mapper
          - oidc-usermodel-property-mapper
      - name: Full Scope Disabled
        providerId: scope
        subType: anonymous
        subComponents: {}
        config: {}
      org.keycloak.keys.KeyProvider:
      - name: aes-generated
        providerId: aes-generated
        subComponents: {}
        config:
          priority:
          - '100'
      - name: hmac-generated
        providerId: hmac-generated
        subComponents: {}
        config:
          priority:
          - '100'
          algorithm:
          - HS256
      - name: rsa-generated
        providerId: rsa-generated
        subComponents: {}
        config:
          priority:
          - '100'
      - name: rsa-enc-generated
        providerId: rsa-enc-generated
        subComponents: {}
        config:
          priority:
          - '100'
          algorithm:
          - RSA-OAEP
    internationalizationEnabled: false
    supportedLocales: []
    authenticationFlows:
    - alias: Account verification options
      description: Method with which to verity the existing account
      providerId: basic-flow
      topLevel: false
      builtIn: true
      authenticationExecutions:
      - authenticator: idp-email-verification
        authenticatorFlow: false
        requirement: ALTERNATIVE
        priority: 10
        autheticatorFlow: false
        userSetupAllowed: false
      - authenticatorFlow: true
        requirement: ALTERNATIVE
        priority: 20
        autheticatorFlow: true
        flowAlias: Verify Existing Account by Re-authentication
        userSetupAllowed: false
    - alias: Browser - Conditional OTP
      description: Flow to determine if the OTP is required for the authentication
      providerId: basic-flow
      topLevel: false
      builtIn: true
      authenticationExecutions:
      - authenticator: conditional-user-configured
        authenticatorFlow: false
        requirement: REQUIRED
        priority: 10
        autheticatorFlow: false
        userSetupAllowed: false
      - authenticator: auth-otp-form
        authenticatorFlow: false
        requirement: REQUIRED
        priority: 20
        autheticatorFlow: false
        userSetupAllowed: false
    - alias: Direct Grant - Conditional OTP
      description: Flow to determine if the OTP is required for the authentication
      providerId: basic-flow
      topLevel: false
      builtIn: true
      authenticationExecutions:
      - authenticator: conditional-user-configured
        authenticatorFlow: false
        requirement: REQUIRED
        priority: 10
        autheticatorFlow: false
        userSetupAllowed: false
      - authenticator: direct-grant-validate-otp
        authenticatorFlow: false
        requirement: REQUIRED
        priority: 20
        autheticatorFlow: false
        userSetupAllowed: false
    - alias: First broker login - Conditional OTP
      description: Flow to determine if the OTP is required for the authentication
      providerId: basic-flow
      topLevel: false
      builtIn: true
      authenticationExecutions:
      - authenticator: conditional-user-configured
        authenticatorFlow: false
        requirement: REQUIRED
        priority: 10
        autheticatorFlow: false
        userSetupAllowed: false
      - authenticator: auth-otp-form
        authenticatorFlow: false
        requirement: REQUIRED
        priority: 20
        autheticatorFlow: false
        userSetupAllowed: false
    - alias: Handle Existing Account
      description: >-
        Handle what to do if there is existing account with same email/username like authenticated identity provider
      providerId: basic-flow
      topLevel: false
      builtIn: true
      authenticationExecutions:
      - authenticator: idp-confirm-link
        authenticatorFlow: false
        requirement: REQUIRED
        priority: 10
        autheticatorFlow: false
        userSetupAllowed: false
      - authenticatorFlow: true
        requirement: REQUIRED
        priority: 20
        autheticatorFlow: true
        flowAlias: Account verification options
        userSetupAllowed: false
    - alias: Reset - Conditional OTP
      description: >-
        Flow to determine if the OTP should be reset or not. Set to REQUIRED to force.
      providerId: basic-flow
      topLevel: false
      builtIn: true
      authenticationExecutions:
      - authenticator: conditional-user-configured
        authenticatorFlow: false
        requirement: REQUIRED
        priority: 10
        autheticatorFlow: false
        userSetupAllowed: false
      - authenticator: reset-otp
        authenticatorFlow: false
        requirement: REQUIRED
        priority: 20
        autheticatorFlow: false
        userSetupAllowed: false
    - alias: User creation or linking
      description: Flow for the existing/non-existing user alternatives
      providerId: basic-flow
      topLevel: false
      builtIn: true
      authenticationExecutions:
      - authenticatorConfig: create unique user config
        authenticator: idp-create-user-if-unique
        authenticatorFlow: false
        requirement: ALTERNATIVE
        priority: 10
        autheticatorFlow: false
        userSetupAllowed: false
      - authenticatorFlow: true
        requirement: ALTERNATIVE
        priority: 20
        autheticatorFlow: true
        flowAlias: Handle Existing Account
        userSetupAllowed: false
    - alias: Verify Existing Account by Re-authentication
      description: Reauthentication of existing account
      providerId: basic-flow
      topLevel: false
      builtIn: true
      authenticationExecutions:
      - authenticator: idp-username-password-form
        authenticatorFlow: false
        requirement: REQUIRED
        priority: 10
        autheticatorFlow: false
        userSetupAllowed: false
      - authenticatorFlow: true
        requirement: CONDITIONAL
        priority: 20
        autheticatorFlow: true
        flowAlias: First broker login - Conditional OTP
        userSetupAllowed: false
    - alias: browser
      description: browser based authentication
      providerId: basic-flow
      topLevel: true
      builtIn: true
      authenticationExecutions:
      - authenticator: auth-cookie
        authenticatorFlow: false
        requirement: ALTERNATIVE
        priority: 10
        autheticatorFlow: false
        userSetupAllowed: false
      - authenticator: auth-spnego
        authenticatorFlow: false
        requirement: DISABLED
        priority: 20
        autheticatorFlow: false
        userSetupAllowed: false
      - authenticator: identity-provider-redirector
        authenticatorFlow: false
        requirement: ALTERNATIVE
        priority: 25
        autheticatorFlow: false
        userSetupAllowed: false
      - authenticatorFlow: true
        requirement: ALTERNATIVE
        priority: 30
        autheticatorFlow: true
        flowAlias: forms
        userSetupAllowed: false
    - alias: clients
      description: Base authentication for clients
      providerId: client-flow
      topLevel: true
      builtIn: true
      authenticationExecutions:
      - authenticator: client-secret
        authenticatorFlow: false
        requirement: ALTERNATIVE
        priority: 10
        autheticatorFlow: false
        userSetupAllowed: false
      - authenticator: client-jwt
        authenticatorFlow: false
        requirement: ALTERNATIVE
        priority: 20
        autheticatorFlow: false
        userSetupAllowed: false
      - authenticator: client-secret-jwt
        authenticatorFlow: false
        requirement: ALTERNATIVE
        priority: 30
        autheticatorFlow: false
        userSetupAllowed: false
      - authenticator: client-x509
        authenticatorFlow: false
        requirement: ALTERNATIVE
        priority: 40
        autheticatorFlow: false
        userSetupAllowed: false
    - alias: direct grant
      description: OpenID Connect Resource Owner Grant
      providerId: basic-flow
      topLevel: true
      builtIn: true
      authenticationExecutions:
      - authenticator: direct-grant-validate-username
        authenticatorFlow: false
        requirement: REQUIRED
        priority: 10
        autheticatorFlow: false
        userSetupAllowed: false
      - authenticator: direct-grant-validate-password
        authenticatorFlow: false
        requirement: REQUIRED
        priority: 20
        autheticatorFlow: false
        userSetupAllowed: false
      - authenticatorFlow: true
        requirement: CONDITIONAL
        priority: 30
        autheticatorFlow: true
        flowAlias: Direct Grant - Conditional OTP
        userSetupAllowed: false
    - alias: docker auth
      description: Used by Docker clients to authenticate against the IDP
      providerId: basic-flow
      topLevel: true
      builtIn: true
      authenticationExecutions:
      - authenticator: docker-http-basic-authenticator
        authenticatorFlow: false
        requirement: REQUIRED
        priority: 10
        autheticatorFlow: false
        userSetupAllowed: false
    - alias: first broker login
      description: >-
        Actions taken after first broker login with identity provider account, which is not yet linked to any Keycloak account
      providerId: basic-flow
      topLevel: true
      builtIn: true
      authenticationExecutions:
      - authenticatorConfig: review profile config
        authenticator: idp-review-profile
        authenticatorFlow: false
        requirement: REQUIRED
        priority: 10
        autheticatorFlow: false
        userSetupAllowed: false
      - authenticatorFlow: true
        requirement: REQUIRED
        priority: 20
        autheticatorFlow: true
        flowAlias: User creation or linking
        userSetupAllowed: false
    - alias: forms
      description: 'Username, password, otp and other auth forms.'
      providerId: basic-flow
      topLevel: false
      builtIn: true
      authenticationExecutions:
      - authenticator: auth-username-password-form
        authenticatorFlow: false
        requirement: REQUIRED
        priority: 10
        autheticatorFlow: false
        userSetupAllowed: false
      - authenticatorFlow: true
        requirement: CONDITIONAL
        priority: 20
        autheticatorFlow: true
        flowAlias: Browser - Conditional OTP
        userSetupAllowed: false
    - alias: registration
      description: registration flow
      providerId: basic-flow
      topLevel: true
      builtIn: true
      authenticationExecutions:
      - authenticator: registration-page-form
        authenticatorFlow: true
        requirement: REQUIRED
        priority: 10
        autheticatorFlow: true
        flowAlias: registration form
        userSetupAllowed: false
    - alias: registration form
      description: registration form
      providerId: form-flow
      topLevel: false
      builtIn: true
      authenticationExecutions:
      - authenticator: registration-user-creation
        authenticatorFlow: false
        requirement: REQUIRED
        priority: 20
        autheticatorFlow: false
        userSetupAllowed: false
      - authenticator: registration-profile-action
        authenticatorFlow: false
        requirement: REQUIRED
        priority: 40
        autheticatorFlow: false
        userSetupAllowed: false
      - authenticator: registration-password-action
        authenticatorFlow: false
        requirement: REQUIRED
        priority: 50
        autheticatorFlow: false
        userSetupAllowed: false
      - authenticator: registration-recaptcha-action
        authenticatorFlow: false
        requirement: DISABLED
        priority: 60
        autheticatorFlow: false
        userSetupAllowed: false
    - alias: reset credentials
      description: Reset credentials for a user if they forgot their password or something
      providerId: basic-flow
      topLevel: true
      builtIn: true
      authenticationExecutions:
      - authenticator: reset-credentials-choose-user
        authenticatorFlow: false
        requirement: REQUIRED
        priority: 10
        autheticatorFlow: false
        userSetupAllowed: false
      - authenticator: reset-credential-email
        authenticatorFlow: false
        requirement: REQUIRED
        priority: 20
        autheticatorFlow: false
        userSetupAllowed: false
      - authenticator: reset-password
        authenticatorFlow: false
        requirement: REQUIRED
        priority: 30
        autheticatorFlow: false
        userSetupAllowed: false
      - authenticatorFlow: true
        requirement: CONDITIONAL
        priority: 40
        autheticatorFlow: true
        flowAlias: Reset - Conditional OTP
        userSetupAllowed: false
    - alias: saml ecp
      description: SAML ECP Profile Authentication Flow
      providerId: basic-flow
      topLevel: true
      builtIn: true
      authenticationExecutions:
      - authenticator: http-basic-authenticator
        authenticatorFlow: false
        requirement: REQUIRED
        priority: 10
        autheticatorFlow: false
        userSetupAllowed: false
    authenticatorConfig:
    - alias: create unique user config
      config:
        require.password.update.after.registration: 'false'
    - alias: review profile config
      config:
        update.profile.on.first.login: missing
    requiredActions:
    - alias: CONFIGURE_TOTP
      name: Configure OTP
      providerId: CONFIGURE_TOTP
      enabled: true
      defaultAction: false
      priority: 10
      config: {}
    - alias: TERMS_AND_CONDITIONS
      name: Terms and Conditions
      providerId: TERMS_AND_CONDITIONS
      enabled: false
      defaultAction: false
      priority: 20
      config: {}
    - alias: UPDATE_PASSWORD
      name: Update Password
      providerId: UPDATE_PASSWORD
      enabled: true
      defaultAction: false
      priority: 30
      config: {}
    - alias: UPDATE_PROFILE
      name: Update Profile
      providerId: UPDATE_PROFILE
      enabled: true
      defaultAction: false
      priority: 40
      config: {}
    - alias: VERIFY_EMAIL
      name: Verify Email
      providerId: VERIFY_EMAIL
      enabled: true
      defaultAction: false
      priority: 50
      config: {}
    - alias: delete_account
      name: Delete Account
      providerId: delete_account
      enabled: false
      defaultAction: false
      priority: 60
      config: {}
    - alias: webauthn-register
      name: Webauthn Register
      providerId: webauthn-register
      enabled: true
      defaultAction: false
      priority: 70
      config: {}
    - alias: webauthn-register-passwordless
      name: Webauthn Register Passwordless
      providerId: webauthn-register-passwordless
      enabled: true
      defaultAction: false
      priority: 80
      config: {}
    - alias: update_user_locale
      name: Update User Locale
      providerId: update_user_locale
      enabled: true
      defaultAction: false
      priority: 1000
      config: {}
    browserFlow: browser
    registrationFlow: registration
    directGrantFlow: direct grant
    resetCredentialsFlow: reset credentials
    clientAuthenticationFlow: clients
    dockerAuthenticationFlow: docker auth
    attributes:
      cibaBackchannelTokenDeliveryMode: poll
      cibaExpiresIn: '120'
      cibaAuthRequestedUserHint: login_hint
      oauth2DeviceCodeLifespan: '600'
      clientOfflineSessionMaxLifespan: '0'
      oauth2DevicePollingInterval: '5'
      clientSessionIdleTimeout: '0'
      parRequestUriLifespan: '60'
      clientSessionMaxLifespan: '0'
      clientOfflineSessionIdleTimeout: '0'
      cibaInterval: '5'
      realmReusableOtpCode: 'false'
    keycloakVersion: 22.0.1
    userManagedAccessAllowed: false
    clientProfiles:
      profiles: []
    clientPolicies:
      policies: []
