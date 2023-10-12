apiVersion: k8s.keycloak.org/v2alpha1
kind: KeycloakRealmImport
metadata:
  name: ${keycloak_dfsp_realm_name}
  namespace: ${keycloak_namespace}
spec:
  keycloakCRName: ${keycloak_name}
  realm:
    id: ${keycloak_dfsp_realm_name}
    realm: ${keycloak_dfsp_realm_name}
    displayName: Payment Manager for Mojaloop
    displayNameHtml: Payment Manager for Mojaloop
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
      - id: eb4f921b-46c3-472f-a36a-7d6e0414b448
        name: write-all
        composite: false
        clientRole: false
        containerId: pm4ml
        attributes: {}
      - id: 865b9301-5728-4ad5-a56d-042aa9001473
        name: read-all
        composite: false
        clientRole: false
        containerId: pm4ml
        attributes: {}
      - id: 457e45a3-bef9-4698-b627-e310cc2a3a2f
        name: uma_authorization
        description: "$${role_uma_authorization}"
        composite: false
        clientRole: false
        containerId: pm4ml
        attributes: {}
      - id: 68503107-a889-45b8-9627-4b5ce42a405d
        name: offline_access
        description: "$${role_offline-access}"
        composite: false
        clientRole: false
        containerId: pm4ml
        attributes: {}
      client:
        pm4ml-customer-ui: []
        realm-management:
        - id: c8c4d76f-aacd-4ae3-a89a-045d103b6136
          name: query-realms
          description: "$${role_query-realms}"
          composite: false
          clientRole: true
          containerId: 67a3b6fc-64a5-4f64-81c8-1201319f0365
          attributes: {}
        - id: '041288b9-5b4f-4e50-b8d1-9884695c644c'
          name: manage-clients
          description: "$${role_manage-clients}"
          composite: false
          clientRole: true
          containerId: 67a3b6fc-64a5-4f64-81c8-1201319f0365
          attributes: {}
        - id: 2ffa8e66-9b6c-4a4f-8b76-faf9ed45754a
          name: view-identity-providers
          description: "$${role_view-identity-providers}"
          composite: false
          clientRole: true
          containerId: 67a3b6fc-64a5-4f64-81c8-1201319f0365
          attributes: {}
        - id: a71ab402-afa2-49be-ae0a-9c90b4e55aba
          name: view-users
          description: "$${role_view-users}"
          composite: true
          composites:
            client:
              realm-management:
              - query-users
              - query-groups
          clientRole: true
          containerId: 67a3b6fc-64a5-4f64-81c8-1201319f0365
          attributes: {}
        - id: d828ef10-22b0-4e8c-9cf7-db3ae6e78cae
          name: manage-events
          description: "$${role_manage-events}"
          composite: false
          clientRole: true
          containerId: 67a3b6fc-64a5-4f64-81c8-1201319f0365
          attributes: {}
        - id: 3f6d0439-9f63-42cd-993d-79d028e39aa7
          name: realm-admin
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
          containerId: 67a3b6fc-64a5-4f64-81c8-1201319f0365
          attributes: {}
        - id: 483ae324-8714-468c-a0a7-5ae941700265
          name: query-groups
          description: "$${role_query-groups}"
          composite: false
          clientRole: true
          containerId: 67a3b6fc-64a5-4f64-81c8-1201319f0365
          attributes: {}
        - id: d60da1ba-71ea-4ef6-83ff-6fc2c8f0c0fa
          name: view-events
          description: "$${role_view-events}"
          composite: false
          clientRole: true
          containerId: 67a3b6fc-64a5-4f64-81c8-1201319f0365
          attributes: {}
        - id: 71680139-60e7-4134-b9da-ca4b33fc63b1
          name: manage-authorization
          description: "$${role_manage-authorization}"
          composite: false
          clientRole: true
          containerId: 67a3b6fc-64a5-4f64-81c8-1201319f0365
          attributes: {}
        - id: c5f44f2f-eb1f-495f-96b7-e4d547bc9a21
          name: manage-realm
          description: "$${role_manage-realm}"
          composite: false
          clientRole: true
          containerId: 67a3b6fc-64a5-4f64-81c8-1201319f0365
          attributes: {}
        - id: 9dad564c-926f-4586-be7c-d68402dbbdf5
          name: view-clients
          description: "$${role_view-clients}"
          composite: true
          composites:
            client:
              realm-management:
              - query-clients
          clientRole: true
          containerId: 67a3b6fc-64a5-4f64-81c8-1201319f0365
          attributes: {}
        - id: 8d2b9ac3-e235-4a4a-9a52-a457990ac082
          name: query-clients
          description: "$${role_query-clients}"
          composite: false
          clientRole: true
          containerId: 67a3b6fc-64a5-4f64-81c8-1201319f0365
          attributes: {}
        - id: ee4dd8da-19d3-404c-8b8e-c69903789e3d
          name: view-authorization
          description: "$${role_view-authorization}"
          composite: false
          clientRole: true
          containerId: 67a3b6fc-64a5-4f64-81c8-1201319f0365
          attributes: {}
        - id: d7754eab-2f88-4650-b419-03961c87a39d
          name: create-client
          description: "$${role_create-client}"
          composite: false
          clientRole: true
          containerId: 67a3b6fc-64a5-4f64-81c8-1201319f0365
          attributes: {}
        - id: e3e24ad8-403a-4afd-922d-75772e78ac9e
          name: manage-users
          description: "$${role_manage-users}"
          composite: false
          clientRole: true
          containerId: 67a3b6fc-64a5-4f64-81c8-1201319f0365
          attributes: {}
        - id: f4aef99f-25f5-4aee-880f-fcab946f39f9
          name: query-users
          description: "$${role_query-users}"
          composite: false
          clientRole: true
          containerId: 67a3b6fc-64a5-4f64-81c8-1201319f0365
          attributes: {}
        - id: 44e26e92-52d2-40a5-a173-b8ae561f065e
          name: view-realm
          description: "$${role_view-realm}"
          composite: false
          clientRole: true
          containerId: 67a3b6fc-64a5-4f64-81c8-1201319f0365
          attributes: {}
        - id: a0da9dac-c286-40a3-8a81-c5fd2861fcfd
          name: impersonation
          description: "$${role_impersonation}"
          composite: false
          clientRole: true
          containerId: 67a3b6fc-64a5-4f64-81c8-1201319f0365
          attributes: {}
        - id: 2b0ae45c-becf-45e0-be63-916725b8493f
          name: manage-identity-providers
          description: "$${role_manage-identity-providers}"
          composite: false
          clientRole: true
          containerId: 67a3b6fc-64a5-4f64-81c8-1201319f0365
          attributes: {}
        security-admin-console: []
        admin-cli: []
        account-console: []
        broker:
        - id: 7af5e460-7eb2-4bae-9852-a59977fa5d93
          name: read-token
          description: "$${role_read-token}"
          composite: false
          clientRole: true
          containerId: 9b46fb1e-e281-4ce7-be76-cc77b73929cc
          attributes: {}
        account:
        - id: 1161f028-74cf-477f-924c-dcb1b13b3299
          name: view-profile
          description: "$${role_view-profile}"
          composite: false
          clientRole: true
          containerId: d5828b63-66ba-47fc-a55b-490bac640c90
          attributes: {}
        - id: f758b5d6-0712-401c-93f5-ebe0753f699d
          name: manage-account-links
          description: "$${role_manage-account-links}"
          composite: false
          clientRole: true
          containerId: d5828b63-66ba-47fc-a55b-490bac640c90
          attributes: {}
        - id: bce12ab9-6992-4534-9709-5102767bbddf
          name: view-applications
          description: "$${role_view-applications}"
          composite: false
          clientRole: true
          containerId: d5828b63-66ba-47fc-a55b-490bac640c90
          attributes: {}
        - id: 6fb497b7-cf3f-4d0a-a7c2-72460a89c87e
          name: delete-account
          description: "$${role_delete-account}"
          composite: false
          clientRole: true
          containerId: d5828b63-66ba-47fc-a55b-490bac640c90
          attributes: {}
        - id: 5606f02e-57eb-401d-bde6-c2f07f210bd6
          name: view-consent
          description: "$${role_view-consent}"
          composite: false
          clientRole: true
          containerId: d5828b63-66ba-47fc-a55b-490bac640c90
          attributes: {}
        - id: a4a30a88-719e-4b20-9e3f-8ffa1e983471
          name: manage-account
          description: "$${role_manage-account}"
          composite: true
          composites:
            client:
              account:
              - manage-account-links
          clientRole: true
          containerId: d5828b63-66ba-47fc-a55b-490bac640c90
          attributes: {}
        - id: d17b5548-9522-4033-8761-14d91f5c6d43
          name: manage-consent
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
    - id: 65ba1f94-2f01-4abc-a998-b0c7ad00ee88
      name: Super Users
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
    - id: d5828b63-66ba-47fc-a55b-490bac640c90
      clientId: account
      name: "$${client_account}"
      rootUrl: "$${authBaseUrl}"
      baseUrl: "/realms/${keycloak_dfsp_realm_name}/account/"
      surrogateAuthRequired: false
      enabled: true
      alwaysDisplayInConsole: false
      clientAuthenticatorType: client-secret
      defaultRoles:
      - view-profile
      - manage-account
      redirectUris:
      - "/realms/${keycloak_dfsp_realm_name}/account/*"
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
    - id: 6f7911df-28fa-43ad-adf5-f194409e938e
      clientId: account-console
      name: "$${client_account-console}"
      rootUrl: "$${authBaseUrl}"
      baseUrl: "/realms/${keycloak_dfsp_realm_name}/account/"
      surrogateAuthRequired: false
      enabled: true
      alwaysDisplayInConsole: false
      clientAuthenticatorType: client-secret
      redirectUris:
      - "/realms/${keycloak_dfsp_realm_name}/account/*"
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
      - id: 84fe8099-7dba-43a4-9a0d-aeeb752f7931
        name: audience resolve
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
    - id: d8d7bca5-f2a2-423a-b8fa-98b4b633451e
      clientId: admin-cli
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
    - id: 9b46fb1e-e281-4ce7-be76-cc77b73929cc
      clientId: broker
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
    - id: 152a25c5-bc13-4dba-9739-43ee05d76970
      clientId: ${pm4ml_oidc_client_id}
      rootUrl: ${frontend_root_url}
      baseUrl: ${frontend_base_url}
      surrogateAuthRequired: false
      enabled: true
      alwaysDisplayInConsole: false
      clientAuthenticatorType: client-secret
      secret: ${pm4ml_oidc_client_secret_secret_name}
      redirectUris:
        - "http://${portal_fqdn}:1234/*"
        - "http://${experience_api_fqdn}/*"
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
    - id: 67a3b6fc-64a5-4f64-81c8-1201319f0365
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
    - id: 48c863b4-54b8-4173-b1c8-1d0a9db57de9
      clientId: security-admin-console
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
      - id: 5d0fd882-404d-4b38-b18b-879fc1a58a8b
        name: locale
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
    - id: b88ca32c-29e3-408e-a72d-6a81e36723e1
      name: address
      description: 'OpenID Connect built-in scope: address'
      protocol: openid-connect
      attributes:
        include.in.token.scope: 'true'
        display.on.consent.screen: 'true'
        consent.screen.text: "$${addressScopeConsentText}"
      protocolMappers:
      - id: 298f6e52-8478-4078-9994-cee1b52a5008
        name: address
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
    - id: 561aebfc-ccba-4754-b4f8-af2b7f0ab3fd
      name: email
      description: 'OpenID Connect built-in scope: email'
      protocol: openid-connect
      attributes:
        include.in.token.scope: 'true'
        display.on.consent.screen: 'true'
        consent.screen.text: "$${emailScopeConsentText}"
      protocolMappers:
      - id: 40f7e54f-798e-49de-9c0e-74f631cf2499
        name: email verified
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
      - id: a59d9560-d9b2-423d-9f9a-26a124f435a7
        name: email
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
    - id: e25f47fe-6d1e-47c1-bd90-4829cf66bb7d
      name: microprofile-jwt
      description: Microprofile - JWT built-in scope
      protocol: openid-connect
      attributes:
        include.in.token.scope: 'true'
        display.on.consent.screen: 'false'
      protocolMappers:
      - id: 30d6519c-f797-409e-aa8c-c6946d7ef84b
        name: upn
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
      - id: '09cd5151-7482-4b23-b0d1-f36c9f530216'
        name: groups
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
    - id: c87355dc-5a3a-4529-a965-bd8571062559
      name: offline_access
      description: 'OpenID Connect built-in scope: offline_access'
      protocol: openid-connect
      attributes:
        consent.screen.text: "$${offlineAccessScopeConsentText}"
        display.on.consent.screen: 'true'
    - id: 73bc7545-ec2a-420b-90dc-a78e90c6d3bd
      name: phone
      description: 'OpenID Connect built-in scope: phone'
      protocol: openid-connect
      attributes:
        include.in.token.scope: 'true'
        display.on.consent.screen: 'true'
        consent.screen.text: "$${phoneScopeConsentText}"
      protocolMappers:
      - id: 2c6e6cb2-e78d-4d38-aa28-d90a845824c2
        name: phone number verified
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
      - id: 020d4b9c-79d7-4c66-8a18-916ed2902e5f
        name: phone number
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
    - id: 6d271619-b674-4705-b3fc-d233d637502b
      name: profile
      description: 'OpenID Connect built-in scope: profile'
      protocol: openid-connect
      attributes:
        include.in.token.scope: 'true'
        display.on.consent.screen: 'true'
        consent.screen.text: "$${profileScopeConsentText}"
      protocolMappers:
      - id: 82cfa3e4-3688-4980-bfcd-8dc88fe3a418
        name: profile
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
      - id: 2def807b-a552-420a-b6ec-d3a12ea68fc2
        name: gender
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
      - id: 486fe8ee-e8dd-463a-8b6c-d1b70af0a8b9
        name: full name
        protocol: openid-connect
        protocolMapper: oidc-full-name-mapper
        consentRequired: false
        config:
          id.token.claim: 'true'
          access.token.claim: 'true'
          userinfo.token.claim: 'true'
      - id: 6e0ce844-f28f-4a83-a645-df8cd306ac03
        name: birthdate
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
      - id: e5be4176-ddfb-4a44-9f37-7ecc57480b40
        name: updated at
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
      - id: f855c422-689b-4cf1-b0dc-f30994d2b715
        name: picture
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
      - id: 4494ab4b-6276-4e07-afd4-1fc7ba92576f
        name: zoneinfo
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
      - id: 85393263-4ad7-4d9d-876d-479dc455c7d6
        name: given name
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
      - id: 4f06428b-bd4c-448d-9a1c-ac9659591917
        name: middle name
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
      - id: 75cadbd8-010c-4253-a816-a8b0dff864a3
        name: username
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
      - id: f513b047-56ef-4e3f-b4bd-2126eaf91ac7
        name: nickname
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
      - id: 42cf502f-51b9-4914-9984-0544fa43ac8a
        name: locale
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
      - id: 402fa5b3-2ddf-445e-9b50-bc26a2e8c355
        name: family name
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
      - id: df507134-76c1-486e-be7a-98dea0eb827a
        name: website
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
    - id: 938e8879-2688-4790-b4d3-fabb1f40f048
      name: role_list
      description: SAML role list
      protocol: saml
      attributes:
        consent.screen.text: "$${samlRoleListScopeConsentText}"
        display.on.consent.screen: 'true'
      protocolMappers:
      - id: 3184641a-cc91-48a7-87b1-16eb1fbebfc3
        name: role list
        protocol: saml
        protocolMapper: saml-role-list-mapper
        consentRequired: false
        config:
          single: 'false'
          attribute.nameformat: Basic
          attribute.name: Role
    - id: 977d7448-6dc8-428c-9ac5-6d964361fb40
      name: roles
      description: OpenID Connect scope for add user roles to the access token
      protocol: openid-connect
      attributes:
        include.in.token.scope: 'true'
        display.on.consent.screen: 'true'
        consent.screen.text: "$${rolesScopeConsentText}"
      protocolMappers:
      - id: c05f0c47-e6d4-4b7b-a925-7fc3fbbacf68
        name: client roles
        protocol: openid-connect
        protocolMapper: oidc-usermodel-client-role-mapper
        consentRequired: false
        config:
          user.attribute: foo
          access.token.claim: 'true'
          claim.name: resource_access.$${client_id}.roles
          jsonType.label: String
          multivalued: 'true'
      - id: 3fe90e67-982b-4cfb-bcd0-4f3cc37a07d5
        name: audience resolve
        protocol: openid-connect
        protocolMapper: oidc-audience-resolve-mapper
        consentRequired: false
        config: {}
      - id: b150f242-d81d-4b70-8d9a-57f6080c7f51
        name: realm roles
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
    - id: e300c074-e2ec-45b9-8f89-351d186208d5
      name: web-origins
      description: OpenID Connect scope for add allowed web origins to the access token
      protocol: openid-connect
      attributes:
        include.in.token.scope: 'false'
        display.on.consent.screen: 'false'
        consent.screen.text: ''
      protocolMappers:
      - id: b8525936-6fa9-45e7-bebd-52be074afab9
        name: allowed web origins
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
      - id: 29d1f1eb-1c79-47ce-83a0-de47a8bd33fc
        name: Allowed Protocol Mapper Types
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
      - id: 1f8d6043-3292-4d24-aac6-90ac4a9976e0
        name: Max Clients Limit
        providerId: max-clients
        subType: anonymous
        subComponents: {}
        config:
          max-clients:
          - '200'
      - id: d43dd62d-f92f-406d-a56f-10a8821d7f40
        name: Allowed Protocol Mapper Types
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
      - id: 2ee0fcb5-9942-4371-8dae-7fdc7139d327
        name: Consent Required
        providerId: consent-required
        subType: anonymous
        subComponents: {}
        config: {}
      - id: 0f443aa2-80ff-411b-8dc8-71f0ddd1090d
        name: Trusted Hosts
        providerId: trusted-hosts
        subType: anonymous
        subComponents: {}
        config:
          host-sending-registration-request-must-match:
          - 'true'
          client-uris-must-match:
          - 'true'
      - id: 14c04c95-c3ef-4024-b4e3-2b4a38c8b33d
        name: Allowed Client Scopes
        providerId: allowed-client-templates
        subType: authenticated
        subComponents: {}
        config:
          allow-default-scopes:
          - 'true'
      - id: b3fd3084-98e5-484c-997a-f25b3d305511
        name: Full Scope Disabled
        providerId: scope
        subType: anonymous
        subComponents: {}
        config: {}
      - id: cb8e04a3-3a98-430c-baef-4d807596bedf
        name: Allowed Client Scopes
        providerId: allowed-client-templates
        subType: anonymous
        subComponents: {}
        config:
          allow-default-scopes:
          - 'true'
      org.keycloak.keys.KeyProvider:
      - id: 3d435c5c-817c-4980-a7b4-dba0db7e716b
        name: rsa-generated
        providerId: rsa-generated
        subComponents: {}
        config:
          priority:
          - '100'
      - id: cda2ca5e-3579-488a-91a1-810d9e88c919
        name: aes-generated
        providerId: aes-generated
        subComponents: {}
        config:
          priority:
          - '100'
      - id: 628a6954-5a7c-4802-91ec-122d8e43ec9d
        name: hmac-generated
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
    - id: d4a7a382-c002-4b50-ab71-c15bdd2bcdbf
      alias: Account verification options
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
    - id: 7ba78d82-2de6-41ab-ba34-0f18560c744f
      alias: Authentication Options
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
    - id: 8f753811-9dd6-4736-b1ae-a87c5c91542c
      alias: Browser - Conditional OTP
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
    - id: c63edba7-4dbc-428f-a0bc-3612ee06e413
      alias: Direct Grant - Conditional OTP
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
    - id: 7d2bf94f-573e-4a03-99b3-2644a6201d30
      alias: First broker login - Conditional OTP
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
    - id: 7ef785df-6476-4d3a-bf08-98f535e5e661
      alias: Handle Existing Account
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
    - id: 9d0034af-d9fc-4ad1-9aa2-4f554dfbc324
      alias: Reset - Conditional OTP
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
    - id: f81aec49-8932-4831-b4a7-a52034dda551
      alias: User creation or linking
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
    - id: 55058f6a-2a53-4cce-a69b-d7327b8bbb4c
      alias: Verify Existing Account by Re-authentication
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
    - id: 6260fc8f-f173-4441-a0a8-e727288020a7
      alias: browser
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
    - id: 7d43fcff-ddf5-4b9b-b47d-6d4b7428be21
      alias: clients
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
    - id: ac3f4ede-0870-48fd-b1ee-5acb61734f5d
      alias: direct grant
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
    - id: e89aa80e-2fb8-4785-8584-8a7a798f17c3
      alias: docker auth
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
    - id: 2bf75dc7-30b6-4b2f-add1-cbc492e65da6
      alias: first broker login
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
    - id: addcffbd-1527-4acd-8972-8dcde9ef6434
      alias: forms
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
    - id: 9ca7ac1e-e19c-4e6a-bb91-a175a14cf3f8
      alias: http challenge
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
    - id: 94a99a06-0183-4b0c-9348-7bac3f0ca077
      alias: registration
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
    - id: f13663bd-df7f-4c52-bf25-baad3e7626a6
      alias: registration form
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
    - id: 2d5bd5ee-dc51-4004-bbee-194007dcd659
      alias: reset credentials
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
    - id: 9dc6622c-3202-428b-83cf-0370cbfe3f88
      alias: saml ecp
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
    - id: cd5c5a28-3c13-4d3b-b740-46930526ac22
      alias: create unique user config
      config:
        require.password.update.after.registration: 'false'
    - id: e19e7d29-5878-46ce-8849-9ec23bc056f0
      alias: review profile config
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

