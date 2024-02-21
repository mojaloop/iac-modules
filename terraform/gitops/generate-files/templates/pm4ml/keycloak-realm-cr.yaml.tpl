apiVersion: k8s.keycloak.org/v2alpha1
kind: KeycloakRealmImport
metadata:
  name: ${keycloak_pm4ml_realm_name}
  namespace: ${keycloak_namespace}
spec:
  keycloakCRName: ${keycloak_name}
  realm:
    id: ${keycloak_pm4ml_realm_name}
    realm: ${keycloak_pm4ml_realm_name}
    displayName: Payment Manager ${keycloak_pm4ml_realm_name} for Mojaloop
    displayNameHtml: Payment Manager ${keycloak_pm4ml_realm_name} for Mojaloop
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
    enabled: true
    sslRequired: external
    registrationAllowed: false
    registrationEmailAsUsername: false
    rememberMe: false
    verifyEmail: false
    loginWithEmailAllowed: true
    duplicateEmailsAllowed: false
    resetPasswordAllowed: true
    editUsernameAllowed: false
    bruteForceProtected: true
    permanentLockout: false
    maxFailureWaitSeconds: 900
    minimumQuickLoginWaitSeconds: 60
    waitIncrementSeconds: 60
    quickLoginCheckMilliSeconds: 1000
    maxDeltaTimeSeconds: 43200
    failureFactor: 30
    roles:
      realm:
      - name: write-all
        composite: false
        clientRole: false
        containerId: ${keycloak_pm4ml_realm_name}
        attributes: {}
      - name: read-all
        composite: false
        clientRole: false
        containerId: ${keycloak_pm4ml_realm_name}
        attributes: {}
      - name: uma_authorization
        description: "$${role_uma_authorization}"
        composite: false
        clientRole: false
        containerId: ${keycloak_pm4ml_realm_name}
        attributes: {}
      - name: offline_access
        description: "$${role_offline-access}"
        composite: false
        clientRole: false
        containerId: ${keycloak_pm4ml_realm_name}
        attributes: {}
      client:
        ${pm4ml_oidc_client_id}: []
        realm-management:
        - name: query-realms
          description: "$${role_query-realms}"
          composite: false
          clientRole: true
          containerId: ${keycloak_pm4ml_realm_name}
          attributes: {}
        - name: manage-clients
          description: "$${role_manage-clients}"
          composite: false
          clientRole: true
          containerId: ${keycloak_pm4ml_realm_name}
          attributes: {}
        - name: view-identity-providers
          description: "$${role_view-identity-providers}"
          composite: false
          clientRole: true
          containerId: ${keycloak_pm4ml_realm_name}
          attributes: {}
        - name: view-users
          description: "$${role_view-users}"
          composite: true
          composites:
            client:
              realm-management:
              - query-users
              - query-groups
          clientRole: true
          containerId: ${keycloak_pm4ml_realm_name}
          attributes: {}
        - name: manage-events
          description: "$${role_manage-events}"
          composite: false
          clientRole: true
          containerId: ${keycloak_pm4ml_realm_name}
          attributes: {}
        - name: realm-admin
          description: "$${role_realm-admin}"
          composite: true
          composites:
            client:
              realm-management:
              - query-realms
              - manage-clients
              - view-identity-providers
              - view-users
              - manage-events
              - query-groups
              - view-events
              - manage-authorization
              - manage-realm
              - view-clients
              - query-clients
              - view-authorization
              - create-client
              - view-realm
              - manage-users
              - query-users
              - impersonation
              - manage-identity-providers
          clientRole: true
          containerId: ${keycloak_pm4ml_realm_name}
          attributes: {}
        - name: query-groups
          description: "$${role_query-groups}"
          composite: false
          clientRole: true
          containerId: ${keycloak_pm4ml_realm_name}
          attributes: {}
        - name: view-events
          description: "$${role_view-events}"
          composite: false
          clientRole: true
          containerId: ${keycloak_pm4ml_realm_name}
          attributes: {}
        - name: manage-authorization
          description: "$${role_manage-authorization}"
          composite: false
          clientRole: true
          containerId: ${keycloak_pm4ml_realm_name}
          attributes: {}
        - name: manage-realm
          description: "$${role_manage-realm}"
          composite: false
          clientRole: true
          containerId: ${keycloak_pm4ml_realm_name}
          attributes: {}
        - name: view-clients
          description: "$${role_view-clients}"
          composite: true
          composites:
            client:
              realm-management:
              - query-clients
          clientRole: true
          containerId: ${keycloak_pm4ml_realm_name}
          attributes: {}
        - name: query-clients
          description: "$${role_query-clients}"
          composite: false
          clientRole: true
          containerId: ${keycloak_pm4ml_realm_name}
          attributes: {}
        - name: view-authorization
          description: "$${role_view-authorization}"
          composite: false
          clientRole: true
          containerId: ${keycloak_pm4ml_realm_name}
          attributes: {}
        - name: create-client
          description: "$${role_create-client}"
          composite: false
          clientRole: true
          containerId: ${keycloak_pm4ml_realm_name}
          attributes: {}
        - name: manage-users
          description: "$${role_manage-users}"
          composite: false
          clientRole: true
          containerId: ${keycloak_pm4ml_realm_name}
          attributes: {}
        - name: query-users
          description: "$${role_query-users}"
          composite: false
          clientRole: true
          containerId: ${keycloak_pm4ml_realm_name}
          attributes: {}
        - name: view-realm
          description: "$${role_view-realm}"
          composite: false
          clientRole: true
          containerId: ${keycloak_pm4ml_realm_name}
          attributes: {}
        - name: impersonation
          description: "$${role_impersonation}"
          composite: false
          clientRole: true
          containerId: ${keycloak_pm4ml_realm_name}
          attributes: {}
        - name: manage-identity-providers
          description: "$${role_manage-identity-providers}"
          composite: false
          clientRole: true
          containerId: ${keycloak_pm4ml_realm_name}
          attributes: {}
        security-admin-console: []
        admin-cli: []
        account-console: []
        broker:
        - name: read-token
          description: "$${role_read-token}"
          composite: false
          clientRole: true
          containerId: 9b46fb1e-e281-4ce7-be76-cc77b73929cc
          attributes: {}
        account:
        - name: view-profile
          description: "$${role_view-profile}"
          composite: false
          clientRole: true
          containerId: d5828b63-66ba-47fc-a55b-490bac640c90
          attributes: {}
        - name: manage-account-links
          description: "$${role_manage-account-links}"
          composite: false
          clientRole: true
          containerId: d5828b63-66ba-47fc-a55b-490bac640c90
          attributes: {}
        - name: view-applications
          description: "$${role_view-applications}"
          composite: false
          clientRole: true
          containerId: d5828b63-66ba-47fc-a55b-490bac640c90
          attributes: {}
        - name: delete-account
          description: "$${role_delete-account}"
          composite: false
          clientRole: true
          containerId: d5828b63-66ba-47fc-a55b-490bac640c90
          attributes: {}
        - name: view-consent
          description: "$${role_view-consent}"
          composite: false
          clientRole: true
          containerId: d5828b63-66ba-47fc-a55b-490bac640c90
          attributes: {}
        - name: manage-account
          description: "$${role_manage-account}"
          composite: true
          composites:
            client:
              account:
              - manage-account-links
          clientRole: true
          containerId: d5828b63-66ba-47fc-a55b-490bac640c90
          attributes: {}
        - name: manage-consent
          description: "$${role_manage-consent}"
          composite: true
          composites:
            client:
              account:
              - view-consent
          clientRole: true
          containerId: d5828b63-66ba-47fc-a55b-490bac640c90
          attributes: {}
    groups:
    - name: Super Users
      path: "/Super Users"
      attributes: {}
      realmRoles:
      - write-all
      - read-all
      clientRoles: {}
      subGroups: []
    defaultRoles:
    - read-all
    - uma_authorization
    - offline_access
    requiredCredentials:
    - password
    otpPolicyType: totp
    otpPolicyAlgorithm: HmacSHA1
    otpPolicyInitialCounter: 0
    otpPolicyDigits: 6
    otpPolicyLookAheadWindow: 1
    otpPolicyPeriod: 30
    otpSupportedApplications:
    - FreeOTP
    - Google Authenticator
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
    scopeMappings:
    - clientScope: offline_access
      roles:
      - offline_access
    - clientScope: roles
      roles:
      - read-all
      - write-all
    clientScopeMappings:
      account:
      - client: account-console
        roles:
        - manage-account
    clients:
    - clientId: account
      name: "$${client_account}"
      rootUrl: "$${authBaseUrl}"
      baseUrl: "/realms/${keycloak_pm4ml_realm_name}/account/"
      surrogateAuthRequired: false
      enabled: true
      alwaysDisplayInConsole: false
      clientAuthenticatorType: client-secret
      defaultRoles:
      - view-profile
      - manage-account
      redirectUris:
      - "/realms/${keycloak_pm4ml_realm_name}/account/*"
      webOrigins: []
      notBefore: 0
      bearerOnly: false
      consentRequired: false
      standardFlowEnabled: true
      implicitFlowEnabled: false
      directAccessGrantsEnabled: false
      serviceAccountsEnabled: false
      publicClient: false
      frontchannelLogout: false
      protocol: openid-connect
      attributes: {}
      authenticationFlowBindingOverrides: {}
      fullScopeAllowed: false
      nodeReRegistrationTimeout: 0
      defaultClientScopes:
      - web-origins
      - role_list
      - profile
      - roles
      - email
      optionalClientScopes:
      - address
      - phone
      - offline_access
      - microprofile-jwt
    - clientId: account-console
      name: "$${client_account-console}"
      rootUrl: "$${authBaseUrl}"
      baseUrl: "/realms/${keycloak_pm4ml_realm_name}/account/"
      surrogateAuthRequired: false
      enabled: true
      alwaysDisplayInConsole: false
      clientAuthenticatorType: client-secret
      redirectUris:
      - "/realms/${keycloak_pm4ml_realm_name}/account/*"
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
      - role_list
      - profile
      - roles
      - email
      optionalClientScopes:
      - address
      - phone
      - offline_access
      - microprofile-jwt
    - clientId: admin-cli
      name: "$${client_admin-cli}"
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
      attributes: {}
      authenticationFlowBindingOverrides: {}
      fullScopeAllowed: false
      nodeReRegistrationTimeout: 0
      defaultClientScopes:
      - web-origins
      - role_list
      - profile
      - roles
      - email
      optionalClientScopes:
      - address
      - phone
      - offline_access
      - microprofile-jwt
    - clientId: broker
      name: "$${client_broker}"
      surrogateAuthRequired: false
      enabled: true
      alwaysDisplayInConsole: false
      clientAuthenticatorType: client-secret
      redirectUris: []
      webOrigins: []
      notBefore: 0
      bearerOnly: false
      consentRequired: false
      standardFlowEnabled: true
      implicitFlowEnabled: false
      directAccessGrantsEnabled: false
      serviceAccountsEnabled: false
      publicClient: false
      frontchannelLogout: false
      protocol: openid-connect
      attributes: {}
      authenticationFlowBindingOverrides: {}
      fullScopeAllowed: false
      nodeReRegistrationTimeout: 0
      defaultClientScopes:
      - web-origins
      - role_list
      - profile
      - roles
      - email
      optionalClientScopes:
      - address
      - phone
      - offline_access
      - microprofile-jwt
    - clientId: ${pm4ml_oidc_client_id}
      rootUrl: "https://${portal_fqdn}/"
      baseUrl: "https://${experience_api_fqdn}/"
      surrogateAuthRequired: false
      enabled: true
      alwaysDisplayInConsole: false
      clientAuthenticatorType: client-secret
      secret: ${pm4ml_oidc_client_secret_secret_name}
      redirectUris:
        - "https://${portal_fqdn}/*"
        - "https://${experience_api_fqdn}/*"
      webOrigins:
        - "*"
      notBefore: 0
      bearerOnly: false
      consentRequired: false
      standardFlowEnabled: true
      implicitFlowEnabled: false
      directAccessGrantsEnabled: true
      serviceAccountsEnabled: false
      publicClient: false
      frontchannelLogout: false
      protocol: openid-connect
      attributes:
        saml.assertion.signature: 'false'
        saml.force.post.binding: 'false'
        saml.multivalued.roles: 'false'
        saml.encrypt: 'false'
        backchannel.logout.revoke.offline.tokens: 'false'
        saml.server.signature: 'false'
        saml.server.signature.keyinfo.ext: 'false'
        exclude.session.state.from.auth.response: 'false'
        backchannel.logout.session.required: 'true'
        client_credentials.use_refresh_token: 'false'
        saml_force_name_id_format: 'false'
        saml.client.signature: 'false'
        tls.client.certificate.bound.access.tokens: 'false'
        saml.authnstatement: 'false'
        display.on.consent.screen: 'false'
        saml.onetimeuse.condition: 'false'
      authenticationFlowBindingOverrides: {}
      fullScopeAllowed: true
      nodeReRegistrationTimeout: -1
      defaultClientScopes:
      - web-origins
      - role_list
      - profile
      - roles
      - email
      optionalClientScopes:
      - address
      - phone
      - offline_access
      - microprofile-jwt
    - clientId: '${pm4ml_namespace} provider'
      name: '${pm4ml_namespace}-provider-client'
      description: ''
      rootUrl: ''
      adminUrl: ''
      baseUrl: ''
      surrogateAuthRequired: false
      enabled: true
      alwaysDisplayInConsole: false
      clientAuthenticatorType: client-secret
      secret: ${pm4ml_oidc_provider_secret}
      redirectUris:
      - "*"
      webOrigins:
      - "*"
      notBefore: 0
      bearerOnly: false
      consentRequired: false
      standardFlowEnabled: true
      implicitFlowEnabled: false
      directAccessGrantsEnabled: true
      serviceAccountsEnabled: false
      publicClient: true
      frontchannelLogout: true
      protocol: openid-connect
      attributes:
        oidc.ciba.grant.enabled: 'false'
        oauth2.device.authorization.grant.enabled: 'false'
        backchannel.logout.session.required: 'true'
        backchannel.logout.revoke.offline.tokens: 'false'
      authenticationFlowBindingOverrides: {}
      fullScopeAllowed: true
      nodeReRegistrationTimeout: -1
      defaultClientScopes:
      - web-origins
      - acr
      - roles
      - profile
      - email
      optionalClientScopes:
      - address
      - phone
      - offline_access
      - microprofile-jwt
    - id: ${keycloak_pm4ml_realm_name}
      clientId: realm-management
      name: "$${client_realm-management}"
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
      attributes: {}
      authenticationFlowBindingOverrides: {}
      fullScopeAllowed: false
      nodeReRegistrationTimeout: 0
      defaultClientScopes:
      - web-origins
      - role_list
      - profile
      - roles
      - email
      optionalClientScopes:
      - address
      - phone
      - offline_access
      - microprofile-jwt
    - clientId: security-admin-console
      name: "$${client_security-admin-console}"
      rootUrl: "$${authAdminUrl}"
      baseUrl: "/admin/pm4ml/console/"
      surrogateAuthRequired: false
      enabled: true
      alwaysDisplayInConsole: false
      clientAuthenticatorType: client-secret
      redirectUris:
      - "/admin/pm4ml/console/*"
      webOrigins:
      - "+"
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
      - role_list
      - profile
      - roles
      - email
      optionalClientScopes:
      - address
      - phone
      - offline_access
      - microprofile-jwt
    clientScopes:
    - name: address
      description: 'OpenID Connect built-in scope: address'
      protocol: openid-connect
      attributes:
        include.in.token.scope: 'true'
        display.on.consent.screen: 'true'
        consent.screen.text: "$${addressScopeConsentText}"
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
    - name: email
      description: 'OpenID Connect built-in scope: email'
      protocol: openid-connect
      attributes:
        include.in.token.scope: 'true'
        display.on.consent.screen: 'true'
        consent.screen.text: "$${emailScopeConsentText}"
      protocolMappers:
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
      - name: email
        protocol: openid-connect
        protocolMapper: oidc-usermodel-property-mapper
        consentRequired: false
        config:
          userinfo.token.claim: 'true'
          user.attribute: email
          id.token.claim: 'true'
          access.token.claim: 'true'
          claim.name: email
          jsonType.label: String
    - name: microprofile-jwt
      description: Microprofile - JWT built-in scope
      protocol: openid-connect
      attributes:
        include.in.token.scope: 'true'
        display.on.consent.screen: 'false'
      protocolMappers:
      - name: upn
        protocol: openid-connect
        protocolMapper: oidc-usermodel-property-mapper
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
    - name: offline_access
      description: 'OpenID Connect built-in scope: offline_access'
      protocol: openid-connect
      attributes:
        consent.screen.text: "$${offlineAccessScopeConsentText}"
        display.on.consent.screen: 'true'
    - name: phone
      description: 'OpenID Connect built-in scope: phone'
      protocol: openid-connect
      attributes:
        include.in.token.scope: 'true'
        display.on.consent.screen: 'true'
        consent.screen.text: "$${phoneScopeConsentText}"
      protocolMappers:
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
    - name: profile
      description: 'OpenID Connect built-in scope: profile'
      protocol: openid-connect
      attributes:
        include.in.token.scope: 'true'
        display.on.consent.screen: 'true'
        consent.screen.text: "$${profileScopeConsentText}"
      protocolMappers:
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
      - name: full name
        protocol: openid-connect
        protocolMapper: oidc-full-name-mapper
        consentRequired: false
        config:
          id.token.claim: 'true'
          access.token.claim: 'true'
          userinfo.token.claim: 'true'
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
      - name: given name
        protocol: openid-connect
        protocolMapper: oidc-usermodel-property-mapper
        consentRequired: false
        config:
          userinfo.token.claim: 'true'
          user.attribute: firstName
          id.token.claim: 'true'
          access.token.claim: 'true'
          claim.name: given_name
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
      - name: username
        protocol: openid-connect
        protocolMapper: oidc-usermodel-property-mapper
        consentRequired: false
        config:
          userinfo.token.claim: 'true'
          user.attribute: username
          id.token.claim: 'true'
          access.token.claim: 'true'
          claim.name: preferred_username
          jsonType.label: String
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
      - name: family name
        protocol: openid-connect
        protocolMapper: oidc-usermodel-property-mapper
        consentRequired: false
        config:
          userinfo.token.claim: 'true'
          user.attribute: lastName
          id.token.claim: 'true'
          access.token.claim: 'true'
          claim.name: family_name
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
    - name: role_list
      description: SAML role list
      protocol: saml
      attributes:
        consent.screen.text: "$${samlRoleListScopeConsentText}"
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
    - name: roles
      description: OpenID Connect scope for add user roles to the access token
      protocol: openid-connect
      attributes:
        include.in.token.scope: 'true'
        display.on.consent.screen: 'true'
        consent.screen.text: "$${rolesScopeConsentText}"
      protocolMappers:
      - name: client roles
        protocol: openid-connect
        protocolMapper: oidc-usermodel-client-role-mapper
        consentRequired: false
        config:
          user.attribute: foo
          access.token.claim: 'true'
          claim.name: resource_access.$${client_id}.roles
          jsonType.label: String
          multivalued: 'true'
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
          multivalued: 'true'
          userinfo.token.claim: 'true'
          user.attribute: foo
          id.token.claim: 'true'
          access.token.claim: 'true'
          claim.name: realm_access.roles
          jsonType.label: String
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
    defaultDefaultClientScopes:
    - email
    - profile
    - roles
    - web-origins
    defaultOptionalClientScopes:
    - phone
    - address
    - offline_access
    - microprofile-jwt
    browserSecurityHeaders:
      contentSecurityPolicyReportOnly: ''
      xContentTypeOptions: nosniff
      xRobotsTag: none
      xFrameOptions: SAMEORIGIN
      contentSecurityPolicy: frame-src 'self'; frame-ancestors 'self'; object-src 'none';
      xXSSProtection: 1; mode=block
      strictTransportSecurity: max-age=31536000; includeSubDomains
    smtpServer: {}
    loginTheme: keycloak
    accountTheme: keycloak
    adminTheme: keycloak
    emailTheme: keycloak
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
      - name: Allowed Protocol Mapper Types
        providerId: allowed-protocol-mappers
        subType: authenticated
        subComponents: {}
        config:
          allowed-protocol-mapper-types:
          - saml-role-list-mapper
          - saml-user-property-mapper
          - oidc-usermodel-property-mapper
          - oidc-address-mapper
          - saml-user-attribute-mapper
          - oidc-usermodel-attribute-mapper
          - oidc-sha256-pairwise-sub-mapper
          - oidc-full-name-mapper
      - name: Max Clients Limit
        providerId: max-clients
        subType: anonymous
        subComponents: {}
        config:
          max-clients:
          - '200'
      - name: Allowed Protocol Mapper Types
        providerId: allowed-protocol-mappers
        subType: anonymous
        subComponents: {}
        config:
          allowed-protocol-mapper-types:
          - saml-role-list-mapper
          - saml-user-attribute-mapper
          - saml-user-property-mapper
          - oidc-address-mapper
          - oidc-sha256-pairwise-sub-mapper
          - oidc-usermodel-attribute-mapper
          - oidc-full-name-mapper
          - oidc-usermodel-property-mapper
      - name: Consent Required
        providerId: consent-required
        subType: anonymous
        subComponents: {}
        config: {}
      - name: Trusted Hosts
        providerId: trusted-hosts
        subType: anonymous
        subComponents: {}
        config:
          host-sending-registration-request-must-match:
          - 'true'
          client-uris-must-match:
          - 'true'
      - name: Allowed Client Scopes
        providerId: allowed-client-templates
        subType: authenticated
        subComponents: {}
        config:
          allow-default-scopes:
          - 'true'
      - name: Full Scope Disabled
        providerId: scope
        subType: anonymous
        subComponents: {}
        config: {}
      - name: Allowed Client Scopes
        providerId: allowed-client-templates
        subType: anonymous
        subComponents: {}
        config:
          allow-default-scopes:
          - 'true'
      org.keycloak.keys.KeyProvider:
      - name: rsa-generated
        providerId: rsa-generated
        subComponents: {}
        config:
          priority:
          - '100'
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
    internationalizationEnabled: false
    supportedLocales:
    - ''
    authenticationFlows:
    - alias: Account verification options
      description: Method with which to verity the existing account
      providerId: basic-flow
      topLevel: false
      builtIn: true
      authenticationExecutions:
      - authenticator: idp-email-verification
        requirement: ALTERNATIVE
        priority: 10
        userSetupAllowed: false
        autheticatorFlow: false
      - requirement: ALTERNATIVE
        priority: 20
        flowAlias: Verify Existing Account by Re-authentication
        userSetupAllowed: false
        autheticatorFlow: true
    - alias: Authentication Options
      description: Authentication options.
      providerId: basic-flow
      topLevel: false
      builtIn: true
      authenticationExecutions:
      - authenticator: basic-auth
        requirement: REQUIRED
        priority: 10
        userSetupAllowed: false
        autheticatorFlow: false
      - authenticator: basic-auth-otp
        requirement: DISABLED
        priority: 20
        userSetupAllowed: false
        autheticatorFlow: false
      - authenticator: auth-spnego
        requirement: DISABLED
        priority: 30
        userSetupAllowed: false
        autheticatorFlow: false
    - alias: Browser - Conditional OTP
      description: Flow to determine if the OTP is required for the authentication
      providerId: basic-flow
      topLevel: false
      builtIn: true
      authenticationExecutions:
      - authenticator: conditional-user-configured
        requirement: REQUIRED
        priority: 10
        userSetupAllowed: false
        autheticatorFlow: false
      - authenticator: auth-otp-form
        requirement: REQUIRED
        priority: 20
        userSetupAllowed: false
        autheticatorFlow: false
    - alias: Direct Grant - Conditional OTP
      description: Flow to determine if the OTP is required for the authentication
      providerId: basic-flow
      topLevel: false
      builtIn: true
      authenticationExecutions:
      - authenticator: conditional-user-configured
        requirement: REQUIRED
        priority: 10
        userSetupAllowed: false
        autheticatorFlow: false
      - authenticator: direct-grant-validate-otp
        requirement: REQUIRED
        priority: 20
        userSetupAllowed: false
        autheticatorFlow: false
    - alias: First broker login - Conditional OTP
      description: Flow to determine if the OTP is required for the authentication
      providerId: basic-flow
      topLevel: false
      builtIn: true
      authenticationExecutions:
      - authenticator: conditional-user-configured
        requirement: REQUIRED
        priority: 10
        userSetupAllowed: false
        autheticatorFlow: false
      - authenticator: auth-otp-form
        requirement: REQUIRED
        priority: 20
        userSetupAllowed: false
        autheticatorFlow: false
    - alias: Handle Existing Account
      description: Handle what to do if there is existing account with same email/username
        like authenticated identity provider
      providerId: basic-flow
      topLevel: false
      builtIn: true
      authenticationExecutions:
      - authenticator: idp-confirm-link
        requirement: REQUIRED
        priority: 10
        userSetupAllowed: false
        autheticatorFlow: false
      - requirement: REQUIRED
        priority: 20
        flowAlias: Account verification options
        userSetupAllowed: false
        autheticatorFlow: true
    - alias: Reset - Conditional OTP
      description: Flow to determine if the OTP should be reset or not. Set to REQUIRED
        to force.
      providerId: basic-flow
      topLevel: false
      builtIn: true
      authenticationExecutions:
      - authenticator: conditional-user-configured
        requirement: REQUIRED
        priority: 10
        userSetupAllowed: false
        autheticatorFlow: false
      - authenticator: reset-otp
        requirement: REQUIRED
        priority: 20
        userSetupAllowed: false
        autheticatorFlow: false
    - alias: User creation or linking
      description: Flow for the existing/non-existing user alternatives
      providerId: basic-flow
      topLevel: false
      builtIn: true
      authenticationExecutions:
      - authenticatorConfig: create unique user config
        authenticator: idp-create-user-if-unique
        requirement: ALTERNATIVE
        priority: 10
        userSetupAllowed: false
        autheticatorFlow: false
      - requirement: ALTERNATIVE
        priority: 20
        flowAlias: Handle Existing Account
        userSetupAllowed: false
        autheticatorFlow: true
    - alias: Verify Existing Account by Re-authentication
      description: Reauthentication of existing account
      providerId: basic-flow
      topLevel: false
      builtIn: true
      authenticationExecutions:
      - authenticator: idp-username-password-form
        requirement: REQUIRED
        priority: 10
        userSetupAllowed: false
        autheticatorFlow: false
      - requirement: CONDITIONAL
        priority: 20
        flowAlias: First broker login - Conditional OTP
        userSetupAllowed: false
        autheticatorFlow: true
    - alias: browser
      description: browser based authentication
      providerId: basic-flow
      topLevel: true
      builtIn: true
      authenticationExecutions:
      - authenticator: auth-cookie
        requirement: ALTERNATIVE
        priority: 10
        userSetupAllowed: false
        autheticatorFlow: false
      - authenticator: auth-spnego
        requirement: DISABLED
        priority: 20
        userSetupAllowed: false
        autheticatorFlow: false
      - authenticator: identity-provider-redirector
        requirement: ALTERNATIVE
        priority: 25
        userSetupAllowed: false
        autheticatorFlow: false
      - requirement: ALTERNATIVE
        priority: 30
        flowAlias: forms
        userSetupAllowed: false
        autheticatorFlow: true
    - alias: clients
      description: Base authentication for clients
      providerId: client-flow
      topLevel: true
      builtIn: true
      authenticationExecutions:
      - authenticator: client-secret
        requirement: REQUIRED
        priority: 10
        userSetupAllowed: false
        autheticatorFlow: false
      - authenticator: client-jwt
        requirement: DISABLED
        priority: 20
        userSetupAllowed: false
        autheticatorFlow: false
      - authenticator: client-secret-jwt
        requirement: DISABLED
        priority: 30
        userSetupAllowed: false
        autheticatorFlow: false
      - authenticator: client-x509
        requirement: DISABLED
        priority: 40
        userSetupAllowed: false
        autheticatorFlow: false
    - alias: direct grant
      description: OpenID Connect Resource Owner Grant
      providerId: basic-flow
      topLevel: true
      builtIn: true
      authenticationExecutions:
      - authenticator: direct-grant-validate-username
        requirement: REQUIRED
        priority: 10
        userSetupAllowed: false
        autheticatorFlow: false
      - authenticator: direct-grant-validate-password
        requirement: REQUIRED
        priority: 20
        userSetupAllowed: false
        autheticatorFlow: false
      - requirement: CONDITIONAL
        priority: 30
        flowAlias: Direct Grant - Conditional OTP
        userSetupAllowed: false
        autheticatorFlow: true
    - alias: docker auth
      description: Used by Docker clients to authenticate against the IDP
      providerId: basic-flow
      topLevel: true
      builtIn: true
      authenticationExecutions:
      - authenticator: docker-http-basic-authenticator
        requirement: REQUIRED
        priority: 10
        userSetupAllowed: false
        autheticatorFlow: false
    - alias: first broker login
      description: Actions taken after first broker login with identity provider account,
        which is not yet linked to any Keycloak account
      providerId: basic-flow
      topLevel: true
      builtIn: true
      authenticationExecutions:
      - authenticatorConfig: review profile config
        authenticator: idp-review-profile
        requirement: REQUIRED
        priority: 10
        userSetupAllowed: false
        autheticatorFlow: false
      - requirement: REQUIRED
        priority: 20
        flowAlias: User creation or linking
        userSetupAllowed: false
        autheticatorFlow: true
    - alias: forms
      description: Username, password, otp and other auth forms.
      providerId: basic-flow
      topLevel: false
      builtIn: true
      authenticationExecutions:
      - authenticator: auth-username-password-form
        requirement: REQUIRED
        priority: 10
        userSetupAllowed: false
        autheticatorFlow: false
      - requirement: REQUIRED
        priority: 20
        flowAlias: Browser - Conditional OTP
        userSetupAllowed: false
        autheticatorFlow: true
    - alias: http challenge
      description: An authentication flow based on challenge-response HTTP Authentication
        Schemes
      providerId: basic-flow
      topLevel: true
      builtIn: true
      authenticationExecutions:
      - authenticator: no-cookie-redirect
        requirement: REQUIRED
        priority: 10
        userSetupAllowed: false
        autheticatorFlow: false
      - requirement: REQUIRED
        priority: 20
        flowAlias: Authentication Options
        userSetupAllowed: false
        autheticatorFlow: true
    - alias: registration
      description: registration flow
      providerId: basic-flow
      topLevel: true
      builtIn: true
      authenticationExecutions:
      - authenticator: registration-page-form
        requirement: REQUIRED
        priority: 10
        flowAlias: registration form
        userSetupAllowed: false
        autheticatorFlow: true
    - alias: registration form
      description: registration form
      providerId: form-flow
      topLevel: false
      builtIn: true
      authenticationExecutions:
      - authenticator: registration-user-creation
        requirement: REQUIRED
        priority: 20
        userSetupAllowed: false
        autheticatorFlow: false
      - authenticator: registration-profile-action
        requirement: REQUIRED
        priority: 40
        userSetupAllowed: false
        autheticatorFlow: false
      - authenticator: registration-password-action
        requirement: REQUIRED
        priority: 50
        userSetupAllowed: false
        autheticatorFlow: false
      - authenticator: registration-recaptcha-action
        requirement: DISABLED
        priority: 60
        userSetupAllowed: false
        autheticatorFlow: false
    - alias: reset credentials
      description: Reset credentials for a user if they forgot their password or something
      providerId: basic-flow
      topLevel: true
      builtIn: true
      authenticationExecutions:
      - authenticator: reset-credentials-choose-user
        requirement: REQUIRED
        priority: 10
        userSetupAllowed: false
        autheticatorFlow: false
      - authenticator: reset-credential-email
        requirement: REQUIRED
        priority: 20
        userSetupAllowed: false
        autheticatorFlow: false
      - authenticator: reset-password
        requirement: REQUIRED
        priority: 30
        userSetupAllowed: false
        autheticatorFlow: false
      - requirement: CONDITIONAL
        priority: 40
        flowAlias: Reset - Conditional OTP
        userSetupAllowed: false
        autheticatorFlow: true
    - alias: saml ecp
      description: SAML ECP Profile Authentication Flow
      providerId: basic-flow
      topLevel: true
      builtIn: true
      authenticationExecutions:
      - authenticator: http-basic-authenticator
        requirement: REQUIRED
        priority: 10
        userSetupAllowed: false
        autheticatorFlow: false
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
    - alias: terms_and_conditions
      name: Terms and Conditions
      providerId: terms_and_conditions
      enabled: true
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
      clientOfflineSessionMaxLifespan: '0'
      clientSessionIdleTimeout: '0'
      clientSessionMaxLifespan: '0'
      clientOfflineSessionIdleTimeout: '0'
    keycloakVersion: 22.0.1
    userManagedAccessAllowed: false

