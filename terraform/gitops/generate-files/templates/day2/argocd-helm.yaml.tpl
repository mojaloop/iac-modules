apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: argocd
  namespace: argocd
  annotations:
    argocd.argoproj.io/sync-wave: ${day2_sync_wave}

  # Add this finalizer ONLY if you want these to cascade delete (A cascade delete, deletes both the app and its resources, rather than only the app.)
  # finalizers:
  #   - resources-finalizer.argocd.argoproj.io

spec:
  project: default
  ignoreDifferences:
    - group: ""
      name: "argocd-rbac-cm"
      kind: ConfigMap
      jsonPointers:
        - /data/policy.csv
    - group: ""
      name: "argocd-cm"
      kind: ConfigMap
      jsonPointers:
        - /data/oidc.config
  syncPolicy:
    syncOptions:
      - CreateNamespace=true
      - PrunePropagationPolicy=foreground
      - RespectIgnoreDifferences=true

    automated:
      prune: false
      selfHeal: false

  destination:
    server: "https://kubernetes.default.svc"
    namespace: argocd

  sources:
    - chart: argo-cd
      repoURL: https://argoproj.github.io/argo-helm
      targetRevision: ${argocd_helm_version}

      helm:
        releaseName: argocd
        valuesObject:
          fullnameOverride: argocd
          crds:
            install: true
          global:
            domain: argo.${argocd_dns_subdomain}
            logging:
              format: json

          applicationSet:
            metrics:
              enabled: true
          notifications:
            enabled: false
          configs:
            secret:
              createSecret: false
            cm:
              url: https://argocd.${argocd_dns_subdomain}
              exec.enabled: "true"
              kustomize.buildOptions: "--load-restrictor LoadRestrictionsNone --enable-helm"
              # DO NOT USE in production, this is only used to improve reconciliation in testing env.
              timeout.reconciliation: "10s"
              application.resourceTrackingMethod: annotation
              statusbadge.enabled: 'true'
              ui.bannercontent: "argocd application install"
              ui.bannerpermanent: "true"
              oidc.config: |
                name: Zitadel
                issuer: ${zitadel_server_url}
                clientID: $argo-oidc:clientid
                clientSecret: $argo-oidc:clientsecret
                requestedScopes: ["openid", "profile", "email", "read_api"]
              resource.exclusions: |
                - apiGroups:
                  - "*"
                  kinds:
                  - ProviderConfigUsage
              resource.customizations: |
                argoproj.io/Application:
                  health.lua: |
                    hs = {}
                    hs.status = "Progressing"
                    hs.message = ""
                    if obj.status ~= nil then
                      if obj.status.health ~= nil then
                        hs.status = obj.status.health.status
                        if obj.status.health.message ~= nil then
                          hs.message = obj.status.health.message
                        end
                      end
                    end
                    return hs
                cert-manager.io/Certificate:
                  health.lua: |
                    hs = {}
                    if obj.status ~= nil then
                      if obj.status.conditions ~= nil then
                        for i, condition in ipairs(obj.status.conditions) do
                          if condition.type == "Ready" and condition.status == "False" then
                            hs.status = "Degraded"
                            hs.message = condition.message
                            return hs
                          end
                          if condition.type == "Ready" and condition.status == "True" then
                            hs.status = "Healthy"
                            hs.message = condition.message
                            return hs
                          end
                        end
                      end
                    end

                    hs.status = "Progressing"
                    hs.message = "Waiting for certificate"
                    return hs
                redhatcop.redhat.io/VaultSecret:
                  health.lua: |
                    hs = {}
                    if obj.status ~= nil then
                      if obj.status.conditions ~= nil then
                        for i, condition in ipairs(obj.status.conditions) do
                          if condition.type == "ReconcileSuccessful" and condition.status == "False" then
                            hs.status = "Degraded"
                            hs.message = condition.message
                            return hs
                          end
                          if condition.type == "ReconcileSuccessful" and condition.status == "True" then
                            hs.status = "Healthy"
                            hs.message = condition.message
                            return hs
                          end
                        end
                      end
                    end

                    hs.status = "Progressing"
                    hs.message = "Waiting for VaultSecret"
                    return hs

                batch/Job:
                  health.lua.useOpenLibs: true
                  health.lua: |
                    hs = {}
                    if obj.status ~= nil then
                      if obj.status.conditions ~= nil then
                        for i, condition in ipairs(obj.status.conditions) do
                          if condition.type == "Failed" and condition.status == "True" then
                            hs.status = "Degraded"
                            if string.sub(obj.metadata.name,1,16) == "moja-ml-ttk-test" then
                              hs.status = "Healthy"
                            end
                            hs.message = condition.message
                            return hs
                          end
                          if condition.type == "Complete" and condition.status == "True" then
                            hs.status = "Healthy"
                            hs.message = condition.message
                            return hs
                          end
                          if condition.type == "Suspended" then
                            hs.status = "Suspended"
                            hs.message = condition.message
                            return hs
                          end
                        end
                      end
                    end

                    hs.status = "Progressing"
                    hs.message = "Waiting for Job"
                    return hs

                k8s.keycloak.org/Keycloak:
                  health.lua: |
                    if obj.status == nil or obj.status.conditions == nil then
                      -- no status info available yet
                      return {
                        status = "Progressing",
                        message = "Waiting for Keycloak status conditions to exist",
                      }
                    end

                    -- Sort conditions by lastTransitionTime, from old to new.
                    table.sort(obj.status.conditions, function(a, b)
                      return a.lastTransitionTime < b.lastTransitionTime
                    end)

                    for _, condition in ipairs(obj.status.conditions) do
                      if condition.type == "Ready" and condition.status == "True" then
                        return {
                          status = "Healthy",
                          message = "",
                        }
                      elseif condition.type == "HasErrors" and condition.status == "True" then
                        return {
                          status = "Degraded",
                          message = "Has Errors: " .. condition.message,
                        }
                      end
                    end

                    -- We couldn't find matching conditions yet, so assume progressing
                    return {
                      status = "Progressing",
                      message = "",
                    }

                pxc.percona.com/PerconaXtraDBCluster:
                  health.lua: |
                    local hs = {}
                    if obj.status ~= nil then

                      if obj.status.state == "initializing" then
                        hs.status = "Progressing"
                        hs.message = obj.status.ready .. "/" .. obj.status.size .. " node(s) are ready"
                        return hs
                      end

                      if obj.status.state == "ready" then
                        hs.status = "Healthy"
                        hs.message = obj.status.ready .. "/" .. obj.status.size .. " node(s) are ready"
                        return hs
                      end

                      if obj.status.state == "paused" then
                        hs.status = "Unknown"
                        hs.message = "Cluster is paused"
                        return hs
                      end

                      if obj.status.state == "stopping" then
                        hs.status = "Degraded"
                        hs.message = "Cluster is stopping (" .. obj.status.ready .. "/" .. obj.status.size .. " node(s) are ready)"
                        return hs
                      end

                      if obj.status.state == "error" then
                        hs.status = "Degraded"
                        hs.message = "Cluster is on error: " .. table.concat(obj.status.message, ", ")
                        return hs
                      end

                    end

                    hs.status = "Unknown"
                    hs.message = "Cluster status is unknown. Ensure your ArgoCD is current and then check for/file a bug report: https://github.com/argoproj/argo-cd/issues"
                    return hs

                "*.upbound.io/*":
                  health.lua: |
                    health_status = {
                      status = "Progressing",
                      message = "Provisioning ..."
                    }

                    local function contains (table, val)
                      for i, v in ipairs(table) do
                        if v == val then
                          return true
                        end
                      end
                      return false
                    end

                    local has_no_status = {
                      "ProviderConfig",
                      "ProviderConfigUsage"
                    }

                    if obj.status == nil or next(obj.status) == nil and contains(has_no_status, obj.kind) then
                      health_status.status = "Healthy"
                      health_status.message = "Resource is up-to-date."
                      return health_status
                    end

                    if obj.status == nil or next(obj.status) == nil or obj.status.conditions == nil then
                      if obj.kind == "ProviderConfig" and obj.status.users ~= nil then
                        health_status.status = "Healthy"
                        health_status.message = "Resource is in use."
                        return health_status
                      end
                      return health_status
                    end

                    for i, condition in ipairs(obj.status.conditions) do
                      if condition.type == "LastAsyncOperation" then
                        if condition.status == "False" then
                          health_status.status = "Degraded"
                          health_status.message = condition.message
                          return health_status
                        end
                      end

                      if condition.type == "Synced" then
                        if condition.status == "False" then
                          health_status.status = "Degraded"
                          health_status.message = condition.message
                          return health_status
                        end
                      end

                      if condition.type == "Ready" then
                        if condition.status == "True" then
                          health_status.status = "Healthy"
                          health_status.message = "Resource is up-to-date."
                          return health_status
                        end
                      end
                    end

                    return health_status

                "*.crossplane.io/*":
                  health.lua: |
                    health_status = {
                      status = "Progressing",
                      message = "Provisioning ..."
                    }

                    local function contains (table, val)
                      for i, v in ipairs(table) do
                        if v == val then
                          return true
                        end
                      end
                      return false
                    end

                    local has_no_status = {
                      "Composition",
                      "CompositionRevision",
                      "DeploymentRuntimeConfig",
                      "ControllerConfig",
                      "ProviderConfig",
                      "ProviderConfigUsage"
                    }
                    if obj.status == nil or next(obj.status) == nil and contains(has_no_status, obj.kind) then
                        health_status.status = "Healthy"
                        health_status.message = "Resource is up-to-date."
                      return health_status
                    end

                    if obj.status == nil or next(obj.status) == nil or obj.status.conditions == nil then
                      if obj.kind == "ProviderConfig" and obj.status.users ~= nil then
                        health_status.status = "Healthy"
                        health_status.message = "Resource is in use."
                        return health_status
                      end
                      return health_status
                    end

                    for i, condition in ipairs(obj.status.conditions) do
                      if condition.type == "LastAsyncOperation" then
                        if condition.status == "False" then
                          health_status.status = "Degraded"
                          health_status.message = condition.message
                          return health_status
                        end
                      end

                      if condition.type == "Synced" then
                        if condition.status == "False" then
                          health_status.status = "Degraded"
                          health_status.message = condition.message
                          return health_status
                        end
                      end

                      if contains({"Ready", "Healthy", "Offered", "Established"}, condition.type) then
                        if condition.status == "True" then
                          health_status.status = "Healthy"
                          health_status.message = "Resource is up-to-date."
                          return health_status
                        end
                      end
                    end

                    return health_status

                "*mojaloop.io/*":
                  health.lua: |
                    health_status = {
                      status = "Progressing",
                      message = "Provisioning ..."
                    }

                    local function contains (table, val)
                      for i, v in ipairs(table) do
                        if v == val then
                          return true
                        end
                      end
                      return false
                    end

                    local has_no_status = {}

                    -- Custom Mojaloop ory resources status check
                    if obj.status ~= nil and obj.status.state == "VALIDATED" then
                      health_status.status = "Healthy"
                      health_status.message = "State is VALIDATED"
                      return health_status
                    end

                    if obj.status == nil
                      or next(obj.status) == nil
                      and contains(has_no_status, obj.kind)
                    then
                        health_status.status = "Healthy"
                        health_status.message = "Resource is up-to-date."
                      return health_status
                    end

                    if obj.status == nil or next(obj.status) == nil or obj.status.conditions == nil then
                      if obj.kind == "ProviderConfig" and obj.status.users ~= nil then
                        health_status.status = "Healthy"
                        health_status.message = "Resource is in use."
                        return health_status
                      end
                      return health_status
                    end

                    for i, condition in ipairs(obj.status.conditions) do
                      if condition.type == "LastAsyncOperation" then
                        if condition.status == "False" then
                          health_status.status = "Degraded"
                          health_status.message = condition.message
                          return health_status
                        end
                      end

                      if condition.type == "Synced" then
                        if condition.status == "False" then
                          health_status.status = "Degraded"
                          health_status.message = condition.message
                          return health_status
                        end
                      end

                      if contains({"Ready", "Healthy", "Offered", "Established"}, condition.type) then
                        if condition.status == "True" then
                          health_status.status = "Healthy"
                          health_status.message = "Resource is up-to-date."
                          return health_status
                        end
                      end
                    end

                    return health_status


            rbac:
              scopes: "[${zitadel_grant_prefix}]"
              policy.default: ""
              policy.csv: |
                g, ${zitadel_project_id}:${argocd_admin_rbac_group}, role:admin
                g, ${zitadel_project_id}:${argocd_readonly_rbac_group}, role:readonly
              policy.matchMode: glob
            params:
              server.insecure: true
              # Mandatory for extensions to work
              server.enable.proxy.extension: "true"
              reposerver.enable.git.submodule: "false"
              applicationsetcontroller.enable.git.submodule: "false"

              #Enable Server-Side Diff so argocd play nicely with Kyverno mutating webhooks:
              #https://argo-cd.readthedocs.io/en/stable/user-guide/diff-strategies/#mutation-webhooks
              controller.diff.server.side: "true"

              server.log.level: ${argocd_helm_server_log_level}
              reposerver.log.level: ${argocd_helm_reposerver_log_level}
              controller.log.level: ${argocd_helm_controller_log_level}
              applicationsetcontroller.log.level: ${argocd_helm_applicationsetcontroller_log_level}

            cmp:
              create: true
              plugins:
                envsubstappofapp:
                  init:
                    command: ["sh", "-c"]
                    args:
                      [
                        "kustomize build . --load-restrictor LoadRestrictionsNone -o raw-kustomization.yaml",
                      ]
                  generate:
                    command: ["sh", "-c"]
                    args:
                      [
                        "envsubst < raw-kustomization.yaml > processed-kustomization.yaml && cp processed-kustomization.yaml /dev/stdout",
                      ]
                  discover:
                    fileName: "kustomization.*"
                envsubst:
                  discover:
                    fileName: "kustomization.*"
                  generate:
                    command: ["sh", "-c"]
                    args:
                      [
                        "for f in *.yaml ; do cat $f | envsubst > $f.sub && mv $f.sub $f ; done && kustomize build . --enable-helm --helm-kube-version ${argocd_helm_kube_version} --load-restrictor LoadRestrictionsNone > /dev/stdout",
                      ]

          ## Controller ##
          controller:
            # resources:
            #   limits:
            #     cpu: 1
            #     memory: 1024Mi
            #   requests:
            #     cpu: 500m
            #     memory: 1024Mi
            metrics:
              enabled: true
              serviceMonitor:
                enabled: false
                namespace: argocd
                additionalLabels:
                  prometheus.io/scrap-with: kube-prometheus-stack

          ## DEX ##
          dex:
            enabled: false
            metrics:
              enabled: true
              serviceMonitor:
                enabled: false # enable for production
                namespace: argocd
                additionalLabels:
                  prometheus.io/scrap-with: kube-prometheus-stack

          ## RepoServer ##
          repoServer:
            # resources:
            #   limits:
            #     cpu: 500m
            #     memory: 1.5Gi
            #   requests:
            #     cpu: 250m
            #     memory: 512Mi
            env:
              - name: HELM_CACHE_HOME
                value: /helm-working-dir
              - name: HELM_CONFIG_HOME
                value: /helm-working-dir
              - name: HELM_DATA_HOME
                value: /helm-working-dir

            volumes:
              - name: custom-tools
                emptyDir: {}
              - name: cmp-plugin
                configMap:
                  name: argocd-cmp-cm

            initContainers:
              - name: helm-plugins
                image: alpine/helm:${helm_version}
                volumeMounts:
                  - name: helm-working-dir
                    mountPath: /helm-working-dir
                env:
                  - name: HELM_CACHE_HOME
                    value: /helm-working-dir
                  - name: HELM_CONFIG_HOME
                    value: /helm-working-dir
                  - name: HELM_DATA_HOME
                    value: /helm-working-dir
                command: ["/bin/sh", "-c"]
                args:
                  - helm plugin install https://github.com/aslafy-z/helm-git --version ${helm_git_plugin_version} && rm -rf /helm-working-dir/plugins/https* && chmod -R 777 $HELM_DATA_HOME

              - name: download-tools
                image: golang:${helm_download_tools_golang_image_version}
                command: [sh, -c]
                args:
                  - apk add git && go install github.com/drone/envsubst/cmd/envsubst@v${helm_envsubst_version} && mv $GOPATH/bin/envsubst /custom-tools/ && chmod +x /custom-tools/envsubst
                volumeMounts:
                  - mountPath: /custom-tools
                    name: custom-tools

            extraContainers:
              - name: debug-tools
                image: quay.io/argoproj/argocd
                command: [sh, -c]
                args:
                  - while true; do echo "running"; sleep 300; done
                volumeMounts:
                  - mountPath: /var/run/argocd
                    name: var-files
                  - mountPath: /home/argocd/cmp-server/plugins
                    name: plugins
                  - mountPath: /tmp
                    name: tmp

                  # Important: Mount tools into $PATH
                  - name: custom-tools
                    subPath: envsubst
                    mountPath: /usr/local/bin/envsubst

                  - name: helm-working-dir
                    mountPath: /helm-working-dir

              - name: envsubstappofapp
                command: [/var/run/argocd/argocd-cmp-server]
                image: quay.io/argoproj/argocd
                args: [--loglevel, debug]
                securityContext:
                  runAsNonRoot: true
                  runAsUser: 999
                volumeMounts:
                  - mountPath: /var/run/argocd
                    name: var-files
                  - mountPath: /home/argocd/cmp-server/plugins
                    name: plugins
                  - mountPath: /tmp
                    name: tmp

                  # Register plugins into sidecar
                  - mountPath: /home/argocd/cmp-server/config/plugin.yaml
                    subPath: envsubstappofapp.yaml
                    name: cmp-plugin

                  # Important: Mount tools into $PATH
                  - name: custom-tools
                    subPath: envsubst
                    mountPath: /usr/local/bin/envsubst

              - name: envsubst
                command: [/var/run/argocd/argocd-cmp-server]
                image: quay.io/argoproj/argocd
                args: [--loglevel, debug]
                securityContext:
                  runAsNonRoot: true
                  runAsUser: 999
                volumeMounts:
                  - mountPath: /var/run/argocd
                    name: var-files
                  - mountPath: /home/argocd/cmp-server/plugins
                    name: plugins
                  - mountPath: /tmp
                    name: tmp

                  # Register plugins into sidecar
                  - mountPath: /home/argocd/cmp-server/config/plugin.yaml
                    subPath: envsubst.yaml
                    name: cmp-plugin

                  # Important: Mount tools into $PATH
                  - name: custom-tools
                    subPath: envsubst
                    mountPath: /usr/local/bin/envsubst

            metrics:
              enabled: true
              serviceMonitor:
                enabled: false
                namespace: argocd
                additionalLabels:
                  prometheus.io/scrap-with: kube-prometheus-stack

          ## Server ##
          server:
            # podAnnotations:
            #   secret.reloader.stakater.com/reload: notused?
            # resources:
            #   limits:
            #     cpu: 400m
            #     memory: 512Mi
            #   requests:
            #     cpu: 400m
            #     memory: 512Mi
            metrics:
              enabled: true
              serviceMonitor:
                enabled: false
                additionalLabels:
                  prometheus.io/scrap-with: kube-prometheus-stack
                namespace: argocd
            ingress:
              enabled: false

            extensions:
              enabled: true
              extensionList:
                # - name: metrics
                #   env:
                #     - name: EXTENSION_URL
                #       value: https://github.com/argoproj-labs/argocd-extension-metrics/releases/download/v1.0.3/extension.tar.gz
                #     - name: EXTENSION_CHECKSUM_URL
                #       value: https://github.com/argoproj-labs/argocd-extension-metrics/releases/download/v1.0.3/extension_checksums.txt
                - name: rollout
                  env:
                    - name: EXTENSION_URL
                      value: https://github.com/argoproj-labs/rollout-extension/releases/download/v${argocd_helm_rollout_extension_version}/extension.tar

              resources:
                {}
                # limits:
                #   cpu: 50m
                #   memory: 128Mi
                # requests:
                #   cpu: 10m
                #   memory: 64Mi
            env:
              - name: ARGOCD_MAX_CONCURRENT_LOGIN_REQUESTS_COUNT
                value: "0"
          ## Redis ##
          redis:
            resources:
              limits:
                cpu: 120m
                memory: 256Mi
              requests:
                cpu: 120m
                memory: 256Mi
            metrics:
              enabled: true
              serviceMonitor:
                enabled: false
                additionalLabels:
                  prometheus.io/scrap-with: kube-prometheus-stack
                namespace: argocd
