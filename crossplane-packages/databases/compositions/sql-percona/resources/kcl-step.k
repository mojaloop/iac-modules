# Read the XR and the OCDs
oxr = option("params").oxr
ocds = option("params").ocds

spec = oxr.spec
parameters = spec.parameters
# Initialize the items list
_items = []
## Adding resources
if parameters?.dbtype == "postgres":
  _Object = {
    apiVersion = "kubernetes.crossplane.io/v1alpha2"
    kind = "Object"
    metadata = {
      name = "{}-ss".format(oxr.metadata.name)
      annotations = {
        "krm.kcl.dev/composition-resource-name": "percona-sql-db"
      }
    }
    spec = {
      forProvider = {
        manifest = {
          apiVersion = "pgv2.percona.com/v2"
          kind = "PerconaPGCluster"
          metadata = {
            name = "foo"
            namespace = "foo"
          }
          spec = {
            crVersion = parameters?.postgres?.crVersion
            image = parameters?.postgres?.image
            postgresVersion = parameters?.postgres?.postgresVersion
            port = 5432
            imagePullPolicy = parameters?.postgres?.imagePullPolicy
            openshift = False
            pause = False
            standby = {
              enabled = False
            }
            unmanaged = False
            instances = [
              {
                name = "instance1"
                replicas = parameters?.postgres?.replicas
                affinity = {
                  podAntiAffinity = {
                    preferredDuringSchedulingIgnoredDuringExecution = [
                      {
                        podAffinityTerm = {
                          labelSelector = {
                            matchLabels = {
                              "postgres-operator.crunchydata.com/data" = "postgres"
                            }
                          }
                          topologyKey = "kubernetes.io/hostname"
                        }
                        weight = 1
                      }
                    ]
                  }
                }
                dataVolumeClaimSpec = {
                  accessModes = [
                    "ReadWriteOnce"
                  ]
                  resources = {
                    requests = {
                      storage = parameters?.postgres?.storageSize
                    }
                  }
                }
              }
            ]
            users = [
              {
                databases = [
                  "foo"
                ]
                name = "foo"
                options = "SUPERUSER"
                password = {
                  type = "ASCII"
                }
                secretName = "foo"
              }
            ]
            proxy = {
              pgBouncer = {
                image = "foo"
                replicas = 2
                port = 5432
                affinity = {
                  podAntiAffinity = {
                    preferredDuringSchedulingIgnoredDuringExecution = [
                      {
                        podAffinityTerm = {
                          labelSelector = {
                            matchLabels = {
                              "postgres-operator.crunchydata.com/role" = "pgbouncer"
                            }
                          }
                          topologyKey = "kubernetes.io/hostname"
                        }
                        weight = 1
                      }
                    ]
                  }
                }
                config = {
                  global = {
                    pool_mode = "foo"
                    query_wait_timeout = "foo"
                    max_prepared_statements = "foo"
                  }
                }
                exposeSuperusers = "foo"
              }
            }
          }
        }
      }
      managementPolicies = spec.managementPolicies
      providerConfigRef = {
        name = spec.providerConfigsRef.scK8sProviderName
      }
    }
  }

_items += [_Object]

dxr = {
  **oxr
}

items = _items + [dxr]
