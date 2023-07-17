apiVersion: redhatcop.redhat.io/v1alpha1
kind: SecretEngineMount
metadata:
  name: pki-root-ca
spec:
  authentication: 
    path: kubernetes
    role: policy-admin
    serviceAccount:
      name: default
  type: pki
  path: "/"
  defaultLeaseTTL: "8760h"
  maxLeaseTTL: "17520h"
---
apiVersion: redhatcop.redhat.io/v1alpha1
kind: PKISecretEngineConfig
metadata:
  name: pki-root-ca
spec:
  authentication: 
    path: kubernetes
    role: policy-admin
    serviceAccount:
      name: default
  path: pki-root-ca
  TTL: "8760h"
---
apiVersion: redhatcop.redhat.io/v1alpha1
kind: PKISecretEngineRole
metadata:
  name: server-cert-role
spec:
  authentication: 
    path: kubernetes
    role: policy-admin
    serviceAccount:
      name: default
  path: pki-root-ca
  allowedDomains: 
   - ${trimsuffix(public_subdomain, ".")}
  maxTTL: "17520h"
  TTL: "17520h"
  allowSubdomains: true
  allowGlobDomains: false
  allowAnyName: false
  enforceHostnames: true
  allowIPSans: true
  serverFlag: true
  clientFlag: false
  ou: "Infrastructure Team"
  organization: "ModusBox"
  keyBits: 2048
  noStore: true
  requireCn: false
---
apiVersion: redhatcop.redhat.io/v1alpha1
kind: PKISecretEngineRole
metadata:
  name: client-cert-role
spec:
  authentication: 
    path: kubernetes
    role: policy-admin
    serviceAccount:
      name: default
  path: pki-root-ca
  allowedDomains: 
   - ${trimsuffix(public_subdomain, ".")}
  maxTTL: "17520h"
  TTL: "17520h"
  allowSubdomains: true
  allowGlobDomains: false
  allowBareDomains: true
  enforceHostnames: true
  allowIPSans: true
  serverFlag: false
  clientFlag: true
  ou: "Infrastructure Team"
  organization: "ModusBox"
  keyBits: 2048
  noStore: true
  requireCn: false
---
apiVersion: redhatcop.redhat.io/v1alpha1
kind: Policy
metadata:
  name: base-token-polcies
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
  name: whitelist-read-policy
spec:
  authentication: 
    path: kubernetes
    role: policy-admin
    serviceAccount:
      name: default
  policy: |
    # Configure read secrets
    path "${whitelist_secret_name_prefix}*" {
      capabilities = ["read", "list"]
    }
    path "secret/onboarding_*" {
      capabilities = ["read", "list"]
    }
  type: acl  
---
apiVersion: redhatcop.redhat.io/v1alpha1
kind: Policy
metadata:
  name: pki-root-full
spec:
  authentication: 
    path: kubernetes
    role: policy-admin
    serviceAccount:
      name: default
  policy: |
    path "pki-root-ca/*" {
      capabilities = ["create", "read", "update", "delete", "list"]
    }
  type: acl 
---