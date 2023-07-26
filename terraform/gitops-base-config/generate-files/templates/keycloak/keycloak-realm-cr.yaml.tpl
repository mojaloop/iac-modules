apiVersion: k8s.keycloak.org/v2alpha1
kind: KeycloakRealmImport
metadata:
  name: ${keycloak_dfsp_realm_name}
spec:
  keycloakCRName: ${keycloak_name}
  realm:
    id: 3bf1f193-ef85-40e7-8456-a997cbfaf5fe
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
    id: a6349506-580f-4ee1-b1d7-8f1edb151a01
    name: default-roles-${keycloak_dfsp_realm_name}
    description: $${role_default-roles}
    composite: true
    clientRole: false
    containerId: 3bf1f193-ef85-40e7-8456-a997cbfaf5fe
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
    - id: c9baf4da-33d9-4a32-859e-567fec725a5a
        createdTimestamp: 1690377454835
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
    - id: e8f1d263-62a8-4a24-954f-c1225e1d47ae
        clientId: account
        name: $${client_account}
        rootUrl: $${authBaseUrl}
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
    - id: 297fc96f-f814-4954-89e4-976edd4ae3e4
        clientId: account-console
        name: $${client_account-console}
        rootUrl: $${authBaseUrl}
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
        - id: 23039ef7-122d-4721-9025-7241d971f1a0
            name: audience resolve
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
    - id: 5fb8e1dd-5018-4ab4-ac47-42272a21c84e
        clientId: admin-cli
        name: $${client_admin-cli}
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
        - acr
        - profile
        - roles
        - email
        optionalClientScopes:
        - address
        - phone
        - offline_access
        - microprofile-jwt
    - id: 2f98a470-f230-4148-a993-35cbfd416211
        clientId: broker
        name: $${client_broker}
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
        - acr
        - profile
        - roles
        - email
        optionalClientScopes:
        - address
        - phone
        - offline_access
        - microprofile-jwt
    - id: cf3bd941-2c1d-4c2a-824e-3731df7658cf
        clientId: dfsp-jwt
        name: dfsp-jwt
        description: ''
        rootUrl: ''
        adminUrl: ''
        baseUrl: ''
        surrogateAuthRequired: false
        enabled: true
        alwaysDisplayInConsole: false
        clientAuthenticatorType: client-secret
        secret: '**********'
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
        backchannel.logout.revoke.offline.tokens: 'false'
        authenticationFlowBindingOverrides: {}
        fullScopeAllowed: true
        nodeReRegistrationTimeout: -1
        protocolMappers:
        - id: a17e14bd-bf3a-4fbb-b8b3-aa374bb8d849
            name: Client Host
            protocol: openid-connect
            protocolMapper: oidc-usersessionmodel-note-mapper
            consentRequired: false
            config:
            user.session.note: clientHost
            id.token.claim: 'true'
            access.token.claim: 'true'
            claim.name: clientHost
            jsonType.label: String
        - id: 991e51f2-9dc6-48fc-aea0-30ac85b5ce4a
            name: Client ID
            protocol: openid-connect
            protocolMapper: oidc-usersessionmodel-note-mapper
            consentRequired: false
            config:
            user.session.note: client_id
            id.token.claim: 'true'
            access.token.claim: 'true'
            claim.name: client_id
            jsonType.label: String
        - id: 34726709-ae0c-4dec-bf8e-d2e14dd1e869
            name: Client IP Address
            protocol: openid-connect
            protocolMapper: oidc-usersessionmodel-note-mapper
            consentRequired: false
            config:
            user.session.note: clientAddress
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
    - id: 575788c3-ed21-408d-b6ea-5f14740660ff
        clientId: realm-management
        name: $${client_realm-management}
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
        - acr
        - profile
        - roles
        - email
        optionalClientScopes:
        - address
        - phone
        - offline_access
        - microprofile-jwt
    - id: 018de02a-973b-4296-ac66-c7ed0452ed5c
        clientId: security-admin-console
        name: $${client_security-admin-console}
        rootUrl: $${authAdminUrl}
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
        - id: fea7700e-a644-48b1-b9da-06191dd5e687
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
        - profile
        - roles
        - email
        optionalClientScopes:
        - address
        - phone
        - offline_access
        - microprofile-jwt
    clientScopes:
    - id: 3674c397-3692-41ae-b045-1cc2f235ce36
        name: web-origins
        description: OpenID Connect scope for add allowed web origins to the access token
        protocol: openid-connect
        attributes:
        include.in.token.scope: 'false'
        display.on.consent.screen: 'false'
        consent.screen.text: ''
        protocolMappers:
        - id: 8791234a-887e-4dff-9fe3-c2d49e310436
            name: allowed web origins
            protocol: openid-connect
            protocolMapper: oidc-allowed-origins-mapper
            consentRequired: false
            config: {}
    - id: d00e0f67-c144-4809-9793-5f2aa62f41db
        name: offline_access
        description: 'OpenID Connect built-in scope: offline_access'
        protocol: openid-connect
        attributes:
        consent.screen.text: $${offlineAccessScopeConsentText}
        display.on.consent.screen: 'true'
    - id: 6e203bdb-f98d-400f-8e15-af452bfdcf6c
        name: profile
        description: 'OpenID Connect built-in scope: profile'
        protocol: openid-connect
        attributes:
        include.in.token.scope: 'true'
        display.on.consent.screen: 'true'
        consent.screen.text: $${profileScopeConsentText}
        protocolMappers:
        - id: e0758923-1b8f-4957-880e-261aa181f5df
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
        - id: 1aae48a9-8fd1-4786-a749-50cbe24d8d76
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
        - id: 8141fca8-ce33-436f-864d-b0a19431d0dc
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
        - id: c5a66193-4acb-48b5-9c29-9300faa5f594
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
        - id: a462fa68-6b7f-4f5f-9a08-29fb3774a3bc
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
        - id: fb7a644e-d7c0-432f-9850-049403abb82d
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
        - id: a0c740cc-f02f-4c26-942b-edff9a9a9a30
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
        - id: aa07aca1-0ff3-48fa-bee8-590d79353f41
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
        - id: 1a490473-0401-4b92-b355-4f516e0da83a
            name: full name
            protocol: openid-connect
            protocolMapper: oidc-full-name-mapper
            consentRequired: false
            config:
            id.token.claim: 'true'
            access.token.claim: 'true'
            userinfo.token.claim: 'true'
        - id: 9e189f3f-dad7-4e59-bc17-88c38421609b
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
        - id: cfa9b024-36a8-4507-97a9-8842f434ab9f
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
        - id: a641c6e6-90b7-4c72-9cc6-a4f8ff1ec6bd
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
        - id: 0a194e5a-8d4e-4a8d-8215-0b8439fd34e0
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
        - id: 82e0dea0-ed14-4aeb-aafa-e9bc7bddf108
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
    - id: 0fbb1e21-b415-4716-b1cc-56600826640c
        name: email
        description: 'OpenID Connect built-in scope: email'
        protocol: openid-connect
        attributes:
        include.in.token.scope: 'true'
        display.on.consent.screen: 'true'
        consent.screen.text: $${emailScopeConsentText}
        protocolMappers:
        - id: f75fbfd1-5e88-497d-b13e-ffe5e1d2973d
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
        - id: 023059e0-5226-4dc0-9598-a4642f6e6c7f
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
    - id: 4bcce258-9d3e-4944-ba38-e87d044add9c
        name: roles
        description: OpenID Connect scope for add user roles to the access token
        protocol: openid-connect
        attributes:
        include.in.token.scope: 'false'
        display.on.consent.screen: 'true'
        consent.screen.text: $${rolesScopeConsentText}
        protocolMappers:
        - id: 87e64ec4-3b39-4fc9-ba57-cf95bb798143
            name: audience resolve
            protocol: openid-connect
            protocolMapper: oidc-audience-resolve-mapper
            consentRequired: false
            config: {}
        - id: a9bdb262-24fb-4344-abd3-bb3008fc6ea7
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
        - id: 1196932d-e1f0-4fc1-b891-0850ad5db117
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
    - id: 6239131f-f5ef-4277-9d90-ca8b693e823d
        name: microprofile-jwt
        description: Microprofile - JWT built-in scope
        protocol: openid-connect
        attributes:
        include.in.token.scope: 'true'
        display.on.consent.screen: 'false'
        protocolMappers:
        - id: d0a3e6c6-6143-47a4-a079-7a5d55cd69b3
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
        - id: 63a0053e-3167-4286-a0fc-3624491dbe2a
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
    - id: d9d11f27-ca5e-49ce-a2a2-bb26f9eb5fa9
        name: acr
        description: >-
        OpenID Connect scope for add acr (authentication context class reference)
        to the token
        protocol: openid-connect
        attributes:
        include.in.token.scope: 'false'
        display.on.consent.screen: 'false'
        protocolMappers:
        - id: d814911a-10b3-4b70-ae22-36bda32185a7
            name: acr loa level
            protocol: openid-connect
            protocolMapper: oidc-acr-mapper
            consentRequired: false
            config:
            id.token.claim: 'true'
            access.token.claim: 'true'
    - id: 5b15adf4-d7bd-4802-b9e4-f1e69290c0f0
        name: role_list
        description: SAML role list
        protocol: saml
        attributes:
        consent.screen.text: $${samlRoleListScopeConsentText}
        display.on.consent.screen: 'true'
        protocolMappers:
        - id: e3153860-11ee-411f-b680-69d6d2509d0a
            name: role list
            protocol: saml
            protocolMapper: saml-role-list-mapper
            consentRequired: false
            config:
            single: 'false'
            attribute.nameformat: Basic
            attribute.name: Role
    - id: 0be9ec53-6a5d-4edb-a14b-a247749a1777
        name: phone
        description: 'OpenID Connect built-in scope: phone'
        protocol: openid-connect
        attributes:
        include.in.token.scope: 'true'
        display.on.consent.screen: 'true'
        consent.screen.text: $${phoneScopeConsentText}
        protocolMappers:
        - id: 9063d321-29a5-4c95-91d5-caa7e4ccacb1
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
        - id: 38947555-e93a-4775-9a42-f27a01d3ab53
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
    - id: 4c476abb-1d3d-47aa-8766-5278634c537e
        name: address
        description: 'OpenID Connect built-in scope: address'
        protocol: openid-connect
        attributes:
        include.in.token.scope: 'true'
        display.on.consent.screen: 'true'
        consent.screen.text: $${addressScopeConsentText}
        protocolMappers:
        - id: 6865db49-2168-43a9-a4cb-60c6fc05abc2
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
        - id: b0d74461-6901-4c30-ab3d-2fd8238c0070
        name: Consent Required
        providerId: consent-required
        subType: anonymous
        subComponents: {}
        config: {}
        - id: 8ebd15d9-9c7f-40e7-bdb3-f897bbe6d535
        name: Max Clients Limit
        providerId: max-clients
        subType: anonymous
        subComponents: {}
        config:
            max-clients:
            - '200'
        - id: 8b151985-5e5a-43f6-a124-9943621c84bb
        name: Allowed Client Scopes
        providerId: allowed-client-templates
        subType: authenticated
        subComponents: {}
        config:
            allow-default-scopes:
            - 'true'
        - id: c369d95a-011e-4815-aa78-8a449346de9c
        name: Allowed Protocol Mapper Types
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
        - id: 7d5145d7-7071-489c-87d1-8ad735279380
        name: Allowed Client Scopes
        providerId: allowed-client-templates
        subType: anonymous
        subComponents: {}
        config:
            allow-default-scopes:
            - 'true'
        - id: 671ea876-2b79-4546-9e44-cb326dafb510
        name: Trusted Hosts
        providerId: trusted-hosts
        subType: anonymous
        subComponents: {}
        config:
            host-sending-registration-request-must-match:
            - 'true'
            client-uris-must-match:
            - 'true'
        - id: a9baceb7-c221-424d-81f3-e81d2518a3bd
        name: Allowed Protocol Mapper Types
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
        - id: dfa0e94d-a039-4d0f-ab28-7d40935f2467
        name: Full Scope Disabled
        providerId: scope
        subType: anonymous
        subComponents: {}
        config: {}
    org.keycloak.keys.KeyProvider:
        - id: ab109bcb-c8e1-451f-b611-2576173f959e
        name: aes-generated
        providerId: aes-generated
        subComponents: {}
        config:
            priority:
            - '100'
        - id: e29a5ddb-299b-4232-90d5-14604828e828
        name: hmac-generated
        providerId: hmac-generated
        subComponents: {}
        config:
            priority:
            - '100'
            algorithm:
            - HS256
        - id: 68882c21-3af3-4c40-b0e7-025cf65bc88b
        name: rsa-generated
        providerId: rsa-generated
        subComponents: {}
        config:
            priority:
            - '100'
        - id: d69edfbd-e8b5-484e-84df-ea30f7241db4
        name: rsa-enc-generated
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
    - id: 749c3de4-1ae9-442a-bb1f-df34da575009
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
    - id: 5ea48625-f870-45b4-b2c7-8ae0b6fff626
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
    - id: b7a3fd17-4a8a-46bf-a9a8-d6c949b1c7f4
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
    - id: 6de29bb1-840a-4537-ad1d-99895f32333a
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
    - id: 7cf346de-2204-4d3c-bb08-4b616ad5611d
        alias: Handle Existing Account
        description: >-
        Handle what to do if there is existing account with same email/username
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
    - id: 703a2c1d-3d6d-44ac-ab8a-1fdeb17352c2
        alias: Reset - Conditional OTP
        description: >-
        Flow to determine if the OTP should be reset or not. Set to REQUIRED to
        force.
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
    - id: 5d360f8d-65c4-4436-843d-222392628a4c
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
    - id: 5cd7d768-413b-4142-9603-6fdb4337ff3c
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
    - id: 692652b6-aafa-49bf-95b3-508746a500d3
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
    - id: 3ee745a7-0bbe-4c8b-8887-8c0cf9518f5e
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
    - id: f3d279e8-e548-414d-9647-6162b6206e9b
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
    - id: ff4b8e0d-f154-4fae-9c14-05d4e1301b43
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
    - id: f0e48414-879e-4327-92e6-b318234166c1
        alias: first broker login
        description: >-
        Actions taken after first broker login with identity provider account,
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
    - id: 1872f234-e21b-48df-ab10-c1fb4996ea4e
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
    - id: aac87ed4-db08-402f-93df-2dbdeb269877
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
    - id: 867098c3-8cb5-45eb-bad7-bb4e748b3364
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
    - id: d14c763d-e3a9-46b7-a985-07011965122b
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
    - id: c7e826cc-9dea-4088-acde-b64317a50d64
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
    - id: 63dfdd4b-b440-4e8f-94ff-354413e8221c
        alias: create unique user config
        config:
        require.password.update.after.registration: 'false'
    - id: 5913b730-3004-4576-b9be-e8096925e34e
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
    keycloakVersion: 22.0.1
    userManagedAccessAllowed: false
    clientProfiles:
    profiles: []
    clientPolicies:
    policies: []
