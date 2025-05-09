apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: nbrouter-add-security-context
  annotations:
    policies.kyverno.io/title: Add security context to nbrouter deployment
    policies.kyverno.io/description: >-
      This policy updates pod security context of nbrouter deployment
    argocd.argoproj.io/sync-wave: "0"

spec:
  rules:
    - name: nbrouter-add-security-context
      match:
        any:
          - resources:
              kinds:
                - Pod
              namespaces:
                - ${netbird_operator_namespace}
              selector:
                matchLabels:
                  app.kubernetes.io/name: netbird-router
      mutate:
        patchStrategicMerge:
          spec:
            securityContext:
              sysctls:
                - name: net.ipv4.ip_forward
                  value: "1"
      preconditions:
        any:
          - key: "{{request.operation}}"
            operator: In
            value: ["CREATE", "UPDATE"]
      skipBackgroundRequests: true
  validationFailureAction: Audit
---
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: restart-netbird-operator
  annotations:
    policies.kyverno.io/title: Restart netbird operator pod on secret update
    policies.kyverno.io/description: >-
      This policy requires the restart of netbird operator pod when the secret is updated
    argocd.argoproj.io/sync-wave: "0"
spec:
  rules:
    - name: add-annotation-on-secret-update
      match:
        any:
          - resources:
              kinds:
                - Secret
              names:
                - ${netbird_operator_api_key_secret}
              namespaces:
                - ${netbird_operator_namespace}
      mutate:
        patchStrategicMerge:
          spec:
            template:
              metadata:
                annotations:
                  kyverno.platform.eon.com/triggerrestart: "{{request.object.metadata.resourceVersion}}"
        targets:
          - apiVersion: apps/v1
            kind: Deployment
            namespace: ${netbird_operator_namespace}
            selector:
              matchLabels:
                app.kubernetes.io/name: kubernetes-operator
      preconditions:
        all:
          - key: "{{request.operation}}"
            operator: Equals
            value: UPDATE
      skipBackgroundRequests: true
  validationFailureAction: Audit
