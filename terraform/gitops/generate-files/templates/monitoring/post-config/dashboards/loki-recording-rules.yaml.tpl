{
  "annotations": {
    "list": [
      {
        "builtIn": 1,
        "datasource": "-- Grafana --",
        "enable": true,
        "hide": true,
        "iconColor": "rgba(0, 211, 255, 1)",
        "name": "Annotations & Alerts",
        "type": "dashboard"
      }
    ]
  },
  "editable": true,
  "fiscalYearStartMonth": 0,
  "graphTooltip": 0,
  "id": null,
  "links": [],
  "panels": [
    {
      "title": "Log Lines / sec by Namespace",
      "type": "timeseries",
      "datasource": {
        "type": "prometheus",
        "uid": "${DS_PROMETHEUS}"
      },
      "targets": [
        {
          "expr": "loki_lines_total_by_namespace{namespace=~\"$namespace\"}",
          "legendFormat": "{{namespace}}",
          "refId": "A"
        }
      ],
      "fieldConfig": {
        "defaults": {
          "unit": "ops"
        }
      },
      "gridPos": { "x": 0, "y": 0, "w": 12, "h": 8 }
    },
    {
      "title": "Log Lines / sec by App",
      "type": "timeseries",
      "datasource": {
        "type": "prometheus",
        "uid": "${DS_PROMETHEUS}"
      },
      "targets": [
        {
          "expr": "loki_lines_total_by_namespace_app{namespace=~\"$namespace\", app=~\"$app\"}",
          "legendFormat": "{{app}}",
          "refId": "A"
        }
      ],
      "fieldConfig": {
        "defaults": {
          "unit": "ops"
        }
      },
      "gridPos": { "x": 12, "y": 0, "w": 12, "h": 8 }
    },
    {
      "title": "Top Pods by Log Volume",
      "type": "barchart",
      "datasource": {
        "type": "prometheus",
        "uid": "${DS_PROMETHEUS}"
      },
      "targets": [
        {
          "expr": "topk(10, loki_lines_total_by_pod{namespace=~\"$namespace\"})",
          "legendFormat": "{{pod}}",
          "refId": "A"
        }
      ],
      "gridPos": { "x": 0, "y": 8, "w": 12, "h": 8 }
    },
    {
      "title": "Bytes / sec by Namespace",
      "type": "timeseries",
      "datasource": {
        "type": "prometheus",
        "uid": "${DS_PROMETHEUS}"
      },
      "targets": [
        {
          "expr": "loki_bytes_total_by_namespace{namespace=~\"$namespace\"}",
          "legendFormat": "{{namespace}}",
          "refId": "A"
        }
      ],
      "fieldConfig": {
        "defaults": {
          "unit": "Bps"
        }
      },
      "gridPos": { "x": 12, "y": 8, "w": 12, "h": 8 }
    },
    {
      "title": "Error Lines / sec by Namespace",
      "type": "timeseries",
      "datasource": {
        "type": "prometheus",
        "uid": "${DS_PROMETHEUS}"
      },
      "targets": [
        {
          "expr": "loki_error_lines_by_namespace{namespace=~\"$namespace\"}",
          "legendFormat": "{{namespace}}",
          "refId": "A"
        }
      ],
      "fieldConfig": {
        "defaults": {
          "unit": "ops"
        }
      },
      "gridPos": { "x": 0, "y": 16, "w": 12, "h": 8 }
    },
    {
      "title": "Top Pods by Error Rate",
      "type": "barchart",
      "datasource": {
        "type": "prometheus",
        "uid": "${DS_PROMETHEUS}"
      },
      "targets": [
        {
          "expr": "topk(10, loki_error_lines_by_pod{namespace=~\"$namespace\"})",
          "legendFormat": "{{pod}}",
          "refId": "A"
        }
      ],
      "gridPos": { "x": 12, "y": 16, "w": 12, "h": 8 }
    },
    {
      "title": "Error Ratio (%) by Namespace",
      "type": "timeseries",
      "datasource": {
        "type": "prometheus",
        "uid": "${DS_PROMETHEUS}"
      },
      "targets": [
        {
          "expr": "(loki_error_lines_by_namespace{namespace=~\"$namespace\"} / loki_lines_total_by_namespace{namespace=~\"$namespace\"}) * 100",
          "legendFormat": "{{namespace}}",
          "refId": "A"
        }
      ],
      "fieldConfig": {
        "defaults": {
          "unit": "percent"
        }
      },
      "gridPos": { "x": 0, "y": 24, "w": 24, "h": 8 }
    }
  ],
  "schemaVersion": 39,
  "style": "dark",
  "tags": ["loki", "logs", "kubernetes", "prometheus"],
  "templating": {
    "list": [
      {
        "name": "namespace",
        "type": "query",
        "datasource": "Prometheus",
        "query": "label_values(loki_lines_total_by_namespace, namespace)",
        "includeAll": true,
        "multi": true
      },
      {
        "name": "app",
        "type": "query",
        "datasource": "Prometheus",
        "query": "label_values(loki_lines_total_by_namespace_app{namespace=~\"$namespace\"}, app)",
        "includeAll": true,
        "multi": true
      }
    ]
  },
  "time": {
    "from": "now-6h",
    "to": "now"
  },
  "timezone": "",
  "title": "Loki Recording Rules",
  "uid": "loki-prom-logs",
  "version": 1
}
