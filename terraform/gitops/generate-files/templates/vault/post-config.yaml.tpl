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
      if [ $VAULT_ROOT_TOKEN != "" ]
      then
        vault login -no-print $VAULT_ROOT_TOKEN
        cat <<EOT >/tmp/vault-admin-policy.hcl
        path "/*" {
          capabilities = ["create", "read", "update", "delete", "list", "sudo"]
        }
    EOT
        cat <<EOT >/tmp/vault-read-secrets-policy.hcl
        path "secret/*" {
          capabilities = ["read", "list"]
        }
    EOT
        vault policy write vault-admin /tmp/vault-admin-policy.hcl
        vault policy write read-secrets /tmp/vault-read-secrets-policy.hcl
        vault auth enable kubernetes
        vault write auth/kubernetes/config kubernetes_host=https://kubernetes.default.svc:443
        vault write auth/kubernetes/role/policy-admin bound_service_account_names=* bound_service_account_namespaces=* policies=vault-admin ttl=600s
        vault secrets enable --path=secret kv
        vault secrets tune -default-lease-ttl=2m secret/
        vault write ${dfsp_external_whitelist_secret} loopback="127.0.0.1/32"
        vault write ${dfsp_internal_whitelist_secret} loopback="127.0.0.1/32"
    %{ if enable_vault_oidc ~}
        vault auth enable oidc
        vault write auth/oidc/config \
          bound_issuer="${gitlab_server_url}" \
          oidc_discovery_url="${gitlab_server_url}" \
          oidc_client_id="$${OIDC_CLIENT_ID}" \
          oidc_client_secret="$${OIDC_CLIENT_SECRET}" \
          default_role="techops-admin"
        vault write auth/oidc/role/techops-admin -<<EOF
          {
            "user_claim": "sub",
            "bound_audiences": "$${OIDC_CLIENT_ID}",
            "allowed_redirect_uris": ["https://vault.${public_subdomain}/ui/vault/auth/oidc/oidc/callback"],
            "role_type": "oidc",
            "token_policies": "vault-admin",
            "ttl": "1h",
            "oidc_scopes": ["openid"], 
            "bound_claims": { "groups": ["${gitlab_admin_group_name}"] }
          }
    EOF
        vault write auth/oidc/role/techops-readonly -<<EOF
          {
            "user_claim": "sub",
            "bound_audiences": "$${OIDC_CLIENT_ID}",
            "allowed_redirect_uris": ["https://vault.${public_subdomain}/ui/vault/auth/oidc/oidc/callback"],
            "role_type": "oidc",
            "token_policies": "read-secrets",
            "ttl": "1h",
            "oidc_scopes": ["openid"],
            "bound_claims": { "groups": ["${gitlab_readonly_group_name}"] }
          }
    EOF
    %{ endif ~}
        rm /tmp/output.json || true
      else
        echo "no root token found, skipping init"
      fi
    else
      echo "vault already initialized"
    fi