---
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: create-netbird-hostport-claim
  annotations:
    argocd.argoproj.io/sync-wave: "${kyverno_sync_wave}"
spec:
  rules:
    - name: create-hostport-claim-for-netbird-sidecars
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
      generate:
        synchronize: true
        apiVersion: hostport.rmb938.com/v1alpha1
        kind: HostPortClaim
        name: "{{request.object.metadata.ownerReferences[0].name | split(@, '-') | [0:-1] | join('-', @)}}"
        namespace: ${netbird_operator_namespace}
        spec:
          hostPortClassName: netbird-hostports
    - name: clone-netbird-secret-for-matching-pods
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
      generate:
        synchronize: true
        apiVersion: v1
        kind: Secret
        name: ${netbird_setup_key_name}
        namespace: "{{request.object.metadata.namespace}}"
        clone:
          namespace: "${netbird_setup_key_namespace}"
          name: ${netbird_setup_key_name}

---
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: inject-netbird-sidecar
  annotations:
    argocd.argoproj.io/sync-wave: "${kyverno_sync_wave}"
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
      preconditions:
        all:
        - key: "{{request.operation}}"
          operator: In
          value: ["CREATE", "UPDATE"]
      context:
        # 1. Lookup the HostPortClaim to get the HostPort resource name
        - name: hostportclaim
          apiCall:
            urlPath: "/apis/hostport.rmb938.com/v1alpha1/namespaces/${netbird_operator_namespace}/hostportclaims/{{ request.object.metadata.ownerReferences[0].name | split(@, '-') | [0:-1] | join('-', @) }}"
            jmesPath: "spec.hostPortName"
        # 2. Lookup the actual HostPort to get the allocated port number
        - name: hostport
          apiCall:
            urlPath: "/apis/hostport.rmb938.com/v1alpha1/hostports/{{ hostportclaim }}"
            jmesPath: "status.port"
      mutate:
        patchesJson6902: |-
          - op: add
            path: "/spec/containers/-"
            value:
              name: netbird
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
                  - name: NB_EXTERNAL_IP
                    valueFrom:
                      fieldRef:
                        fieldPath: status.hostIP
                  - name: NB_LISTEN_PORT
                    value: "{{ hostport }}"
                ports:
                  - name: router
                    containerPort: 51820
                    hostPort: "{{ hostport }}"
                    protocol: UDP
                securityContext:
                  runAsUser: 0
                  runAsGroup: 0
                  runAsNonRoot: false
                  capabilities:
                    add:
                      - NET_ADMIN
                  sysctls:
                    - name: net.ipv4.ip_forward
                      value: "1"
---
apiVersion: kyverno.io/v1
  kind: ClusterPolicy
  metadata:
    name: nbrouter-mutate
  spec:
    rules:
      - name: nbrouter-mutate
        match:
          any:
            - resources:
                kinds: ["Pod"]
                namespaces: ["${netbird_operator_namespace}"]
                selector:
                  matchLabels:
                    app.kubernetes.io/name: netbird-router
        context:
          # 1. Lookup the HostPortClaim to get the HostPort resource name
          - name: hostportclaim
            apiCall:
              urlPath: "/apis/hostport.rmb938.com/v1alpha1/namespaces/{{ request.namespace }}/hostportclaims/netbird-{{ request.object.metadata.ownerReferences[0].name | split(@, '-') | [0:-1] | join('-', @) }}"
              jmesPath: "spec.hostPortName"
          # 2. Lookup the actual HostPort to get the allocated port number
          - name: hostport
            apiCall:
              urlPath: "/apis/hostport.rmb938.com/v1alpha1/hostports/{{ hostportclaim }}"
              jmesPath: "status.port"
        mutate:
          patchesJson6902: |-
            - op: add
              path: "/spec/containers/0/ports"
              value: 
              - name: router
                containerPort: 51820
                hostPort: {{ hostport }}
                protocol: UDP
            - op: add
              path: "/spec/containers/0/env/-"
              value: {"name": "NB_EXTERNAL_IP", "valueFrom": {"fieldRef": {"fieldPath": "status.hostIP"}}}
            - op: add
              path: "/spec/containers/0/env/-"
              value: {"name": "NB_LISTEN_PORT", "value": "{{ hostport }}"}
            - op: add
              path: "/spec/securityContext"
              value: {"sysctls": [{"name": "net.ipv4.ip_forward", "value": "1"}]}
        preconditions:
          all:
            - key: "{{ request.operation }}"
              operator: In
              value: ["CREATE", "UPDATE"]
        skipBackgroundRequests: true
    validationFailureAction: Audit