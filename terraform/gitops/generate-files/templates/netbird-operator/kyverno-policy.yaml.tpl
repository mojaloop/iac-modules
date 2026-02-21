apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: nbrouter-add-security-context
spec:
  rules:
    - name: nbrouter-add-security-context
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
          # Static injection of the port into the ENV (more reliable than fieldRef for annotations)
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
                  kyverno.platform.mojaloop.com/triggerrestart: "{{request.object.metadata.resourceVersion}}"
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
