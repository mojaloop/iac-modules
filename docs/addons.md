# Addons

Addons provide a way to install additional applications that are loosely coupled
to the Mojaloop platform.

## Addon structure

Addons are defined as subdirectories in the `addons` directory.
Each subdirectory includes tha apps that are part of the addon.
Each app contains template files for creating the k8s resources and
optional sub-folders for any files used by the templates.
A special `.app.yaml` extension denotes the ArgoCD `kind: Application` resources,
which are added to tha `apps/app-yamls` folder.
See the diagram below for the meaning of each directory and file:

```text
├──📁 addons
|   ├──📁 addon-name-1
|   |   ├──📁 app-1                  # k8s resources for app-1
|   |   |   ├── 📁 .config           # app 1 configs folder
|   |   |   |    ├── app-1.yaml      # app 1 configuration
|   |   |   |    └── other-app.yaml  # other app configuration (use for dependencies)
|   |   |   ├── 📁 app-1-folder      # app 1 misc files (no templating)
|   |   |   ├── app-1.app.yaml       # ArgoCD Application definition for app-1
|   |   |   ├── kustomization.yaml
|   |   |   ├── values-default.yaml  # default values for app-1
|   |   |   ├── values-override.yaml # template for overrides
|   |   |   ├── vs.yaml              # virtual service for app-1
|   |   |   └── ...
|   |   └──📁 app-2                 # k8s resources for app-2
|   └──📁 addon-name-2
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

- `addons/<addon-name>/<app-name>/.config/<app-name>.yaml`: default values for
  the app

  Examples:

  ```yaml
  # addons/example-addon/app-1/.config/app-1.yaml
  enabled: true
  version: 2.7.0
  values: {}
  ```

  ```yaml
  # addons/example-addon/app-2/.config/app-2.yaml
  enabled: true
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

- `custom-config/<app-name>.yaml`: environment overrides for app-name

  Example:

  ```yaml
  # custom-config/app-1.yaml
  enabled: false    # disable app-1
  values:           # chart values overrides
    image:
      tag: v1.0.0   # override the image tag
  version: 1.0.0    # override the chart version
  ```

  ```yaml
  # custom-config/app-2.yaml
  namespace: new-namespace    # change the namespace for app-2
  syncWave: 1                 # move app-2 to sync wave 1
  ```

## Template variables

The following template variables are available for use in the addon app templates:

- `app`: contains the merged configuration for the app, including
  default values from the addon and overrides from the environment.
  It has the following keys by default:
  - `enabled: false`: boolean to enable or disable the app.
  - `name: <folder-name>`: the name of the app.
  - `namespace: <folder-name>`: the namespace where the app will be deployed.
  - `syncWave: 0`: the sync wave for the ArgoCD app.
- `cluster`: contains cluster-wide configuration values.
  It has the following keys by default:
  - `gitlabProjectUrl`: the URL of the GitLab project.
  - `env`: the environment name (e.g., dev, staging, prod).
  - `domain`: the base domain for the environment.
  - `domainSuffix`: the domain suffix for the environment.
  - `cc`: the control center name
  - `sc`: the storage cluster name
  - `submoduleRevisions`: a map of git submodule names to their revisions.
- `apps`: provides access to the merged configuration of all addon apps,
  useful for inter-app dependencies.

## Reusable addons

Addons are usually maintained in separate git repositories to allow reuse across
multiple environments and projects. Each addon repository usually contains
a group of related apps that are part of the addon. Examples of such addons are
developer addons or security addons.

To achieve reuse of addons, they can be cloned as git submodules in the
addons folder of the respective environment repository.

The easiest way to achieve that is to use the declarative
approach and configure the addons in the `submodules.yaml`:

   ```yaml
   addons/addon-name-1:
      url: https://example.com/addons/addon-name-1.git
      ref: stable
   addons/addon-name-2:
      url: https://example.com/addons/addon-name-2.git
      ref: v1.0
   ```

For more details about this approach check the [reusable profiles](profiles.md#reusable-profiles)
section in the profiles documentation.
