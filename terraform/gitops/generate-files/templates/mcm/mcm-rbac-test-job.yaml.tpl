apiVersion: batch/v1
kind: Job
metadata:
  name: mcm-rbac-validation
  namespace: ${mcm_namespace}
  annotations:
    argocd.argoproj.io/sync-wave: "5"
    argocd.argoproj.io/hook: PostSync
    argocd.argoproj.io/hook-delete-policy: BeforeHookCreation
spec:
  backoffLimit: 3
  template:
    metadata:
      annotations:
        vault.hashicorp.com/agent-inject: "true"
        vault.hashicorp.com/agent-pre-populate-only: "true"
        vault.hashicorp.com/role: "${mcm_vault_k8s_role_name}"
        vault.hashicorp.com/agent-inject-secret-portal-admin-password: "secret/${portal_admin_secret}"
        vault.hashicorp.com/agent-inject-template-portal-admin-password: |
          {{- with secret "secret/${portal_admin_secret}" -}}
          {{ .Data.data.${vault_secret_key} }}
          {{- end }}
        sidecar.istio.io/inject: "false"
    spec:
      serviceAccountName: ${mcm_service_account_name}
      restartPolicy: Never
      containers:
        - name: mcm-rbac-test
          image: mojaloop/ml-testing-toolkit-client-lib:${ttk_cli_version}
          imagePullPolicy: IfNotPresent
          command:
            - /bin/sh
            - '-c'
          args:
            - |
              set -e

              echo "===================================="
              echo "MCM RBAC Validation Test Suite"
              echo "===================================="
              echo ""

              # Download MCM test setup CLI from connection-manager-api repo
              echo "Downloading MCM test setup CLI..."
              until nslookup github.com; do
                echo "Waiting for DNS resolution..."
                sleep 5
              done

              wget https://raw.githubusercontent.com/mojaloop/connection-manager-api/refs/heads/feat/mcm-test-setup-script/scripts/mcm-test-setup \
                -O /tmp/mcm-test-setup
              chmod +x /tmp/mcm-test-setup

              # Download test collections from testing-toolkit-test-cases repo
              echo "Downloading test collections..."
              wget https://github.com/mojaloop/testing-toolkit-test-cases/archive/v${ttk_test_cases_version}.zip \
                -O /tmp/test-collections.zip
              mkdir -p /tmp/test_cases
              unzip -d /tmp/test_cases -o /tmp/test-collections.zip

              TEST_BASE_PATH="/tmp/test_cases/testing-toolkit-test-cases-${ttk_test_cases_version}"

              # Setup: Generate test data
              echo ""
              echo "===================================="
              echo "Setting Up Test Environment"
              echo "===================================="
              echo ""

              RANDOM_SUFFIX=$(date +%s%N | md5sum | head -c 6)
              MONETARY_ZONE_ID="1"

              DFSP1_ID="testdfsp1-$RANDOM_SUFFIX"
              DFSP1_NAME="Test DFSP 1 ($RANDOM_SUFFIX)"
              DFSP1_USER_EMAIL="testdfsp1-$RANDOM_SUFFIX@test.local"
              DFSP1_USER_PASSWORD="Test@$(openssl rand -base64 12)"

              DFSP2_ID="testdfsp2-$RANDOM_SUFFIX"
              DFSP2_NAME="Test DFSP 2 ($RANDOM_SUFFIX)"
              DFSP2_USER_EMAIL="testdfsp2-$RANDOM_SUFFIX@test.local"
              DFSP2_USER_PASSWORD="Test@$(openssl rand -base64 12)"

              echo "Monetary Zone: $MONETARY_ZONE_ID"
              echo "Test DFSP1: $DFSP1_ID ($DFSP1_USER_EMAIL)"
              echo "Test DFSP2: $DFSP2_ID ($DFSP2_USER_EMAIL)"
              echo ""

              # Cleanup function
              cleanup_test_dfsps() {
                echo ""
                echo "===================================="
                echo "Cleaning up test DFSPs..."
                echo "===================================="

                if [ -n "$PORTAL_ADMIN_SESSION" ]; then
                  /tmp/mcm-test-setup destroy-dfsp "$DFSP1_ID" "$PORTAL_ADMIN_SESSION" || true
                  /tmp/mcm-test-setup destroy-dfsp "$DFSP2_ID" "$PORTAL_ADMIN_SESSION" || true
                  echo "Cleanup completed"
                fi
              }

              trap cleanup_test_dfsps EXIT

              # Get portal admin session
              export PORTAL_ADMIN_PASSWORD=$(cat /vault/secrets/portal-admin-password)
              echo "Getting portal admin session..."
              PORTAL_ADMIN_SESSION=$(/tmp/mcm-test-setup get-admin-session)

              # Create DFSPs
              echo "Creating DFSP1..."
              /tmp/mcm-test-setup create-dfsp "$DFSP1_ID" "$DFSP1_NAME" "$DFSP1_USER_EMAIL" "$MONETARY_ZONE_ID" "$PORTAL_ADMIN_SESSION"

              echo "Creating DFSP2..."
              /tmp/mcm-test-setup create-dfsp "$DFSP2_ID" "$DFSP2_NAME" "$DFSP2_USER_EMAIL" "$MONETARY_ZONE_ID" "$PORTAL_ADMIN_SESSION"

              # Complete DFSP1 invitation
              echo ""
              echo "Completing DFSP1 invitation..."
              /tmp/mcm-test-setup complete-invitation "$DFSP1_USER_EMAIL" "$DFSP1_USER_PASSWORD" "Test" "DFSP1"

              # Clear Mailpit before DFSP2
              MAILPIT_URL="http://mailpit-http.${mailpit_namespace}.svc.cluster.local"
              curl -s -X DELETE "$MAILPIT_URL/api/v1/messages" > /dev/null

              # Complete DFSP2 invitation
              echo "Completing DFSP2 invitation..."
              /tmp/mcm-test-setup complete-invitation "$DFSP2_USER_EMAIL" "$DFSP2_USER_PASSWORD" "Test" "DFSP2"

              # Get operator sessions
              echo ""
              echo "Getting operator sessions..."
              DFSP1_OPERATOR_SESSION=$(/tmp/mcm-test-setup get-operator-session "$DFSP1_USER_EMAIL" "$DFSP1_USER_PASSWORD")
              DFSP2_OPERATOR_SESSION=$(/tmp/mcm-test-setup get-operator-session "$DFSP2_USER_EMAIL" "$DFSP2_USER_PASSWORD")

              # Generate PM4ML credentials
              echo ""
              echo "Generating PM4ML credentials..."
              DFSP1_CREDS=$(/tmp/mcm-test-setup generate-pm4ml-creds "$DFSP1_ID" "$DFSP1_OPERATOR_SESSION")
              DFSP1_CLIENT_ID=$(echo "$DFSP1_CREDS" | cut -d'|' -f1)
              DFSP1_CLIENT_SECRET=$(echo "$DFSP1_CREDS" | cut -d'|' -f2)

              DFSP2_CREDS=$(/tmp/mcm-test-setup generate-pm4ml-creds "$DFSP2_ID" "$DFSP2_OPERATOR_SESSION")
              DFSP2_CLIENT_ID=$(echo "$DFSP2_CREDS" | cut -d'|' -f1)
              DFSP2_CLIENT_SECRET=$(echo "$DFSP2_CREDS" | cut -d'|' -f2)

              # Get JWT tokens
              echo ""
              echo "Getting JWT tokens..."
              DFSP1_JWT=$(/tmp/mcm-test-setup get-jwt "$DFSP1_CLIENT_ID" "$DFSP1_CLIENT_SECRET")
              DFSP2_JWT=$(/tmp/mcm-test-setup get-jwt "$DFSP2_CLIENT_ID" "$DFSP2_CLIENT_SECRET")

              # Create TTK environment file
              cat > /tmp/mcm-test-env.json <<EOF
              {
                "inputValues": {
                  "MCM_URL": "http://mcm-api.${mcm_namespace}.svc.cluster.local",
                  "MCM_EXTERNAL_URL": "https://${mcm_external_fqdn}",
                  "MONETARY_ZONE_ID": "$MONETARY_ZONE_ID",
                  "DFSP1_ID": "$DFSP1_ID",
                  "DFSP1_NAME": "$DFSP1_NAME",
                  "DFSP2_ID": "$DFSP2_ID",
                  "DFSP2_NAME": "$DFSP2_NAME",
                  "PORTAL_ADMIN_SESSION": "$PORTAL_ADMIN_SESSION",
                  "DFSP1_OPERATOR_SESSION": "$DFSP1_OPERATOR_SESSION",
                  "DFSP2_OPERATOR_SESSION": "$DFSP2_OPERATOR_SESSION",
                  "DFSP1_JWT": "$DFSP1_JWT",
                  "DFSP2_JWT": "$DFSP2_JWT"
                }
              }
              EOF

              cat > /tmp/mcm-test-config.json <<'EOFCONFIG'
              {
                "DEFAULT_ENVIRONMENT": "mcm-test",
                "VERSIONING_SUPPORT_ENABLE": false
              }
              EOFCONFIG

              echo ""
              echo "===================================="
              echo "Running MCM RBAC Tests"
              echo "===================================="
              echo ""

              TEST_FAILED=0

              # Run positive tests
              echo "Running MCM RBAC positive tests..."
              if npm run cli -- \
                -c /tmp/mcm-test-config.json \
                -e /tmp/mcm-test-env.json \
                -i "$TEST_BASE_PATH/collections/hub/mcm/mcm_rbac_positive.json" \
                -u http://moja-ml-testing-toolkit-backend.${mojaloop_namespace}.svc.cluster.local:5050 \
                --report-format html \
                --report-auto-filename-enable true \
                --extra-summary-information="Test Suite:MCM RBAC Positive,Environment:${ttk_fqdn}" \
                --save-report true \
                --report-folder /tmp \
                --report-name mcm_rbac_positive \
                --save-report-base-url https://${ttk_fqdn}; then
                echo "Positive tests PASSED"
              else
                echo "ERROR: Positive tests FAILED"
                TEST_FAILED=1
              fi

              echo ""

              # Run negative tests
              echo "Running MCM RBAC negative tests..."
              if npm run cli -- \
                -c /tmp/mcm-test-config.json \
                -e /tmp/mcm-test-env.json \
                -i "$TEST_BASE_PATH/collections/hub/mcm/mcm_rbac_negative.json" \
                -u http://moja-ml-testing-toolkit-backend.${mojaloop_namespace}.svc.cluster.local:5050 \
                --report-format html \
                --report-auto-filename-enable true \
                --extra-summary-information="Test Suite:MCM RBAC Negative,Environment:${ttk_fqdn}" \
                --save-report true \
                --report-folder /tmp \
                --report-name mcm_rbac_negative \
                --save-report-base-url https://${ttk_fqdn}; then
                echo "Negative tests PASSED"
              else
                echo "ERROR: Negative tests FAILED"
                TEST_FAILED=1
              fi

              echo ""

              # Run PM4ML API tests
              if [ -f "$TEST_BASE_PATH/collections/hub/mcm/mcm_pm4ml_api.json" ]; then
                echo "Running MCM PM4ML API tests..."
                if npm run cli -- \
                  -c /tmp/mcm-test-config.json \
                  -e /tmp/mcm-test-env.json \
                  -i "$TEST_BASE_PATH/collections/hub/mcm/mcm_pm4ml_api.json" \
                  -u http://moja-ml-testing-toolkit-backend.${mojaloop_namespace}.svc.cluster.local:5050 \
                  --report-format html \
                  --report-auto-filename-enable true \
                  --extra-summary-information="Test Suite:MCM PM4ML API,Environment:${ttk_fqdn}" \
                  --save-report true \
                  --report-folder /tmp \
                  --report-name mcm_rbac_pm4ml_api \
                  --save-report-base-url https://${ttk_fqdn}; then
                  echo "PM4ML API tests PASSED"
                else
                  echo "ERROR: PM4ML API tests FAILED"
                  TEST_FAILED=1
                fi
              else
                echo "SKIP: PM4ML API test collection not found (may need newer test-cases version)"
              fi

              echo ""
              echo "===================================="
              echo "MCM RBAC Test Summary"
              echo "===================================="
              echo ""

              if [ $TEST_FAILED -eq 0 ]; then
                echo "All MCM RBAC tests PASSED"
                echo ""
                echo "View detailed reports in TTK UI:"
                echo "  URL: https://${ttk_fqdn}"
                echo ""
                exit 0
              else
                echo "ERROR: Some MCM RBAC tests FAILED"
                echo ""
                echo "View detailed reports in TTK UI:"
                echo "  URL: https://${ttk_fqdn}"
                echo ""
                exit 1
              fi
          env:
            # MCM Configuration
            - name: MCM_NAMESPACE
              value: "${mcm_namespace}"

            # Authentication Services
            - name: KRATOS_SERVICE_NAME
              value: "${kratos_service_name}"
            - name: KEYCLOAK_FQDN
              value: "${keycloak_fqdn}"
            - name: KEYCLOAK_HUBOP_REALM_NAME
              value: "${keycloak_hubop_realm_name}"

            # Testing Infrastructure
            - name: MAILPIT_NAMESPACE
              value: "${mailpit_namespace}"

            # Portal Admin User
            - name: PORTAL_ADMIN_USER
              value: "${portal_admin_user}"

            # Disable npm update notifier
            - name: NPM_CONFIG_UPDATE_NOTIFIER
              value: "false"
          resources:
            requests:
              memory: "256Mi"
              cpu: "100m"
            limits:
              memory: "512Mi"
              cpu: "500m"
