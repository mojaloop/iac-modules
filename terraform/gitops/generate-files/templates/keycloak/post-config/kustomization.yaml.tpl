apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - keycloak-cr.yaml
  - keycloak-ingress.yaml
  - vault-secret.yaml
secretGenerator:
- name: keycloak-user
  literals:
  - username=${keycloak_postgres_user}
generatorOptions:
  disableNameSuffixHash: true