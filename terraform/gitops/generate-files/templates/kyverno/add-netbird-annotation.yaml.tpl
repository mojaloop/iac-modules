---
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: inject-netbird-sidecar
spec:
  rules:
    - name: inject-netbird-annotation
      match:
        resources:
          kinds:
            - Pod
        any:
%{ for label in netbird_target_labels ~}
          - resources:
              selector:
                matchLabels:
                  app.kubernetes.io/name: "${label}"
%{ endfor ~}
      mutate:
        patchStrategicMerge:
          metadata:
            annotations:
              netbird.io/setup-key: ${netbird_setup_key_name}
