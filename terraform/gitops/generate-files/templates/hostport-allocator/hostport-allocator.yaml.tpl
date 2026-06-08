# Vendored from https://github.com/rmb938/hostport-allocator
# Original release manifest: https://github.com/rmb938/hostport-allocator/releases/download/v0.1.17/hostport-allocator.yaml
# SPDX-License-Identifier: MIT
# Copyright (c) 2020 Ryan Belgrave
#
# Local modification: container image registry changed from the upstream GHCR
# package to ghcr.io/mojaloop/iac-crossplane-packages/hostport-allocator:v0.1.17.
#
# MIT License
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
---
apiVersion: v1
kind: Namespace
metadata:
  name: hostport-allocator
---
# Source: hostport-allocator/templates/serviceaccount.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: hostport-allocator
  namespace: "hostport-allocator"
  labels:
    helm.sh/chart: hostport-allocator-v0.1.17
    app.kubernetes.io/name: hostport-allocator
    app.kubernetes.io/instance: release-name
    app.kubernetes.io/version: "v0.1.17"
    app.kubernetes.io/managed-by: Helm
---
# Source: hostport-allocator/templates/crds/hostport.rmb938.com_hostportclaims.yaml
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  annotations:
    controller-gen.kubebuilder.io/version: v0.8.0
  name: hostportclaims.hostport.rmb938.com
spec:
  group: hostport.rmb938.com
  names:
    kind: HostPortClaim
    listKind: HostPortClaimList
    plural: hostportclaims
    shortNames:
    - hpc
    singular: hostportclaim
  scope: Namespaced
  versions:
  - additionalPrinterColumns:
    - jsonPath: .status.phase
      name: STATUS
      type: string
    - jsonPath: .spec.hostPortClassName
      name: HOSTPORTCLASS
      type: string
    - jsonPath: .spec.hostPortName
      name: HOSTPORT
      type: string
    - jsonPath: .metadata.creationTimestamp
      name: AGE
      type: date
    name: v1alpha1
    schema:
      openAPIV3Schema:
        description: HostPortClaim is the Schema for the hostportclaims API
        properties:
          apiVersion:
            description: 'APIVersion defines the versioned schema of this representation
              of an object. Servers should convert recognized schemas to the latest
              internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#resources'
            type: string
          kind:
            description: 'Kind is a string value representing the REST resource this
              object represents. Servers may infer this from the endpoint the client
              submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#types-kinds'
            type: string
          metadata:
            type: object
          spec:
            description: HostPortClaimSpec defines the desired state of HostPortClaim
            properties:
              hostPortClassName:
                description: The host port class
                type: string
              hostPortName:
                description: The binding reference to the HostPort backing this claim
                type: string
            required:
            - hostPortClassName
            type: object
          status:
            description: HostPortClaimStatus defines the observed state of HostPortClaim
            properties:
              conditions:
                description: Resource status conditions
                items:
                  properties:
                    lastTransitionTime:
                      description: lastTransitionTime is the last time the condition
                        transitioned from one status to another. This should be when
                        the underlying condition changed.  If that is not known, then
                        using the time when the API field changed is acceptable.
                      format: date-time
                      type: string
                    message:
                      description: message is a human readable message indicating
                        details about the transition. This may be an empty string.
                      maxLength: 32768
                      type: string
                    observedGeneration:
                      description: observedGeneration represents the .metadata.generation
                        that the condition was set based upon. For instance, if .metadata.generation
                        is currently 12, but the .status.conditions[x].observedGeneration
                        is 9, the condition is out of date with respect to the current
                        state of the instance.
                      format: int64
                      minimum: 0
                      type: integer
                    reason:
                      description: reason contains a programmatic identifier indicating
                        the reason for the condition's last transition. Producers
                        of specific condition types may define expected values and
                        meanings for this field, and whether the values are considered
                        a guaranteed API. The value should be a CamelCase string.
                        This field may not be empty.
                      maxLength: 1024
                      minLength: 1
                      pattern: ^[A-Za-z]([A-Za-z0-9_,:]*[A-Za-z0-9_])?$
                      type: string
                    status:
                      description: status of the condition, one of True, False, Unknown.
                      enum:
                      - "True"
                      - "False"
                      - Unknown
                      type: string
                    type:
                      description: type of condition in CamelCase or in foo.example.com/CamelCase.
                        --- Many .condition.type values are consistent across resources
                        like Available, but because arbitrary conditions can be useful
                        (see .node.status.conditions), the ability to deconflict is
                        important. The regex it matches is (dns1123SubdomainFmt/)?(qualifiedNameFmt)
                      maxLength: 316
                      pattern: ^([a-z0-9]([-a-z0-9]*[a-z0-9])?(\.[a-z0-9]([-a-z0-9]*[a-z0-9])?)*/)?(([A-Za-z0-9][-A-Za-z0-9_.]*)?[A-Za-z0-9])$
                      type: string
                  required:
                  - lastTransitionTime
                  - message
                  - reason
                  - status
                  - type
                  type: object
                type: array
              phase:
                type: string
            type: object
        type: object
    served: true
    storage: true
    subresources:
      status: {}
status:
  acceptedNames:
    kind: ""
    plural: ""
  conditions: []
  storedVersions: []
---
# Source: hostport-allocator/templates/crds/hostport.rmb938.com_hostportclasses.yaml
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  annotations:
    controller-gen.kubebuilder.io/version: v0.8.0
  name: hostportclasses.hostport.rmb938.com
spec:
  group: hostport.rmb938.com
  names:
    kind: HostPortClass
    listKind: HostPortClassList
    plural: hostportclasses
    shortNames:
    - hpcl
    singular: hostportclass
  scope: Cluster
  versions:
  - additionalPrinterColumns:
    - jsonPath: .metadata.creationTimestamp
      name: AGE
      type: date
    name: v1alpha1
    schema:
      openAPIV3Schema:
        description: HostPortClass is the Schema for the hostportclasses API
        properties:
          apiVersion:
            description: 'APIVersion defines the versioned schema of this representation
              of an object. Servers should convert recognized schemas to the latest
              internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#resources'
            type: string
          kind:
            description: 'Kind is a string value representing the REST resource this
              object represents. Servers may infer this from the endpoint the client
              submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#types-kinds'
            type: string
          metadata:
            type: object
          spec:
            description: HostPortClassSpec defines the desired state of HostPortClass
            properties:
              pools:
                items:
                  properties:
                    end:
                      description: The end port for the pool
                      maximum: 65535
                      minimum: 1
                      type: integer
                    start:
                      description: The start port for the pool
                      maximum: 65535
                      minimum: 1
                      type: integer
                  required:
                  - end
                  - start
                  type: object
                type: array
            required:
            - pools
            type: object
          status:
            description: HostPortClassStatus defines the observed state of HostPortClass
            type: object
        type: object
    served: true
    storage: true
    subresources:
      status: {}
status:
  acceptedNames:
    kind: ""
    plural: ""
  conditions: []
  storedVersions: []
---
# Source: hostport-allocator/templates/crds/hostport.rmb938.com_hostports.yaml
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  annotations:
    controller-gen.kubebuilder.io/version: v0.8.0
  name: hostports.hostport.rmb938.com
spec:
  group: hostport.rmb938.com
  names:
    kind: HostPort
    listKind: HostPortList
    plural: hostports
    shortNames:
    - hp
    singular: hostport
  scope: Cluster
  versions:
  - additionalPrinterColumns:
    - jsonPath: .spec.hostPortClassName
      name: CLASS
      type: string
    - jsonPath: .status.phase
      name: STATUS
      type: string
    - jsonPath: .status.port
      name: PORT
      type: integer
    - jsonPath: .metadata.creationTimestamp
      name: AGE
      type: date
    name: v1alpha1
    schema:
      openAPIV3Schema:
        description: HostPort is the Schema for the hostports API
        properties:
          apiVersion:
            description: 'APIVersion defines the versioned schema of this representation
              of an object. Servers should convert recognized schemas to the latest
              internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#resources'
            type: string
          kind:
            description: 'Kind is a string value representing the REST resource this
              object represents. Servers may infer this from the endpoint the client
              submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#types-kinds'
            type: string
          metadata:
            type: object
          spec:
            description: HostPortSpec defines the desired state of HostPort
            properties:
              claimRef:
                description: The referencing claim
                properties:
                  apiVersion:
                    description: API version of the referent.
                    type: string
                  fieldPath:
                    description: 'If referring to a piece of an object instead of
                      an entire object, this string should contain a valid JSON/Go
                      field access statement, such as desiredState.manifest.containers[2].
                      For example, if the object reference is to a container within
                      a pod, this would take on a value like: "spec.containers{name}"
                      (where "name" refers to the name of the container that triggered
                      the event) or if no container name is specified "spec.containers[2]"
                      (container with index 2 in this pod). This syntax is chosen
                      only to have some well-defined way of referencing a part of
                      an object. TODO: this design is not final and this field is
                      subject to change in the future.'
                    type: string
                  kind:
                    description: 'Kind of the referent. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#types-kinds'
                    type: string
                  name:
                    description: 'Name of the referent. More info: https://kubernetes.io/docs/concepts/overview/working-with-objects/names/#names'
                    type: string
                  namespace:
                    description: 'Namespace of the referent. More info: https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/'
                    type: string
                  resourceVersion:
                    description: 'Specific resourceVersion to which this reference
                      is made, if any. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#concurrency-control-and-consistency'
                    type: string
                  uid:
                    description: 'UID of the referent. More info: https://kubernetes.io/docs/concepts/overview/working-with-objects/names/#uids'
                    type: string
                type: object
              hostPortClassName:
                type: string
            required:
            - hostPortClassName
            type: object
          status:
            description: HostPortStatus defines the observed state of HostPort
            properties:
              conditions:
                description: Resource status conditions
                items:
                  properties:
                    lastTransitionTime:
                      description: lastTransitionTime is the last time the condition
                        transitioned from one status to another. This should be when
                        the underlying condition changed.  If that is not known, then
                        using the time when the API field changed is acceptable.
                      format: date-time
                      type: string
                    message:
                      description: message is a human readable message indicating
                        details about the transition. This may be an empty string.
                      maxLength: 32768
                      type: string
                    observedGeneration:
                      description: observedGeneration represents the .metadata.generation
                        that the condition was set based upon. For instance, if .metadata.generation
                        is currently 12, but the .status.conditions[x].observedGeneration
                        is 9, the condition is out of date with respect to the current
                        state of the instance.
                      format: int64
                      minimum: 0
                      type: integer
                    reason:
                      description: reason contains a programmatic identifier indicating
                        the reason for the condition's last transition. Producers
                        of specific condition types may define expected values and
                        meanings for this field, and whether the values are considered
                        a guaranteed API. The value should be a CamelCase string.
                        This field may not be empty.
                      maxLength: 1024
                      minLength: 1
                      pattern: ^[A-Za-z]([A-Za-z0-9_,:]*[A-Za-z0-9_])?$
                      type: string
                    status:
                      description: status of the condition, one of True, False, Unknown.
                      enum:
                      - "True"
                      - "False"
                      - Unknown
                      type: string
                    type:
                      description: type of condition in CamelCase or in foo.example.com/CamelCase.
                        --- Many .condition.type values are consistent across resources
                        like Available, but because arbitrary conditions can be useful
                        (see .node.status.conditions), the ability to deconflict is
                        important. The regex it matches is (dns1123SubdomainFmt/)?(qualifiedNameFmt)
                      maxLength: 316
                      pattern: ^([a-z0-9]([-a-z0-9]*[a-z0-9])?(\.[a-z0-9]([-a-z0-9]*[a-z0-9])?)*/)?(([A-Za-z0-9][-A-Za-z0-9_.]*)?[A-Za-z0-9])$
                      type: string
                  required:
                  - lastTransitionTime
                  - message
                  - reason
                  - status
                  - type
                  type: object
                type: array
              phase:
                type: string
              port:
                description: The port that was allocated by the HostPortClass
                maximum: 65535
                minimum: 0
                type: integer
            type: object
        type: object
    served: true
    storage: true
    subresources:
      status: {}
status:
  acceptedNames:
    kind: ""
    plural: ""
  conditions: []
  storedVersions: []
---
# Source: hostport-allocator/templates/clusterrole.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: hostport-allocator
  labels:
    helm.sh/chart: hostport-allocator-v0.1.17
    app.kubernetes.io/name: hostport-allocator
    app.kubernetes.io/instance: release-name
    app.kubernetes.io/version: "v0.1.17"
    app.kubernetes.io/managed-by: Helm
rules:
  - apiGroups:
      - ""
    resources:
      - pods
    verbs:
      - get
      - list
      - watch
  - apiGroups:
      - hostport.rmb938.com
    resources:
      - hostportclaims
    verbs:
      - create
      - delete
      - get
      - list
      - patch
      - update
      - watch
  - apiGroups:
      - hostport.rmb938.com
    resources:
      - hostportclaims/status
    verbs:
      - get
      - patch
      - update
  - apiGroups:
      - hostport.rmb938.com
    resources:
      - hostportclasses
    verbs:
      - create
      - delete
      - get
      - list
      - patch
      - update
      - watch
  - apiGroups:
      - hostport.rmb938.com
    resources:
      - hostportclasses/status
    verbs:
      - get
      - patch
      - update
  - apiGroups:
      - hostport.rmb938.com
    resources:
      - hostports
    verbs:
      - create
      - delete
      - get
      - list
      - patch
      - update
      - watch
  - apiGroups:
      - hostport.rmb938.com
    resources:
      - hostports/status
    verbs:
      - get
      - patch
      - update
---
# Source: hostport-allocator/templates/clusterrolebinding.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: hostport-allocator
  labels:
    helm.sh/chart: hostport-allocator-v0.1.17
    app.kubernetes.io/name: hostport-allocator
    app.kubernetes.io/instance: release-name
    app.kubernetes.io/version: "v0.1.17"
    app.kubernetes.io/managed-by: Helm
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: hostport-allocator
subjects:
  - kind: ServiceAccount
    name: hostport-allocator
    namespace: hostport-allocator
---
# Source: hostport-allocator/templates/leaderelectionrole.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: hostport-allocator
  namespace: "hostport-allocator"
  labels:
    helm.sh/chart: hostport-allocator-v0.1.17
    app.kubernetes.io/name: hostport-allocator
    app.kubernetes.io/instance: release-name
    app.kubernetes.io/version: "v0.1.17"
    app.kubernetes.io/managed-by: Helm
rules:
  - apiGroups:
      - "coordination.k8s.io"
    resources:
      - leases
    verbs:
      - get
      - list
      - watch
      - create
      - update
      - patch
      - delete
  - apiGroups:
      - "coordination.k8s.io"
    resources:
      - leases/status
    verbs:
      - get
      - update
      - patch
  - apiGroups:
      - ""
    resources:
      - events
    verbs:
      - create
---
# Source: hostport-allocator/templates/leaderelectionrolebinding.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: hostport-allocator
  namespace: "hostport-allocator"
  labels:
    helm.sh/chart: hostport-allocator-v0.1.17
    app.kubernetes.io/name: hostport-allocator
    app.kubernetes.io/instance: release-name
    app.kubernetes.io/version: "v0.1.17"
    app.kubernetes.io/managed-by: Helm
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: hostport-allocator
subjects:
  - kind: ServiceAccount
    name: hostport-allocator
    namespace: hostport-allocator
---
# Source: hostport-allocator/templates/service.yaml
apiVersion: v1
kind: Service
metadata:
  name: hostport-allocator
  namespace: "hostport-allocator"
  labels:
    helm.sh/chart: hostport-allocator-v0.1.17
    app.kubernetes.io/name: hostport-allocator
    app.kubernetes.io/instance: release-name
    app.kubernetes.io/version: "v0.1.17"
    app.kubernetes.io/managed-by: Helm
spec:
  type: ClusterIP
  ports:
    - port: 8080
      targetPort: metrics
      protocol: TCP
      name: metrics
    - port: 443
      targetPort: webhook
      protocol: TCP
      name: webhook
  selector:
    app.kubernetes.io/name: hostport-allocator
    app.kubernetes.io/instance: release-name
---
# Source: hostport-allocator/templates/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: hostport-allocator
  namespace: "hostport-allocator"
  labels:
    helm.sh/chart: hostport-allocator-v0.1.17
    app.kubernetes.io/name: hostport-allocator
    app.kubernetes.io/instance: release-name
    app.kubernetes.io/version: "v0.1.17"
    app.kubernetes.io/managed-by: Helm
spec:
  replicas: 1
  selector:
    matchLabels:
      app.kubernetes.io/name: hostport-allocator
      app.kubernetes.io/instance: release-name
  template:
    metadata:
      annotations:
        prometheus.io/path: '/metrics'
        prometheus.io/scrape: 'true'
        prometheus.io/port: '8080'
      labels:
        helm.sh/chart: hostport-allocator-v0.1.17
        app.kubernetes.io/name: hostport-allocator
        app.kubernetes.io/instance: release-name
        app.kubernetes.io/version: "v0.1.17"
        app.kubernetes.io/managed-by: Helm
    spec:
      serviceAccountName: hostport-allocator
      securityContext:
        {}
      containers:
        - name: hostport-allocator
          securityContext:
            {}
          image: "ghcr.io/mojaloop/iac-crossplane-packages/hostport-allocator:v0.1.17"
          imagePullPolicy: IfNotPresent
          args:
            - --enable-leader-election
          ports:
            - name: health
              containerPort: 8081
              protocol: TCP
            - name: metrics
              containerPort: 8080
              protocol: TCP
            - name: webhook
              containerPort: 9443
              protocol: TCP
          volumeMounts:
            - mountPath: /tmp/k8s-webhook-server/serving-certs
              name: cert
              readOnly: true
          livenessProbe:
            httpGet:
              path: /healthz
              port: health
          readinessProbe:
            httpGet:
              path: /readyz
              port: health
          resources:
            {}
      volumes:
        - name: cert
          secret:
            defaultMode: 420
            secretName: hostport-allocator
---
# Source: hostport-allocator/templates/certificate.yaml
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: hostport-allocator
  namespace: "hostport-allocator"
  labels:
    helm.sh/chart: hostport-allocator-v0.1.17
    app.kubernetes.io/name: hostport-allocator
    app.kubernetes.io/instance: release-name
    app.kubernetes.io/version: "v0.1.17"
    app.kubernetes.io/managed-by: Helm
spec:
  dnsNames:
    - hostport-allocator.hostport-allocator.svc
    - hostport-allocator.hostport-allocator.svc.cluster.local
  issuerRef:
    kind: Issuer
    name: hostport-allocator
  secretName: hostport-allocator
---
# Source: hostport-allocator/templates/issuer.yaml
apiVersion: cert-manager.io/v1
kind: Issuer
metadata:
  name: hostport-allocator
  namespace: "hostport-allocator"
  labels:
    helm.sh/chart: hostport-allocator-v0.1.17
    app.kubernetes.io/name: hostport-allocator
    app.kubernetes.io/instance: release-name
    app.kubernetes.io/version: "v0.1.17"
    app.kubernetes.io/managed-by: Helm
spec:
  selfSigned: {}
---
# Source: hostport-allocator/templates/crd-webhook.yaml
apiVersion: admissionregistration.k8s.io/v1
kind: MutatingWebhookConfiguration
metadata:
  name: hostport-allocator-crd
  labels:
    helm.sh/chart: hostport-allocator-v0.1.17
    app.kubernetes.io/name: hostport-allocator
    app.kubernetes.io/instance: release-name
    app.kubernetes.io/version: "v0.1.17"
    app.kubernetes.io/managed-by: Helm
  annotations:
    cert-manager.io/inject-ca-from: hostport-allocator/hostport-allocator
webhooks:
  - admissionReviewVersions:
        - v1
    clientConfig:
      caBundle: Cg==
      service:
        name: hostport-allocator
        namespace: hostport-allocator
        path: /mutate-hostport-rmb938-com-v1alpha1-hostport
    failurePolicy: Fail
    name: mhostport.kb.io
    rules:
      - apiGroups:
          - hostport.rmb938.com
        apiVersions:
          - v1alpha1
        operations:
          - CREATE
          - UPDATE
        resources:
          - hostports
    sideEffects: None
  - admissionReviewVersions:
      - v1
    clientConfig:
      caBundle: Cg==
      service:
        name: hostport-allocator
        namespace: hostport-allocator
        path: /mutate-hostport-rmb938-com-v1alpha1-hostportclaim
    failurePolicy: Fail
    name: mhostportclaim.kb.io
    rules:
      - apiGroups:
          - hostport.rmb938.com
        apiVersions:
          - v1alpha1
        operations:
          - CREATE
          - UPDATE
        resources:
          - hostportclaims
    sideEffects: None
  - admissionReviewVersions:
      - v1
    clientConfig:
      caBundle: Cg==
      service:
        name: hostport-allocator
        namespace: hostport-allocator
        path: /mutate-hostport-rmb938-com-v1alpha1-hostportclass
    failurePolicy: Fail
    name: mhostportclass.kb.io
    rules:
      - apiGroups:
          - hostport.rmb938.com
        apiVersions:
          - v1alpha1
        operations:
          - CREATE
          - UPDATE
        resources:
          - hostportclasses
    sideEffects: None
---
# Source: hostport-allocator/templates/pod-webhook.yaml
apiVersion: admissionregistration.k8s.io/v1
kind: MutatingWebhookConfiguration
metadata:
  name: hostport-allocator-pod
  labels:
    helm.sh/chart: hostport-allocator-v0.1.17
    app.kubernetes.io/name: hostport-allocator
    app.kubernetes.io/instance: release-name
    app.kubernetes.io/version: "v0.1.17"
    app.kubernetes.io/managed-by: Helm
  annotations:
    cert-manager.io/inject-ca-from: hostport-allocator/hostport-allocator
webhooks:
  - admissionReviewVersions:
      - v1
    clientConfig:
      caBundle: Cg==
      service:
        name: hostport-allocator
        namespace: hostport-allocator
        path: /mutate-v1-pod
    failurePolicy: Fail
    name: mpod.kb.io
    namespaceSelector:
      matchLabels:
        hostport.rmb938.com: "true"
    rules:
      - apiGroups:
          - ""
        apiVersions:
          - v1
        operations:
          - CREATE
          - UPDATE
        resources:
          - pods
    sideEffects: None
---
# Source: hostport-allocator/templates/crd-webhook.yaml
apiVersion: admissionregistration.k8s.io/v1
kind: ValidatingWebhookConfiguration
metadata:
  name: hostport-allocator-crd
  labels:
    helm.sh/chart: hostport-allocator-v0.1.17
    app.kubernetes.io/name: hostport-allocator
    app.kubernetes.io/instance: release-name
    app.kubernetes.io/version: "v0.1.17"
    app.kubernetes.io/managed-by: Helm
  annotations:
    cert-manager.io/inject-ca-from: hostport-allocator/hostport-allocator
webhooks:
  - admissionReviewVersions:
      - v1
    clientConfig:
      caBundle: Cg==
      service:
        name: hostport-allocator
        namespace: hostport-allocator
        path: /validate-hostport-rmb938-com-v1alpha1-hostport
    failurePolicy: Fail
    name: vhostport.kb.io
    rules:
      - apiGroups:
          - hostport.rmb938.com
        apiVersions:
          - v1alpha1
        operations:
          - CREATE
          - UPDATE
        resources:
          - hostports
    sideEffects: None
  - admissionReviewVersions:
      - v1
    clientConfig:
      caBundle: Cg==
      service:
        name: hostport-allocator
        namespace: hostport-allocator
        path: /validate-hostport-rmb938-com-v1alpha1-hostportclaim
    failurePolicy: Fail
    name: vhostportclaim.kb.io
    rules:
      - apiGroups:
          - hostport.rmb938.com
        apiVersions:
          - v1alpha1
        operations:
          - CREATE
          - UPDATE
        resources:
          - hostportclaims
    sideEffects: None
  - admissionReviewVersions:
      - v1
    clientConfig:
      caBundle: Cg==
      service:
        name: hostport-allocator
        namespace: hostport-allocator
        path: /validate-hostport-rmb938-com-v1alpha1-hostportclass
    failurePolicy: Fail
    name: vhostportclass.kb.io
    rules:
      - apiGroups:
          - hostport.rmb938.com
        apiVersions:
          - v1alpha1
        operations:
          - CREATE
          - UPDATE
        resources:
          - hostportclasses
    sideEffects: None
