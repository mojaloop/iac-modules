local mimir = import 'mimir-mixin/mixin.libsonnet';


local ingester_jobname = '.*ingester';
local distributor_jobname = '.*distributor';

local querier_jobname = '.*querier';
local query_frontend_jobname = '.*query-frontend';
local query_scheduler_jobname = '.*query-scheduler';

local store_gateway_jobname = '.*store-gateway';
local compactor_jobname = '.*compactor';

local ruler_querier_jobname = '.*ruler-querier';
local ruler_jobname = '.*ruler';
local ruler_query_frontend_jobname = '.*ruler-query-frontend';
local ruler_query_scheduler_jobname = '.*ruler-query-scheduler';

local alertmanager_jobname = '.*alertmanager';
local overrides_exporter_jobname = '.*overrides-exporter';



local config =  mimir._config + {
  job_names+: {
      ingester: [ingester_jobname],  // Match also custom and per-zone ingester deployments.
      ingester_partition: ['ingester.*-partition'],  // Match exclusively temporarily partition ingesters run during the migration to ingest storage.
      distributor: [distributor_jobname],  // Match also per-zone distributor deployments.
      querier: [querier_jobname],  // Match also custom querier deployments.
      ruler_querier: [ruler_querier_jobname],  // Match also custom querier deployments.
      ruler: [ruler_jobname],
      query_frontend: [query_frontend_jobname],  // Match also custom query-frontend deployments.
      ruler_query_frontend: [ruler_query_frontend_jobname],  // Match also custom ruler-query-frontend deployments.
      query_scheduler: [query_scheduler_jobname],  // Not part of single-binary. Match also custom query-scheduler deployments.
      ruler_query_scheduler: [ruler_query_scheduler_jobname],  // Not part of single-binary. Match also custom query-scheduler deployments.
      ring_members: ['admin-api', alertmanager_jobname, compactor_jobname, distributor_jobname, ingester_jobname, querier_jobname, ruler_jobname, ruler_querier_jobname, store_gateway_jobname],
      store_gateway: [store_gateway_jobname],  // Match also per-zone store-gateway deployments.
      gateway: ['gateway', 'cortex-gw.*'],  // Match also custom and per-zone gateway deployments.
      compactor: [compactor_jobname],  // Match also custom compactor deployments.
      alertmanager: [alertmanager_jobname],
      overrides_exporter: [overrides_exporter_jobname],

      // The following are job matchers used to select all components in a given "path".
      write: [distributor_jobname, ingester_jobname, ],
      read: [query_frontend_jobname, querier_jobname, ruler_query_frontend_jobname, ruler_querier_jobname],
      backend: [ruler_jobname, query_scheduler_jobname, ruler_query_scheduler_jobname, store_gateway_jobname, compactor_jobname, alertmanager_jobname, overrides_exporter_jobname],
    },

  container_names+: {
    distributor: "grafana-mimir-distributor",
    ingester: "grafana-mimir-ingester",
    // Need to over-ride because unfortunately bitnami chart is not following container names as per convention
    write: "grafana-mimir-distributor|grafana-mimir-ingester"
  }
};

local mimir_with_updated_config = mimir + {"_config": config};

local all_dashboards = mimir_with_updated_config.grafanaDashboards;


local exported_resources = {
    "mimir-overview.json": all_dashboards["mimir-overview.json"],
    "mimir-overview-networking.json": all_dashboards["mimir-overview-networking.json"],
    "mimir-overview-resources.json": all_dashboards["mimir-overview-resources.json"],

    "mimir-queries.json": all_dashboards["mimir-queries.json"],
    "mimir-reads.json": all_dashboards["mimir-reads.json"],
    "mimir-reads-networking.json": all_dashboards["mimir-reads-networking.json"],
    "mimir-reads-resources.json": all_dashboards["mimir-reads-resources.json"],
    
    "mimir-writes.json": all_dashboards["mimir-writes.json"],
    "mimir-writes-networking.json": all_dashboards["mimir-writes-networking.json"],
    "mimir-writes-resources.json": all_dashboards["mimir-writes-resources.json"],
    
    "mimir-compactor.json": all_dashboards["mimir-compactor.json"],
    "mimir-object-store.json": all_dashboards["mimir-object-store.json"],
    
    "mimir-rollout-progress.json": all_dashboards["mimir-rollout-progress.json"],
    "mimir-scaling.json": all_dashboards["mimir-scaling.json"],
    "mimir-slow-queries.json": all_dashboards["mimir-slow-queries.json"],
    "mimir-tenants.json": all_dashboards["mimir-tenants.json"],

    };

exported_resources