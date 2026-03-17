apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: restart-vault-on-tenancytoken-change
spec:
  rules:
    - name: restart-vault
      match:
        any:
          - resources:
              kinds:
                - Secret
              names:
                - ${vault_seal_token_secret}
              namespaces:
                - ${vault_namespace}
      mutate:
        targets:
          - apiVersion: apps/v1
            kind: StatefulSet
            name: vault
            namespace: vault
        patchStrategicMerge:
          spec:
            template:
              metadata:
                annotations:
                  secret.restartedAt: "{{ time_now_utc() }}"