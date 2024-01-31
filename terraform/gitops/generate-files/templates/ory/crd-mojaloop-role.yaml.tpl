kind: CustomResourceDefinition
apiVersion: apiextensions.k8s.io/v1beta1
metadata:
  name: mojalooproles.mojaloop.io
spec:
  group: mojaloop.io
  scope: Namespaced
  names:
    plural: mojalooproles
    singular: mojalooprole
    shortNames:
      - mlr
    kind: MojaloopRole
    listKind: MojaloopRoleList
  validation:
    openAPIV3Schema:
      description: MojaloopRole is the Schema for MojaloopRole API
      type: object
      properties:
        apiVersion:
          description: >-
            APIVersion defines the versioned schema of this representation
            of an object. Servers should convert recognized schemas to the
            latest internal value, and may reject unrecognized values. More
            info:
            https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#resources
          type: string
        kind:
          description: >-
            Kind is a string value representing the REST resource this
            object represents. Servers may infer this from the endpoint the
            client submits requests to. Cannot be updated. In CamelCase.
            More info:
            https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#types-kinds
          type: string
        metadata:
          type: object
        spec:
          description: MojaloopRole.spec describes the desired state of my resource
          type: object
          required:
            - role
          properties:
            role:
              description: >-
                The role of our MojaloopRole.
              type: string
            permissions:
              description: The list of permissions for the role.
              type: array
              items:
                description: permission ID.
                type: string
        status:
          description: The status of this MojaloopRole resource, set by the operator.
          type: object
          properties:
            state:
              description: The state of keto tuples.
              type: string
  versions:
    - name: v1
      served: true
      storage: true
      additionalPrinterColumns:
  conversion:
    strategy: None