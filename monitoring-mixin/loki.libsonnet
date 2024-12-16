local loki = import 'loki-mixin/mixin.libsonnet';





local updated_config = loki._config + {
  meta_monitoring+: {
      enabled: false,
    },
};

local loki_with_updated_config = loki + {"_config": updated_config };

local all_dashboards = loki_with_updated_config.grafanaDashboards;


local exported_resources = {
    "loki-debug.json": loki._config
    };

exported_resources + all_dashboards