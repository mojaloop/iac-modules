apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - https://raw.githubusercontent.com/keycloak/keycloak-k8s-resources/${keycloak_operator_version}/kubernetes/keycloaks.k8s.keycloak.org-v1.yml
  - https://raw.githubusercontent.com/keycloak/keycloak-k8s-resources/${keycloak_operator_version}/kubernetes/keycloakrealmimports.k8s.keycloak.org-v1.yml
  - https://raw.githubusercontent.com/keycloak/keycloak-k8s-resources/${keycloak_operator_version}/kubernetes/kubernetes.yml
  - keycloak-cert.yaml
  - keycloak-cr.yaml
  - keycloak-ingress.yaml
secretGenerator:
- name: keycloak-user
  literals:
  - username=${keycloak_postgres_user}
generatorOptions:
  disableNameSuffixHash: true