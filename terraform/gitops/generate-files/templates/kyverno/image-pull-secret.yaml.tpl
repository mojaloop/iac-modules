apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: copy-and-attach-image-pull-secret
spec:
  background: true
  rules:
    # Rule 1: Copy the image pull secret to all namespaces
    - name: copy-image-pull-secret
      match:
        resources:
          kinds:
            - Namespace
      generate:
        kind: Secret
        name: ${image_pull_secret_name}
        namespace: "{{request.object.metadata.name}}"
        synchronize: true
        clone:
          namespace: ${image_pull_secret_namespace}
          name: ${image_pull_secret_name}

    # Rule 2: Attach the image pull secret to every Pod
    - name: attach-image-pull-secret-to-pod
      match:
        resources:
          kinds:
            - Pod
      mutate:
        patchStrategicMerge:
          spec:
            imagePullSecrets:
              - name: ${image_pull_secret_name}