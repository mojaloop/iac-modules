# Profiles

Profiles provide a way to apply repeating configurations to different
environments.

## Profile Structure

Profiles are defined as files and subdirectories in the `profiles` directory.
Each profile directory contains configuration files that are applied on
top of the default configuration. Profiles are applied in the order
returned by the [bash filename expansion](https://www.gnu.org/software/bash/manual/bash.html#Filename-Expansion)
`profiles/**/?(*-)xxx.yaml`.

This pattern gives possibility to control the order of the profiles and
have different structures, based on the needs.

### Examples

Profiles, applying independent configurations will normally
not require a specific order. For example, a profile that disables
event sidecars and another that sets up a medium scale environment
can use the following structure:

```text
📁 env1
├──📁 default-config
|   ├── platform-stateful-resources.yaml
|   ├── mojaloop-values-override.yaml
|   └── ...
├──📁 profiles
|   ├──📁 medium-scale
|   |   ├── platform-stateful-resources.yaml (configures deployment replicas)
|   |   └── mojaloop-values-override.yaml    (configures topic partitions)
|   └──📁 no-event-sidecars
|       └── mojaloop-values-override.yaml    (configures sidecar)
├──📁 custom-config
|   ├── ...
|   └── ...
```

A profile can contain multiple configuration files that are applied in
the order they are returned by the bash filename expansion on top
of the default configuration. This is achieved by prefixing the filename
and allows splitting the configuration into multiple files for better organization.
The prefix can control the order or can be descriptive or do both, depending
on the needs. For example:

```text
📁 env1
├──📁 default-config
|   ├── ...
|   └── ...
├──📁 profiles
|   └──📁 debug
|       ├── 001-fxp-pm4ml-vars.yaml
|       ├── 002-payer-pm4ml-vars.yaml
|       ├── 003-payee-pm4ml-vars.yaml
|       ├── ledger-platform-stateful-resources.yaml
|       ├── quoting-platform-stateful-resources.yaml
|       ├── 001-mojaloop-values-override.yaml
|       └── 002-mojaloop-values-override.yaml
├──📁 custom-config
|   ├── ...
|   └── ...
```

In simpler cases profile files can be put directly in the `profiles` directory:

```text
📁 env1
├──📁 default-config
|   ├── ...
|   └── ...
├──📁 profiles
|   ├── debug-finance-portal-values-override
|   ├── debug-mojaloop-values-override.yaml
|   └── ...
├──📁 custom-config
|   ├── ...
|   └── ...
```

### Environment Specific Profiles

Configuration files can be environment specific. This can be achieved by
appending the environment type in front of the extension. For example,
`mojaloop-values-override.prod.yaml` will be applied only to the `prod`
environment. The environment specific profiles are applied after the generic
profiles.

The environment type is defined in the `ENV_TYPE` environment variable,
that must be defined in the pipeline.

## Reusable Profiles

To achieve reusability, profiles can be cloned as git submodules in the
respective IAC environment repository.

```bash
git submodule add https://gitlab.controlcenter.moja-onprem.net/profiles/xxx.git profiles/xxx
```

There are multiple ways to make use of git submodules, but the ones
that are potentially useful are:

1. **Branch tracking** - Git submodules can be configured to track a specific
   branch and can be updated to the latest version by running the
   `refresh-templates` action from the pipeline.

   To configure a submodule to track a specific branch, execute the following
   command:

   ```bash
   git config -f .gitmodules submodule.xxx.branch stable
   ```

1. **Tag pinning** - Git submodules can be pinned to a specific tag. This is useful
   when a specific version of a profile is required.

   ```bash
   cd profiles/xxx
   git checkout v1.0
   cd ../..
   git add profiles/xxx
   git commit -m "moved xxx to v1.0"
   git push
   ```

   If branch tracking has been configured previously, make sure you remove it:

   ```bash
    git config -f .gitmodules --unset submodule.xxx.branch
    ```
