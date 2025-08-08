---
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: inject-netbird-sidecar
spec:
  rules:
    - name: inject-netbird-annotation
      match:
        any:
%{ for label in netbird_target_labels ~}
          - resources:
              kinds:
                - Pod
              selector:
                matchLabels:
                  ${label.name}: "${label.value}"
%{ endfor ~}
      mutate:
        patchStrategicMerge:
          metadata:
            annotations:
              netbird.io/setup-key: ${netbird_setup_key_name}
    - name: copy-netbird-secret
      match:
        any:
%{ for label in netbird_target_labels ~}
          - resources:
              kinds:
                - Pod
              selector:
                matchLabels:
                  ${label.name}: "${label.value}"
%{ endfor ~}
      exclude:
        any:
          - resources:
              namespaces:
                - "${netbird_setup_key_namespace}"
      generate:
        synchronize: true
        apiVersion: v1
        kind: Secret
        name: ${netbird_setup_key_name}
        namespace: "{{request.object.metadata.namespace}}"
        clone:
          namespace: "${netbird_setup_key_namespace}"
          name: ${netbird_setup_key_name}
    - name: copy-netbird-setupkey-cr
      match:
        any:
%{ for label in netbird_target_labels ~}
          - resources:
              kinds:
                - Pod
              selector:
                matchLabels:
                  ${label.name}: "${label.value}"
%{ endfor ~}
      exclude:
        any:
          - resources:
              namespaces:
                - "${netbird_setup_key_namespace}"
      generate:
        synchronize: true
        apiVersion: netbird.io/v1
        kind: NBSetupKey
        name: ${netbird_setup_key_name}
        namespace: "{{request.object.metadata.namespace}}"
        clone:
          namespace: "${netbird_setup_key_namespace}"
          name: ${netbird_setup_key_name}
