# Private-cloud environment onboarding

The PushSecrets in this overlay default to a `15m` refresh interval. This limits
routine Vault authentication and lease writes while keeping storage credentials
within a 15-minute propagation window.

The generated `deploy-env-onboard` Application receives this setting through the
existing `deploy_env.onboard` configuration chain. Override the default in the
environment configuration consumed by `terraform/ccnew`:

```yaml
env_onboard_eso_refresh_interval: "30m"
```

The generated application exposes this as
`ARGOCD_ENV_deploy_env_onboard_eso_refresh_interval` to the `envsubst` plugin.
Explicit values are preserved; intervals below `15m` should be used only when
the additional ESO and Vault reconciliation load is understood and accepted.

Validate the default and override render behavior with:

```shell
python3 test_refresh_interval.py
```
