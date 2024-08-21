auto_auth = {
  method "kubernetes" {
    mount_path = "auth/${k8s_auth_path}"
    config = {
      role = "${mcm_vault_k8s_role_name}"
    }
  }

  sink = {
    config = {
        path = "/home/vault/.token"
    }

    type = "file"
  }
}

exit_after_auth = false
pid_file = "/home/vault/.pid"
template {
  contents = <<EOH
{{ range secrets "${onboarding_secret_path}/" }}
{{ with secret (printf "${onboarding_secret_path}/%s" .) }}
---
apiVersion: redhatcop.redhat.io/v1alpha1
kind: VaultSecret
metadata:
  name: {{ .Data.host }}-clientcert-tls
  namespace: ${mojaloop_namespace}
spec:
  refreshPeriod: 1m0s
  vaultSecretDefinitions:
    - authentication:
        path: kubernetes
        role: policy-admin
        serviceAccount:
            name: default
      name: clientcertsecret
      path: ${onboarding_secret_path}/{{ .Data.host }}
  output:
    name: {{ .Data.host }}-clientcert-tls
    stringData:
      ca.crt: '{{ `{{ .clientcertsecret.ca_bundle }}` }}'
      tls.key: '{{ `{{ .clientcertsecret.client_key }}` }}'
      tls.crt: '{{ `{{ .clientcertsecret.client_cert_chain }}` }}'
    type: kubernetes.io/tls
---
apiVersion: redhatcop.redhat.io/v1alpha1
kind: VaultSecret
metadata:
  name: {{ .Data.host }}-clientcert-tls
  namespace: ${istio_egress_gateway_namespace}
spec:
  refreshPeriod: 1m0s
  vaultSecretDefinitions:
    - authentication:
        path: kubernetes
        role: policy-admin
        serviceAccount:
            name: default
      name: clientcertsecret
      path: ${onboarding_secret_path}/{{ .Data.host }}
  output:
    name: {{ .Data.host }}-clientcert-tls
    stringData:
      ca.crt: '{{ `{{ .clientcertsecret.ca_bundle }}` }}'
      tls.key: '{{ `{{ .clientcertsecret.client_key }}` }}'
      tls.crt: '{{ `{{ .clientcertsecret.client_cert_chain }}` }}'
    type: kubernetes.io/tls
---
apiVersion: networking.istio.io/v1alpha3
kind: ServiceEntry
metadata:
  name: {{ .Data.host }}
  namespace: ${mojaloop_namespace}
spec:
  hosts:
  - '{{ .Data.fqdn }}'
  location: MESH_EXTERNAL
  ports:
  - number: 80
    name: http
    protocol: HTTP
  - number: 443
    name: https
    protocol: HTTPS
  resolution: DNS
---
apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: {{ .Data.host }}-callback-gateway
  namespace: ${mojaloop_namespace}
spec:
  selector:
    istio: ${istio_egress_gateway_name}
  servers:
  - hosts:
    - '{{ .Data.fqdn }}'
    port:
      number: 443
      name: https
      protocol: HTTPS
    tls:
      mode: ISTIO_MUTUAL
---
apiVersion: networking.istio.io/v1alpha3
kind: DestinationRule
metadata:
  name: {{ .Data.host }}-callback
  namespace: ${mojaloop_namespace}
spec:
  host: ${istio_egress_gateway_name}.${istio_egress_gateway_namespace}.svc.cluster.local
  subsets:
  - name: {{ .Data.host }}
    trafficPolicy:
      loadBalancer:
        simple: ROUND_ROBIN
      portLevelSettings:
      - port:
          number: 443
        tls:
          mode: ISTIO_MUTUAL
          sni: {{ .Data.fqdn }}
---
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: {{ .Data.host }}-callback
  namespace: ${mojaloop_namespace}
spec:
  hosts:
  - {{ .Data.fqdn }}
  gateways:
  - {{ .Data.host }}-callback-gateway
  - mesh
  http:
  - match:
    - gateways:
      - mesh
      port: 80
    route:
    - destination:
        host: ${istio_egress_gateway_name}.${istio_egress_gateway_namespace}.svc.cluster.local
        subset: {{ .Data.host }}
        port:
          number: 443
      weight: 100
  - match:
    - gateways:
      - {{ .Data.host }}-callback-gateway
      port: 443
    route:
    - destination:
        host: {{ .Data.fqdn }}
        port:
          number: 443
      weight: 100
---
apiVersion: networking.istio.io/v1alpha3
kind: DestinationRule
metadata:
  name: originate-mtls-for-{{ .Data.host }}-callback
  namespace: ${mojaloop_namespace}
spec:
  host: {{ .Data.fqdn }}
  trafficPolicy:
    loadBalancer:
      simple: ROUND_ROBIN
    portLevelSettings:
    - port:
        number: 443
      tls:
        mode: MUTUAL
        credentialName: {{ .Data.host }}-clientcert-tls
        sni: {{ .Data.fqdn }}
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ .Data.host }}-ml-ttk-add-dfsp-conf
  namespace: ${mojaloop_namespace}
data:
  cli-add-dfsp-config.json: |
    {"logLevel":"2","mode":"outbound"}
  cli-add-dfsp-environment.json: |
    {
      "inputValues": {
        "HOST_ACCOUNT_LOOKUP_SERVICE": "http://${mojaloop_release_name}-account-lookup-service",
        "HOST_CENTRAL_LEDGER": "http://${mojaloop_release_name}-centralledger-service",
        "DFSP_CALLBACK_URL": "http://{{ .Data.fqdn }}",
        "DFSP_NAME": "{{ .Data.host }}",
        "HUB_NAME": "${hub_name}",
        "currency": "{{ .Data.currency_code }}",
        "isProxy": "{{ .Data.isProxy }}",
        "hub_operator": "NOT_APPLICABLE",
        "NET_DEBIT_CAP": "50000"
      }
    }
---
apiVersion: batch/v1
kind: Job
metadata:
  name: {{ .Data.host }}-onboard-dfsp
  namespace: ${mojaloop_namespace}
spec:
  template:
    spec:
      volumes:
        - name: {{ .Data.host }}-ml-ttk-add-dfsp-conf
          configMap:
            name: {{ .Data.host }}-ml-ttk-add-dfsp-conf
            items:
              - key: cli-add-dfsp-config.json
                path: cli-add-dfsp-config.json
              - key: cli-add-dfsp-environment.json
                path: cli-add-dfsp-environment.json
            defaultMode: 420

      containers:
        - name: ml-ttk-add-dfsp
          image: mojaloop/ml-testing-toolkit-client-lib:v1.2.0
          command:
            - /bin/sh
            - '-c'
          args:
            - >
              echo "Downloading the test collection...";

              wget
              https://github.com/mojaloop/testing-toolkit-test-cases/archive/v${onboarding_collection_tag}.zip
              -O downloaded-test-collections.zip;

              mkdir tmp_test_cases;

              unzip -d tmp_test_cases -o downloaded-test-collections.zip;

              fxp_currencies="{{ .Data.fxpCurrencies }}"

              if [ -z "$fxp_currencies" ]; then

                npm run cli -- \
                  -c cli-add-dfsp-config.json \
                  -e cli-add-dfsp-environment.json \
                  -i tmp_test_cases/testing-toolkit-test-cases-${onboarding_collection_tag}/collections/hub/provisioning_dfsp \
                  -u http://moja-ml-testing-toolkit-backend:5050 \
                  --report-format html \
                  --report-auto-filename-enable true \
                  --extra-summary-information="Test Suite:Provisioning DFSP,Environment:${ttk_backend_fqdn}" \
                  --save-report true \
                  --report-name standard_provisioning_collection \
                  --save-report-base-url https://${ttk_backend_fqdn};
                export TEST_RUNNER_EXIT_CODE="$?";

              else

                for fxp_currency in $fxp_currencies; do
                  echo "Onboarding FXP currency $fxp_currency"
                  node -e "const x=require('./cli-add-dfsp-environment.json');x.inputValues.fxpCurrency='$fxp_currency';console.log(JSON.stringify(x))" > fxp.json
                  npm run cli -- \
                    -c cli-add-dfsp-config.json \
                    -e fxp.json \
                    -i tmp_test_cases/testing-toolkit-test-cases-${onboarding_collection_tag}/collections/hub/provisioning_fxp \
                    -u http://moja-ml-testing-toolkit-backend:5050 \
                    --report-format html \
                    --report-auto-filename-enable true \
                    --extra-summary-information="Test Suite:Provisioning FXP currency $fxp_currency,Environment:${ttk_backend_fqdn}" \
                    --save-report true \
                    --report-name standard_provisioning_collection \
                    --save-report-base-url https://${ttk_backend_fqdn};
                  export TEST_RUNNER_EXIT_CODE="$?";
                  if [ "$TEST_RUNNER_EXIT_CODE" -ne 0 ]; then break; fi;
                done;

              fi

              echo "Test Runner finished with exit code:
              $TEST_RUNNER_EXIT_CODE";

              exit $TEST_RUNNER_EXIT_CODE;
          envFrom:
            - secretRef:
                name: moja-ml-ttk-test-setup-aws-creds
          resources: {}
          volumeMounts:
            - name: {{ .Data.host }}-ml-ttk-add-dfsp-conf
              mountPath: /opt/app/cli-add-dfsp-environment.json
              subPath: cli-add-dfsp-environment.json
            - name: {{ .Data.host }}-ml-ttk-add-dfsp-conf
              mountPath: /opt/app/cli-add-dfsp-config.json
              subPath: cli-add-dfsp-config.json
          terminationMessagePath: /dev/termination-log
          terminationMessagePolicy: File
          imagePullPolicy: IfNotPresent
      restartPolicy: Never
      terminationGracePeriodSeconds: 30
      dnsPolicy: ClusterFirst
      securityContext: {}
      schedulerName: default-scheduler
  completionMode: NonIndexed
  suspend: false

{{ end }}{{ end }}
  EOH
  destination = "/vault/secrets/tmp/callback.yaml"
  command     = "kubectl apply -f /vault/secrets/tmp/callback.yaml"
}

template {
  contents = <<EOH
apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
  name: dfsp-whitelist-ingress-policy
  namespace: ${istio_external_gateway_namespace}
spec:
  selector:
    matchLabels:
      istio: ${istio_external_gateway_name}
  action: DENY
  rules:
  - from:
      - source:
          notRemoteIpBlocks: [ {{ with secret "${dfsp_external_whitelist_secret}" }}{{ range $k, $v := .Data }}"{{ $v }}",{{ end }}{{ end }}{{ with secret "${dfsp_internal_whitelist_secret}" }}{{ range $k, $v := .Data }}"{{ $v }}",{{ end }}{{ end }}"${private_network_cidr}" ]
    when:
      - key: connection.sni
        values: ["${interop_switch_fqdn}", "${interop_switch_fqdn}:*"]
  EOH
  destination = "/vault/secrets/tmp/whitelist.yaml"
  command     = "kubectl -n ${istio_external_gateway_namespace} apply -f /vault/secrets/tmp/whitelist.yaml"
}

vault = {
  address = "${vault_endpoint}"
}