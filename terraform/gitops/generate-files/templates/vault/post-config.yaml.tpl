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
    if [ $(vault status -format=json | jq .initialized) == "false" ]
    then
      vault operator init -format=json > /tmp/output.json
      export VAULT_ROOT_TOKEN=$(cat /tmp/output.json | jq .root_token | tr -d '"')
      if [ $VAULT_ROOT_TOKEN != "" ]
      then
        export VAULT_ROOT_TOKEN_FOUND=$(curl -sw '%%{http_code}' --request GET "$${GITLAB_URL}/VAULT_ROOT_TOKEN" --header "Authorization: Bearer $GITLAB_TOKEN" -o /dev/null)
        if [ $VAULT_ROOT_TOKEN_FOUND == "404" ]
        then
          curl -s --request POST "$GITLAB_URL" --header "Authorization: Bearer $GITLAB_TOKEN" --form "key=VAULT_ROOT_TOKEN" --form "value=$VAULT_ROOT_TOKEN" --form "raw=true" --form "masked=true" -o /dev/null
        else
          echo "vault root token already present, updating code"
          curl -s --request PUT "$${GITLAB_URL}/VAULT_ROOT_TOKEN" --header "Authorization: Bearer $GITLAB_TOKEN" --form "value=$VAULT_ROOT_TOKEN" -o /dev/null
        fi
      else
        echo "VAULT_ROOT_TOKEN not parsed correctly, exiting"
        exit 1
      fi
      for ((i=0; i<=NUM_KEYS; i++))
      do
        export RECOVERY_KEY=$(cat /tmp/output.json | jq .recovery_keys_b64[$i] | tr -d '"')
        export RECOVERY_CODE_FOUND=$(curl -sw '%%{http_code}' --request GET "$${GITLAB_URL}/RECOVERY_KEY_$i" --header "Authorization: Bearer $GITLAB_TOKEN" -o /dev/null)
        if [ $RECOVERY_CODE_FOUND == "404" ]
        then
          curl -s --request POST "$GITLAB_URL" --header "Authorization: Bearer $GITLAB_TOKEN" --form "key=RECOVERY_KEY_$i" --form "value=$RECOVERY_KEY" --form "raw=true" --form "masked=true" -o /dev/null
        else
          echo "recovery code already present, updating code"
          curl -s --request PUT "$${GITLAB_URL}/RECOVERY_KEY_$i" --header "Authorization: Bearer $GITLAB_TOKEN" --form "value=$RECOVERY_KEY" -o /dev/null
        fi
      done
      else
        echo "no root token found, skipping init"
      fi
    else
      echo "vault already initialized"
      fetch_vault_root_token
    fi

    echo "Logging into Vault..."
vault login -no-print $VAULT_ROOT_TOKEN || true

# Policies
vault policy write vault-admin /tmp/vault-admin-policy.hcl || true
vault policy write read-secrets /tmp/vault-read-secrets-policy.hcl || true

# Kubernetes Auth
vault auth enable kubernetes || true
vault write auth/kubernetes/config kubernetes_host=https://kubernetes.default.svc:443 || true
vault write auth/kubernetes/role/policy-admin \
  bound_service_account_names='*' \
  bound_service_account_namespaces='*' \
  policies=vault-admin ttl=600s || true

# Secrets Engine
vault secrets enable --path=${local_vault_kv_root_path} kv || true
vault secrets tune -default-lease-ttl=2m ${local_vault_kv_root_path}/ || true

# OIDC Auth (Optional)
%{ if enable_vault_oidc ~}
vault auth enable oidc || true
vault write auth/oidc/config \
  bound_issuer="${zitadel_server_url}" \
  oidc_discovery_url="${zitadel_server_url}" \
  oidc_client_id="$${OIDC_CLIENT_ID}" \
  oidc_client_secret="$${OIDC_CLIENT_SECRET}" \
  default_role="techops-admin" || true

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
%{ endif ~}

echo "Vault bootstrap complete ✅"