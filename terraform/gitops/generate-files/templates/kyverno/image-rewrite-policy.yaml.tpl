apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: redirect-xpkgupboundio-to-ghcr
spec:
  rules:
    - name: redirect-xpkgupboundio-to-ghcr
      match:
        any:
          - resources:
              kinds:
                - Pod
              operations:
                - CREATE
                - UPDATE
      exclude:
        any:
        - resources:
            namespaces:
            - istio-ingress-ext
            - istio-ingress-int
            - "kubescape"
      mutate:
        foreach:
          - list: request.object.spec.containers[]
            preconditions:
              all:
                - key: "{{ element.image || '' }}" # GUARD: Prevents nil pointer crash
                  operator: NotEquals
                  value: ""
                - key: "{{ image_normalize(element.image) }}"
                  operator: AnyIn
                  value:
                    - xpkg.upbound.io/*
                - key: "{{ element.image }}"
                  operator: NotEquals
                  value: "auto:latest"
            patchStrategicMerge:
              metadata:
                annotations:
                  kyverno/redirect-xpkgupboundio-to-ghcr: applied
              spec:
                containers:
                  - name: "{{ element.name }}"
                    env:
                      - name: ORIGINAL_IMAGE
                        value: "{{ element.image }}"
                    image: 'ghcr.io/mojaloop/infra/{{ images.containers."{{element.name}}".path}}:{{images.containers."{{element.name}}".tag}}'
---
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: redirect-bitnami-to-bitnamilegacy
spec:
  rules:
    - name: redirect-bitnami-to-bitnamilegacy
      match:
        any:
          - resources:
              kinds:
                - Pod
              operations:
                - CREATE
                - UPDATE
      exclude:
        any:
        - resources:
            namespaces:
            - istio-ingress-ext
            - istio-ingress-int
            - rook-ceph
            - storage
      mutate:
        foreach:
          - list: request.object.spec.containers[]
            preconditions:
              all:
                - key: "{{ element.image || '' }}" # GUARD: Prevents nil pointer crash
                  operator: NotEquals
                  value: ""
                - key: "{{ image_normalize(element.image) }}"
                  operator: AnyIn
                  value:
                    - docker.io/bitnami/*
            patchStrategicMerge:
              metadata:
                annotations:
                  kyverno/redirect-bitnami-to-bitnamilegacy: applied
              spec:
                containers:
                  - name: "{{ element.name }}"
                    env:
                      - name: ORIGINAL_IMAGE
                        value: "{{ element.image }}"
                      - name: BITNAMI_REWRITE
                        value: "true"
                    image: 'docker.io/bitnamilegacy/{{ images.containers."{{element.name}}".name}}:{{images.containers."{{element.name}}".tag}}'
          - list: request.object.spec.initContainers[]
            preconditions:
              all:
                - key: "{{ element.image || '' }}"
                  operator: NotEquals
                  value: ""
                - key: "{{ image_normalize(element.image) }}"
                  operator: AnyIn
                  value:
                    - docker.io/bitnami/*
            patchStrategicMerge:
              metadata:
                annotations:
                  kyverno/redirect-bitnami-to-bitnamilegacy: applied
              spec:
                initContainers:
                  - name: "{{ element.name }}"
                    env:
                      - name: ORIGINAL_IMAGE
                        value: "{{ element.image }}"
                      - name: BITNAMI_REWRITE
                        value: "true"
                    image: 'docker.io/bitnamilegacy/{{ images.initContainers."{{element.name}}".name}}:{{images.initContainers."{{element.name}}".tag}}'