apiVersion: redhatcop.redhat.io/v1alpha1
kind: SecretEngineMount
metadata:
  name: ${vault_root_ca_name}
  namespace: ${vault_pki_namespace}
spec:
  authentication:
    path: kubernetes
    role: policy-admin
    serviceAccount:
      name: default
  type: pki
  path: "/"
  config:
    defaultLeaseTTL: "8760h"
    maxLeaseTTL: "87600h"
---
apiVersion: redhatcop.redhat.io/v1alpha1
kind: PKISecretEngineConfig
metadata:
  name: ${vault_root_ca_name}
  namespace: ${vault_pki_namespace}
spec:
  authentication:
    path: kubernetes
    role: policy-admin
    serviceAccount:
      name: default
  path: ${vault_root_ca_name}
  TTL: "87600h"
---
apiVersion: redhatcop.redhat.io/v1alpha1
kind: PKISecretEngineRole
metadata:
  name: ${pki_server_cert_role}
  namespace: ${vault_pki_namespace}
spec:
  authentication:
    path: kubernetes
    role: policy-admin
    serviceAccount:
      name: default
  path: ${vault_root_ca_name}
  allowedDomains:
   - ${trimsuffix(public_subdomain, ".")}
  maxTTL: "2160h"
  TTL: "2160h"
  allowSubdomains: true
  allowGlobDomains: false
  allowAnyName: false
  enforceHostnames: true
  allowIPSans: true
  serverFlag: true
  clientFlag: false
  ou: "Infrastructure Team"
  organization: "Infitx"
  keyBits: 2048
  noStore: true
  requireCn: false
---
apiVersion: redhatcop.redhat.io/v1alpha1
kind: PKISecretEngineRole
metadata:
  name: ${pki_client_cert_role}
  namespace: ${vault_pki_namespace}
spec:
  authentication:
    path: kubernetes
    role: policy-admin
    serviceAccount:
      name: default
  path: ${vault_root_ca_name}
  allowedDomains:
   - ${trimsuffix(public_subdomain, ".")}
  maxTTL: "2160h"
  TTL: "2160h"
  allowSubdomains: true
  allowGlobDomains: false
  allowBareDomains: true
  enforceHostnames: true
  allowIPSans: true
  serverFlag: false
  clientFlag: true
  ou: "Infrastructure Team"
  organization: "Infitx"
  keyBits: 2048
  noStore: true
  requireCn: false
---
apiVersion: redhatcop.redhat.io/v1alpha1
kind: Policy
metadata:
  name: base-token-polcies
  namespace: ${vault_pki_namespace}
spec:
  authentication:
    path: kubernetes
    role: policy-admin
    serviceAccount:
      name: default
  policy: |
    # Configure read secrets
    path "auth/token/lookup-accessor" {
      capabilities = ["update"]
    }
    path "auth/token/revoke-accessor" {
      capabilities = ["update"]
    }
  type: acl
---
apiVersion: redhatcop.redhat.io/v1alpha1
kind: Policy
metadata:
  name: pki-root-full
  namespace: ${vault_pki_namespace}
spec:
  authentication:
    path: kubernetes
    role: policy-admin
    serviceAccount:
      name: default
  policy: |
    path "${vault_root_ca_name}/*" {
      capabilities = ["create", "read", "update", "delete", "list"]
    }
  type: acl
---