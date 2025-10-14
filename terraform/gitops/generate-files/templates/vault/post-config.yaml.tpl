apiVersion: v1
kind: ConfigMap
metadata:
  name: post-config
  annotations:
    argocd.argoproj.io/sync-wave: "${vault_cm_sync_wave}"
data:
  bootstrap.sh: |
    #!/bin/bash
    set -e
    export VAULT_ADDR=http://127.0.0.1:8200
    export VAULT_SKIP_VERIFY=true
    export NUM_KEYS=5

    # Function: get VAULT_ROOT_TOKEN from GitLab
    fetch_vault_root_token() {
      echo "Fetching existing VAULT_ROOT_TOKEN from GitLab..."
      export VAULT_ROOT_TOKEN=$(curl -s --request GET "$${GITLAB_URL}/VAULT_ROOT_TOKEN" \
        --header "Authorization: Bearer $GITLAB_TOKEN" | jq -r .value)
      if [ -z "$VAULT_ROOT_TOKEN" ] || [ "$VAULT_ROOT_TOKEN" == "null" ]; then
        echo "ERROR: Could not fetch VAULT_ROOT_TOKEN from GitLab"
        exit 1
      fi
    }

    create_or_update_gitlab_var() {
    local key="$1"
    local value="$2"

    HTTP_STATUS=$(curl -sw '%%{http_code}' --request GET "$GITLAB_URL/$key" \
        --header "Authorization: Bearer $GITLAB_TOKEN" -o /dev/null)

    if [ "$HTTP_STATUS" == "404" ]; then
        curl -s --request POST "$GITLAB_URL" \
            --header "Authorization: Bearer $GITLAB_TOKEN" \
            --form "key=$key" \
            --form "value=$value" \
            --form "raw=true" \
            --form "masked=true" -o /dev/null
        echo "Created GitLab variable $key"
    else
        curl -s --request PUT "$GITLAB_URL/$key" \
            --header "Authorization: Bearer $GITLAB_TOKEN" \
            --form "value=$value" -o /dev/null
        echo "Updated GitLab variable $key"
    fi
    }

    if [[ $(vault status -format=json | jq .initialized) == "false" ]]
    then
      vault operator init -format=json > /tmp/output.json
      export VAULT_ROOT_TOKEN=$(cat /tmp/output.json | jq .root_token | tr -d '"')
      if [ "$VAULT_ROOT_TOKEN" != "" ]
      then
        create_or_update_gitlab_var "VAULT_ROOT_TOKEN" "$VAULT_ROOT_TOKEN"
      else
        echo "VAULT_ROOT_TOKEN not parsed correctly, exiting"
        exit 1
      fi
      for ((i=0; i<=NUM_KEYS; i++))
      do
        export RECOVERY_KEY=$(cat /tmp/output.json | jq .recovery_keys_b64[$i] | tr -d '"')
        create_or_update_gitlab_var "RECOVERY_KEY_$i" "$RECOVERY_KEY"
      done
    else
      echo "vault already initialized"
      echo "fetching root token"
      fetch_vault_root_token
    fi


    if [ "$VAULT_ROOT_TOKEN" != "" ]
    then
      vault login -no-print $VAULT_ROOT_TOKEN
      cat <<EOT >/tmp/vault-admin-policy.hcl
      path "/*" {
        capabilities = ["create", "read", "update", "delete", "list", "sudo"]
      }
    EOT
      cat <<EOT >/tmp/vault-read-secrets-policy.hcl
      path "${local_vault_kv_root_path}/*" {
        capabilities = ["read", "list"]
      }
    EOT
      cat <<EOT >/tmp/vault-snapshot-policy.hcl
      path "sys/storage/raft/snapshot" {
        capabilities = ["read"]
      }
    EOT
      vault policy write vault-admin /tmp/vault-admin-policy.hcl
      vault policy write read-secrets /tmp/vault-read-secrets-policy.hcl

      if vault auth list -format=json | jq -e 'has("kubernetes/")' > /dev/null; then
        echo "✅ kubernetes is enabled"
      else
        echo "kubernetes is not enabled, enabling it"
        vault auth enable kubernetes
        echo "✅ kubernetes is enabled"
      fi
      vault write auth/kubernetes/config kubernetes_host=https://kubernetes.default.svc:443
      vault write auth/kubernetes/role/policy-admin bound_service_account_names=* bound_service_account_namespaces=* policies=vault-admin ttl=600s

      #Secret mount
      if vault secrets list -format=json | jq -e --arg path "${local_vault_kv_root_path}/" 'has($path)' >/dev/null; then
        echo "✅ Secrets engine '${local_vault_kv_root_path}/' is enabled"
      else
        echo "Secrets engine '${local_vault_kv_root_path}/' is not enabled"
        vault secrets enable --path=${local_vault_kv_root_path} kv
        echo "✅ Secrets engine '${local_vault_kv_root_path}/' is enabled"
      fi
      vault secrets tune -default-lease-ttl=2m ${local_vault_kv_root_path}/

      #snapshot
      if vault auth list -format=json | jq -e 'has("approle/")' > /dev/null; then
        echo "✅ AppRole is enabled"
      else
        echo "AppRole is not enabled, enabling it"
        vault auth enable approle
        echo "✅ AppRole is enabled"
      fi
      vault policy write snapshot /tmp/vault-snapshot-policy.hcl
      vault write auth/approle/role/snapshot-agent token_ttl=768h token_policies=snapshot
      ROLE_ID=$(vault read -format=json auth/approle/role/snapshot-agent/role-id | jq -r .data.role_id)
      SECRET_ID=$(vault write -f -format=json auth/approle/role/snapshot-agent/secret-id | jq -r .data.secret_id)

      create_or_update_gitlab_var "VAULT_SNAPSHOT_ROLE_ID" "$ROLE_ID"
      create_or_update_gitlab_var "VAULT_SNAPSHOT_SECRET_ID" "$SECRET_ID"

  %{ if enable_vault_oidc ~}

      if vault auth list -format=json | jq -e 'has("oidc/")' > /dev/null; then
        echo "✅ oidc is enabled"
      else
        echo "oidc is not enabled, enabling it"
        vault auth enable oidc
        echo "✅ oidc is enabled"
      fi

      vault write auth/oidc/config \
        bound_issuer="${zitadel_server_url}" \
        oidc_discovery_url="${zitadel_server_url}" \
        oidc_client_id="$${OIDC_CLIENT_ID}" \
        oidc_client_secret="$${OIDC_CLIENT_SECRET}" \
        default_role="techops-admin"
      vault write auth/oidc/role/techops-admin -<<EOF
        {
          "user_claim": "sub",
          "bound_audiences": "$${OIDC_CLIENT_ID}",
          "allowed_redirect_uris": ["https://${vault_fqdn}/ui/vault/auth/oidc/oidc/callback"],
          "role_type": "oidc",
          "token_policies": "vault-admin",
          "ttl": "1h",
          "oidc_scopes": ["openid"],
          "bound_claims": { "zitadel:grants": ["${zitadel_project_id}:${vault_admin_rbac_group}"] }
        }
    EOF
      vault write auth/oidc/role/techops-readonly -<<EOF
        {
          "user_claim": "sub",
          "bound_audiences": "$${OIDC_CLIENT_ID}",
          "allowed_redirect_uris": ["https://${vault_fqdn}/ui/vault/auth/oidc/oidc/callback"],
          "role_type": "oidc",
          "token_policies": "read-secrets",
          "ttl": "1h",
          "oidc_scopes": ["openid"],
          "bound_claims": { "zitadel:grants": ["${zitadel_project_id}:${vault_readonly_rbac_group}"] }
        }
    EOF
  %{ endif ~}
      rm /tmp/output.json || true
    else
      echo "no root token found, skipping init"
    fi
