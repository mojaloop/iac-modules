# Private-cloud environment onboarding

The PushSecrets in this overlay default to a `15m` refresh interval. This limits
routine Vault authentication and lease writes while keeping storage credentials
within a 15-minute propagation window.

The overlay uses the existing Argo CD `envsubst` plugin. To override the default,
set the following plugin parameter on the generated `deploy-env-onboard`
Application:

```yaml
spec:
  source:
    plugin:
      env:
        - name: eso_refresh_interval
          value: 30m
```

Argo CD exposes this parameter to the plugin as
`ARGOCD_ENV_eso_refresh_interval`. Explicit values are preserved; intervals below
`15m` should be used only when the additional ESO and Vault reconciliation load
is understood and accepted.

Validate the default and override render behavior with:

```shell
python3 test_refresh_interval.py
```
