# Read the XR and the OCDs
oxr = option("params").oxr
ocds = option("params").ocds

spec = oxr.spec
parameters = spec.parameters
# Initialize the items list
_items = []
## Adding resources
if parameters?.dbType == "postgres":
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
                        name = spec?.claimRef?.name
                        namespace = spec?.claimRef?.namespace
                    }
                    spec = {
                        crVersion = parameters?.postgres?.crVersion
                        image = parameters?.postgres?.image
                        postgresVersion = parameters?.postgres?.pgVersion
                        port = 5432
                        imagePullPolicy = "Always"
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
                                    "mydatabase"
                                ]
                                name = "admin"
                                options = "SUPERUSER"
                                password = {
                                    type = "ASCII"
                                }
                                secretName = "db-secret"
                            }
                        ]
                        backups = {
                            pgbackrest = {
                                image = "percona/percona-postgresql-operator:2.5.0-ppg16.4-pgbackrest2.53-1"
                                repos = [
                                    {
                                        name = "repo2"
                                        volume = {
                                            volumeClaimSpec = {
                                                accessModes = [
                                                    "ReadWriteOnce"
                                                ]
                                                resources = {
                                                    requests = {
                                                        storage = "1Gi"
                                                    }
                                                }
                                            }
                                        }
                                    }
                                ]
                            }
                        }
                        proxy = {
                            pgBouncer = {
                                image = "percona/percona-postgresql-operator:2.5.0-ppg16.4-pgbouncer1.23.1"
                                replicas = 1
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
                                        pool_mode = "transaction"
                                        query_wait_timeout = "600"
                                        max_prepared_statements = "1"
                                    }
                                }
                                exposeSuperusers = True
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
