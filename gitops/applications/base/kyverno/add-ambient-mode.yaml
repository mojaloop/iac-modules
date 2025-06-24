apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: add-ambient-mode-namespace
spec:
  rules:
    - name: add-ambient-mode-enabled
      match:
        any:
          - resources:
              kinds:
                - Namespace
      exclude:
        any:
          # Hardcoded namespace exclusions
          - resources:
              namespaces:
                - "kube-system"
                - "kube-public"
                - "istio-system"

          # Exclude namespaces with specific labels (OR condition)
          - resources:
              selector:
                matchLabels:
                  opt-out-mesh: "true" # Example 2 (optional)
      mutate:
        patchStrategicMerge:
          metadata:
            labels:
              istio.io/dataplane-mode: ambient
