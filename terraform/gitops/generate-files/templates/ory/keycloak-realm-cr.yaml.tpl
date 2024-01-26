apiVersion: k8s.keycloak.org/v2alpha1
kind: KeycloakRealmImport
metadata:
  name: ${keycloak_kratos_realm_name}
  namespace: ${keycloak_namespace}
spec:
  keycloakCRName: ${keycloak_name}
  realm:
    id: 3966e35c-5461-4280-9f47-f30f1bf07bc4
    realm: ${keycloak_kratos_realm_name}
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
      id: 6f5b2abc-67f8-40d5-b214-4198f33328ba
      name: default-roles-kratos
      description: '$${role_default-roles}'
      composite: true
      clientRole: false
      containerId: 3966e35c-5461-4280-9f47-f30f1bf07bc4
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
    - id: fe42ec55-74e7-494b-8028-a5910fde47b2
      clientId: account
      name: '$${client_account}'
      rootUrl: '$${authBaseUrl}'
      baseUrl: "/realms/${keycloak_kratos_realm_name}/account/"
      surrogateAuthRequired: false
      enabled: true
      alwaysDisplayInConsole: false
      clientAuthenticatorType: client-secret
      redirectUris:
      - "/realms/${keycloak_kratos_realm_name}/account/*"
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
      - roles
      - profile
      - email
      optionalClientScopes:
      - address
      - phone
      - offline_access
      - microprofile-jwt
    - id: 4f6d41f5-6478-49e1-b796-615ca93149ec
      clientId: account-console
      name: '$${client_account-console}'
      rootUrl: '$${authBaseUrl}'
      baseUrl: "/realms/${keycloak_kratos_realm_name}/account/"
      surrogateAuthRequired: false
      enabled: true
      alwaysDisplayInConsole: false
      clientAuthenticatorType: client-secret
      redirectUris:
      - "/realms/${keycloak_kratos_realm_name}/account/*"
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
      - id: 22fabaef-6934-4439-9276-c898bf6a8bc4
        name: audience resolve
        protocol: openid-connect
        protocolMapper: oidc-audience-resolve-mapper
        consentRequired: false
        config: {}
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
    - id: 0b0e4661-6d01-4058-92c9-76a1efd802ab
      clientId: admin-cli
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
        post.logout.redirect.uris: +
      authenticationFlowBindingOverrides: {}
      fullScopeAllowed: false
      nodeReRegistrationTimeout: 0
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
    - id: 7baf5e07-58a8-4edd-a891-1d1fd0152b46
      clientId: broker
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
        post.logout.redirect.uris: +
      authenticationFlowBindingOverrides: {}
      fullScopeAllowed: false
      nodeReRegistrationTimeout: 0
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
    - id: 4747d00a-859b-4d3d-b952-e36fd9660c6d
      clientId: '${kratos_oidc_client_id}'
      name: '${kratos_oidc_client_id}'
      description: ''
      rootUrl: ''
      adminUrl: ''
      baseUrl: ''
      surrogateAuthRequired: false
      enabled: true
      alwaysDisplayInConsole: false
      clientAuthenticatorType: client-secret
      secret: ${kratos_oidc_client_secret_secret_name}
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
    - id: ce8b8b2d-71b8-4ecc-a306-ba657c9e8403
      clientId: realm-management
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
        post.logout.redirect.uris: +
      authenticationFlowBindingOverrides: {}
      fullScopeAllowed: false
      nodeReRegistrationTimeout: 0
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
    - id: 2c52db25-d2df-402f-b9aa-ac77117c469d
      clientId: security-admin-console
      name: '$${client_security-admin-console}'
      rootUrl: '$${authAdminUrl}'
      baseUrl: "/admin/${keycloak_kratos_realm_name}/console/"
      surrogateAuthRequired: false
      enabled: true
      alwaysDisplayInConsole: false
      clientAuthenticatorType: client-secret
      redirectUris:
      - "/admin/${keycloak_kratos_realm_name}/console/*"
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
      - id: 26cb1f7f-f99e-4d12-b125-d8ba81a656f4
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
      - acr
      - roles
      - profile
      - email
      optionalClientScopes:
      - address
      - phone
      - offline_access
      - microprofile-jwt
    clientScopes:
    - id: 4199c8c5-09fc-40e2-9994-5e220f11826d
      name: phone
      description: 'OpenID Connect built-in scope: phone'
      protocol: openid-connect
      attributes:
        include.in.token.scope: 'true'
        display.on.consent.screen: 'true'
        consent.screen.text: '$${phoneScopeConsentText}'
      protocolMappers:
      - id: eb777c70-ee95-4296-a981-a4fb73736a5e
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
      - id: 152a86f1-835d-4ae6-aabb-5d5604054e41
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
    - id: 76b94df7-554d-452a-8b47-e9ae35b9da98
      name: roles
      description: OpenID Connect scope for add user roles to the access token
      protocol: openid-connect
      attributes:
        include.in.token.scope: 'false'
        display.on.consent.screen: 'true'
        consent.screen.text: '$${rolesScopeConsentText}'
      protocolMappers:
      - id: 62cd0514-84f1-4c26-8f53-0851d3026ffa
        name: audience resolve
        protocol: openid-connect
        protocolMapper: oidc-audience-resolve-mapper
        consentRequired: false
        config: {}
      - id: 0735adae-e24f-4640-b712-4ab8c23a97c0
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
      - id: 68e037f5-019a-4ffa-9479-b3e7ad94d093
        name: realm roles
        protocol: openid-connect
        protocolMapper: oidc-usermodel-realm-role-mapper
        consentRequired: false
        config:
          user.attribute: foo
          access.token.claim: 'true'
          claim.name: realm_access.roles
          jsonType.label: String
          multivalued: 'true'
    - id: d40cdf7b-3598-4b2f-a525-8adc0b235914
      name: offline_access
      description: 'OpenID Connect built-in scope: offline_access'
      protocol: openid-connect
      attributes:
        consent.screen.text: '$${offlineAccessScopeConsentText}'
        display.on.consent.screen: 'true'
    - id: 7d684713-10e0-4790-9a4b-46bb3961903b
      name: role_list
      description: SAML role list
      protocol: saml
      attributes:
        consent.screen.text: '$${samlRoleListScopeConsentText}'
        display.on.consent.screen: 'true'
      protocolMappers:
      - id: 448b8f19-010c-42a4-bf88-8f93426db3ec
        name: role list
        protocol: saml
        protocolMapper: saml-role-list-mapper
        consentRequired: false
        config:
          single: 'false'
          attribute.nameformat: Basic
          attribute.name: Role
    - id: f2688156-a258-4905-9954-e515e6667e83
      name: web-origins
      description: OpenID Connect scope for add allowed web origins to the access token
      protocol: openid-connect
      attributes:
        include.in.token.scope: 'false'
        display.on.consent.screen: 'false'
        consent.screen.text: ''
      protocolMappers:
      - id: 72ecc90e-9c08-468e-b0ca-4ebde23f2a62
        name: allowed web origins
        protocol: openid-connect
        protocolMapper: oidc-allowed-origins-mapper
        consentRequired: false
        config: {}
    - id: 2ba2ceed-6c05-4485-9998-43aec0f29a4f
      name: acr
      description: OpenID Connect scope for add acr (authentication context class reference)
        to the token
      protocol: openid-connect
      attributes:
        include.in.token.scope: 'false'
        display.on.consent.screen: 'false'
      protocolMappers:
      - id: 48d6f88b-c32b-4152-8951-c86cab35e170
        name: acr loa level
        protocol: openid-connect
        protocolMapper: oidc-acr-mapper
        consentRequired: false
        config:
          id.token.claim: 'true'
          access.token.claim: 'true'
    - id: c6f73ce7-3111-4a41-b298-d7ae1c154c9e
      name: microprofile-jwt
      description: Microprofile - JWT built-in scope
      protocol: openid-connect
      attributes:
        include.in.token.scope: 'true'
        display.on.consent.screen: 'false'
      protocolMappers:
      - id: 5859e23c-9597-4233-9506-c08e86780166
        name: groups
        protocol: openid-connect
        protocolMapper: oidc-usermodel-realm-role-mapper
        consentRequired: false
        config:
          multivalued: 'true'
          user.attribute: foo
          id.token.claim: 'true'
          access.token.claim: 'true'
          claim.name: groups
          jsonType.label: String
      - id: 3927834f-36e9-4810-adc9-81fc1f1ffdb4
        name: upn
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
    - id: 42c7c386-1b52-47d4-8415-5d9ecfaa3f7a
      name: address
      description: 'OpenID Connect built-in scope: address'
      protocol: openid-connect
      attributes:
        include.in.token.scope: 'true'
        display.on.consent.screen: 'true'
        consent.screen.text: '$${addressScopeConsentText}'
      protocolMappers:
      - id: 0ef44298-f08b-4b81-ab45-7800128ee7a7
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
    - id: ff9f858b-1685-44eb-bc7d-e4d945563665
      name: profile
      description: 'OpenID Connect built-in scope: profile'
      protocol: openid-connect
      attributes:
        include.in.token.scope: 'true'
        display.on.consent.screen: 'true'
        consent.screen.text: '$${profileScopeConsentText}'
      protocolMappers:
      - id: fe2b056a-905a-46c1-b329-7127355c71ae
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
      - id: f98c10f7-9d8a-4318-a539-67e99ab2b411
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
      - id: 46bd6902-4cd6-404e-b298-baa7df77314c
        name: given name
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
      - id: 241784b6-e417-4730-a60e-569d0a8b5886
        name: username
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
      - id: 4089fff3-c90f-415a-ab21-e56401a72227
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
      - id: edc03b49-5972-456f-9b8e-9f5b852d4d96
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
      - id: 4086c284-7e7b-4597-8184-59eb808dfbcc
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
      - id: 95e49edf-5184-4472-8322-536809ecd160
        name: full name
        protocol: openid-connect
        protocolMapper: oidc-full-name-mapper
        consentRequired: false
        config:
          id.token.claim: 'true'
          access.token.claim: 'true'
          userinfo.token.claim: 'true'
      - id: 766ac657-2181-4c80-b111-cb0392bff92a
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
      - id: 9372c5a8-665b-4b7b-acb7-153c568ab317
        name: family name
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
      - id: f5574a68-3854-47ef-8926-71242538a06c
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
          jsonType.label: long
      - id: 8b6dcbff-09b4-442e-bcc6-5ea9fb2b6d15
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
      - id: 2a8d9094-7ad8-437a-bece-ddf437d7bd2f
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
      - id: 9beae9ce-7361-4179-a792-dab12e4ad6de
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
    - id: 1cdb662d-1681-4262-b9d1-de6a3dcdef1e
      name: email
      description: 'OpenID Connect built-in scope: email'
      protocol: openid-connect
      attributes:
        include.in.token.scope: 'true'
        display.on.consent.screen: 'true'
        consent.screen.text: '$${emailScopeConsentText}'
      protocolMappers:
      - id: f2d083ad-6b23-4759-bc05-fb2b502a65d6
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
      - id: 46c48eb4-fcf4-4c62-8a57-c248e18b589a
        name: email
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
      - id: 205f7b4c-02be-41a7-9fed-c0d67a324df4
        name: Consent Required
        providerId: consent-required
        subType: anonymous
        subComponents: {}
        config: {}
      - id: 983bd134-a454-435c-bd6f-44bf8a74e5cb
        name: Allowed Client Scopes
        providerId: allowed-client-templates
        subType: authenticated
        subComponents: {}
        config:
          allow-default-scopes:
          - 'true'
      - id: c480ff06-4b6d-490e-9346-6a19f907c17b
        name: Allowed Protocol Mapper Types
        providerId: allowed-protocol-mappers
        subType: authenticated
        subComponents: {}
        config:
          allowed-protocol-mapper-types:
          - saml-user-attribute-mapper
          - saml-user-property-mapper
          - oidc-usermodel-property-mapper
          - oidc-usermodel-attribute-mapper
          - oidc-sha256-pairwise-sub-mapper
          - saml-role-list-mapper
          - oidc-full-name-mapper
          - oidc-address-mapper
      - id: a442e93e-a30d-4eb9-a6e1-cd684671eb3a
        name: Trusted Hosts
        providerId: trusted-hosts
        subType: anonymous
        subComponents: {}
        config:
          host-sending-registration-request-must-match:
          - 'true'
          client-uris-must-match:
          - 'true'
      - id: b8c3d66c-9064-4f40-a523-35b3ac617acc
        name: Max Clients Limit
        providerId: max-clients
        subType: anonymous
        subComponents: {}
        config:
          max-clients:
          - '200'
      - id: c986bfa0-85d9-484f-b99b-90ca5124af0c
        name: Full Scope Disabled
        providerId: scope
        subType: anonymous
        subComponents: {}
        config: {}
      - id: 28df0f96-855e-4dd3-a2e6-83088332e06a
        name: Allowed Protocol Mapper Types
        providerId: allowed-protocol-mappers
        subType: anonymous
        subComponents: {}
        config:
          allowed-protocol-mapper-types:
          - oidc-sha256-pairwise-sub-mapper
          - oidc-address-mapper
          - oidc-usermodel-property-mapper
          - saml-user-attribute-mapper
          - saml-role-list-mapper
          - saml-user-property-mapper
          - oidc-usermodel-attribute-mapper
          - oidc-full-name-mapper
      - id: 1ba7cd55-881c-4b82-ae13-d063e10d2c7a
        name: Allowed Client Scopes
        providerId: allowed-client-templates
        subType: anonymous
        subComponents: {}
        config:
          allow-default-scopes:
          - 'true'
      org.keycloak.keys.KeyProvider:
      - id: 0a080e35-b539-4726-b233-204a9b9b8b0d
        name: rsa-enc-generated
        providerId: rsa-enc-generated
        subComponents: {}
        config:
          priority:
          - '100'
          algorithm:
          - RSA-OAEP
      - id: 18320b89-a5d7-4243-9062-09d2ba7f7928
        name: aes-generated
        providerId: aes-generated
        subComponents: {}
        config:
          priority:
          - '100'
      - id: a633651f-694c-4036-bb5f-04ea895f769d
        name: rsa-generated
        providerId: rsa-generated
        subComponents: {}
        config:
          priority:
          - '100'
      - id: ba90dfee-38d2-44ae-b883-ce2c07feb91e
        name: hmac-generated
        providerId: hmac-generated
        subComponents: {}
        config:
          priority:
          - '100'
          algorithm:
          - HS256
    internationalizationEnabled: false
    supportedLocales: []
    authenticationFlows:
    - id: 61d7b757-0689-4cc9-a0a6-5dabfbbb5fad
      alias: Account verification options
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
    - id: b574e98c-792d-4494-8b05-e0320733b745
      alias: Browser - Conditional OTP
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
    - id: 8f41dc43-782a-4613-8513-3d50b8f8027b
      alias: Direct Grant - Conditional OTP
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
    - id: fbaa2f11-a5ed-426c-b61c-8a979f4be745
      alias: First broker login - Conditional OTP
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
    - id: 8ad31650-d3d1-4c2a-bbf1-573e54d6e90b
      alias: Handle Existing Account
      description: Handle what to do if there is existing account with same email/username
        like authenticated identity provider
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
    - id: 837b6e4d-b1df-4e6b-9866-85e258b5a200
      alias: Reset - Conditional OTP
      description: Flow to determine if the OTP should be reset or not. Set to REQUIRED
        to force.
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
    - id: 29d77d36-7171-4cd5-8835-61d35ababea8
      alias: User creation or linking
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
    - id: dc0dec08-1f90-400f-b8d0-219591d6d016
      alias: Verify Existing Account by Re-authentication
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
    - id: 0decd379-88c3-4950-a4af-b12ca06d7e20
      alias: browser
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
    - id: fd71399c-d224-4323-9802-f37b43e20703
      alias: clients
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
    - id: 9ed42792-6128-47b7-a042-6c62b22ede50
      alias: direct grant
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
    - id: 3be8983d-0814-420c-bcf2-889dfa208985
      alias: docker auth
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
    - id: 00d39bbf-33e6-4958-86fb-a43843fbd6b9
      alias: first broker login
      description: Actions taken after first broker login with identity provider account,
        which is not yet linked to any Keycloak account
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
    - id: e2a9d383-c481-4a85-89ca-694589c2ab5a
      alias: forms
      description: Username, password, otp and other auth forms.
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
    - id: 33da0495-5c97-4155-8d1e-46085b194005
      alias: registration
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
    - id: 61d321f2-7c8a-4cc6-a83f-056324dce790
      alias: registration form
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
    - id: 1b66e35a-0470-406f-b686-c40045965dba
      alias: reset credentials
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
    - id: 579ac5ca-dd22-4815-9eea-ecba33d8238a
      alias: saml ecp
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
    - id: e98f0f9f-fffc-45d8-9e10-970c233b8e4c
      alias: create unique user config
      config:
        require.password.update.after.registration: 'false'
    - id: fcd9825c-4516-4242-9f86-ce1b33203919
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
      oauth2DevicePollingInterval: '5'
      parRequestUriLifespan: '60'
      cibaInterval: '5'
      realmReusableOtpCode: 'false'
    keycloakVersion: 22.0.2
    userManagedAccessAllowed: false
    clientProfiles:
      profiles: []
    clientPolicies:
      policies: []

