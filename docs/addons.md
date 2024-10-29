# Addons

Addons provide a way to install additional applications that are loosely coupled
to the Mojaloop platform.

## Addon structure

Addons are defined as subdirectories in the `addons` directory.
Each subdirectory includes tha apps that are part of the addon.
See the diagram below for the meaning of each directory and file:

```text
├──📁 addons
|   ├──📁 addon-name-1
|   |   ├──📁 app-yamls              # define apps for the root app
|   |   |   ├── app-1.yaml
|   |   |   └── app-2.yaml
|   |   ├──📁 app-1                  # k8s resources for app-1
|   |   |   ├── kustomization.yaml
|   |   |   ├── values-default.yaml  # default values for app-1
|   |   |   ├── values-override.yaml # template for overrides
|   |   |   ├── vs.yaml              # virtual service for app-1
|   |   |   └── ...
|   |   ├──📁 app-2                 # k8s resources for app-2
|   |   └── default.yaml            # default values for addon-name-1
|   └──📁 addon-name-2
|       ├──📁 app-yamls             # define apps for the root app
|       ├──📁 app-3                 # k8s resources for app-3
|       ├──📁 app-4                 # k8s resources for app-2
|       └──📁 ...
├──📁 custom-config
|   ├── app-yamls.yaml
|   ├── app-1.yaml
|   ├── app-2.yaml
|   ├── app-3.yaml
|   └── app-4.yaml
```

## Addon configuration

Addons are configured using several files:

- `addons/<addon-name>/default.yaml`: default values for the addon

  Example:

  ```yaml
  app-yamls:
      app-1:
        enabled: true
        syncWave: 0
        namespace: app-1
      app-2:
        enabled: true
        syncWave: 0
        namespace: app-2

  app-1:
      version: 2.7.0
      values: {}

  app-2:
      version: 0.7.26
      tag: v2.6.0
      values: {}
  ```

- `addons/<addon-name>/<app-name>/values-default.yaml`: default values for each app

  Example:

  ```yaml
  image:
    tag: ${app.tag}
  config:
    oidc:
      clientID: test
  ```

- `custom-config/app-yamls.yaml`: environment overrides for ArgoCD app settings

  Example:

  ```yaml
  app-1:
    enabled: false              # disable app-1
  app-2:
    namespace: new-namespace    # change the namespace for app-2
    syncWave: 1                 # move app-2 to sync wave 1
  ```

- `custom-config/<app-name>.yaml`: environment overrides for app-name

  Example:

  ```yaml
  values:           # chart values overrides
    image:
      tag: v1.0.0   # override the image tag
  version: 1.0.0    # override the chart version
  ```

## Reusable addons

To achieve addons, profiles can be cloned as git submodules in the
addons folder of the respective IAC environment repository.

The easiest way is to achieve that is to use the declarative
approach and configure the addons in the `submodules.yaml`:

   ```yaml
   addons/addon-name-1:
      url: https://example.com/addons/addon-name-1.git
      ref: stable
   addons/addon-name-2:
      url: https://example.com/addons/addon-name-2.git
      ref: v1.0
   ```

For more details check the [reusable profiles](profiles.md#reusable-profiles)
section in the profiles documentation.
