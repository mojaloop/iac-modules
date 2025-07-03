apiVersion: redhatcop.redhat.io/v1alpha1
kind: PasswordPolicy
metadata:
  name: ${dbdeploy_name_prefix}-docdb-password-policy
  namespace: ${namespace}
  annotations:
    argocd.argoproj.io/sync-wave: "-6"
spec:
  # Add fields here
  authentication:
    path: kubernetes
    role: policy-admin
    serviceAccount:
      name: default
  passwordPolicy: |
    length = 20
      rule "charset" {
        charset = "abcdefghijklmnopqrstuvwxyz"
        min-chars = 1
      }
      rule "charset" {
        charset = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        min-chars = 1
      }
      rule "charset" {
        charset = "0123456789"
        min-chars = 1
      }
      rule "charset" {
        charset = "_"
        min-chars = 1
      }
---
apiVersion: redhatcop.redhat.io/v1alpha1
kind: RandomSecret
metadata:
  name: ${dbdeploy_name_prefix}-docdb-password
  namespace: ${namespace}
  annotations:
    argocd.argoproj.io/sync-wave: "-6"
spec:
  authentication:
    path: kubernetes
    role: policy-admin
    serviceAccount:
      name: default
  isKVSecretsEngineV2: true
  path: /secret/generated
  secretKey: password
  secretFormat:
    passwordPolicyName: ${dbdeploy_name_prefix}-docdb-password-policy
---
apiVersion: redhatcop.redhat.io/v1alpha1
kind: VaultSecret
metadata:
  name: ${db_secret}
  namespace: ${namespace}
  annotations:
    argocd.argoproj.io/sync-wave: "-6"
spec:
  refreshPeriod: 1m0s
  vaultSecretDefinitions:
    - authentication:
        path: kubernetes
        role: policy-admin
        serviceAccount:
          name: default
      name: dynamicsecret_db_password
      path: /secret/generated/${dbdeploy_name_prefix}-docdb-password
  output:
    name: ${db_secret}
    stringData:
      ${db_secret_key}: "{{ .dynamicsecret_db_password.password }}"
    type: Opaque
---
apiVersion: aws.mojaloop.io/v1alpha1
kind: DocDbCluster
metadata:
  name: "${cluster_name}"
  namespace: "${namespace}"
spec:
  managementPolicies:
    - "*"
  providerConfigsRef:
    awsProviderConfigName: "aws-cp-upbound-provider-config"
    ccK8sProviderName: "kubernetes-provider"
  parameters:
    externalServiceName: "${externalservice_name}"
    appNamespace: "${namespace}"
    consumerAppsExternalServices: ${consumer_app_externalname_services}
    allowMajorVersionUpgrade: ${allow_major_version_upgrade}
    applyImmediately: ${apply_immediately}
    backupRetentionPeriod: ${backup_retention_period}
    databaseName: "${db_name}"
    dbClusterInstanceClass: "${instance_class}"
    deletionProtection: ${deletion_protection}
    engine: ${engine}
    engineVersion: "${engine_version}"
    family: ${family}
    instanceCount: ${instance_count}
    parameter:
      - applyMethod: pending-reboot
        name: tls
        value: disabled
    passwordSecret:
      key: ${db_secret_key}
      name: ${db_secret}
      namespace: "${namespace}"
    port: ${port}
    preferredBackupWindow: "${preferred_backup_window}"
    preferredMaintenanceWindow: ${preferred_maintenance_window}
    region: "${cloud_region}"
    skipFinalSnapshot: ${skip_final_snapshot}
    finalSnapshotIdentifier: "${final_snapshot_identifier}"
    storageEncrypted: ${storage_encrypted}
    storageType: "${storage_type}"
    subnets: ${subnet_list}
    azs: ${azs}
    username: ${db_username}
    vpcCidr: ${vpc_cidr}
    vpcId: ${vpc_id}