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
          spec:
            containers:
              - name: netbird
                image: netbirdio/netbird:${netbird_image_version}
                imagePullPolicy: Always
                args:
                  - --setup-key-file
                  - /etc/nbkey
                  - -m
                  - ${netbird_management_url}
                env:
                  - name: NB_SETUP_KEY
                    valueFrom:
                      secretKeyRef:
                        name: ${netbird_setup_key_secret_name}
                        key: ${netbird_setup_key_secret_key}
                  - name: NB_MANAGEMENT_URL
                    value: ${netbird_management_url}
                securityContext:
                  runAsUser: 0
                  runAsGroup: 0
                  runAsNonRoot: false
                  capabilities:
                    add:
                      - NET_ADMIN
    - name: copy-netbird-secret
      match:
        any:
        - resources:
            kinds:
            - Namespace
            name: storage
      generate:
        synchronize: true
        apiVersion: v1
        kind: Secret
        name: ${netbird_setup_key_name}
        namespace: "storage"
        clone:
          namespace: "${netbird_setup_key_namespace}"
          name: ${netbird_setup_key_name}
    - name: copy-netbird-secret-xplane
      match:
        any:
        - resources:
            kinds:
            - Namespace
            name: crossplane-system
      generate:
        synchronize: true
        apiVersion: v1
        kind: Secret
        name: ${netbird_setup_key_name}
        namespace: "crossplane-system"
        clone:
          namespace: "${netbird_setup_key_namespace}"
          name: ${netbird_setup_key_name}
