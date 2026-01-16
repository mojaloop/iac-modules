apiVersion: grafana.integreatly.org/v1beta1
kind: GrafanaDashboard
metadata:
  name: loki-log-metrics
spec:
  folder: monitoring
  instanceSelector:
    matchLabels:
      dashboards: "grafana"
  datasources:
    - inputName: DS_PROMETHEUS
      datasourceName: Prometheus
  json: |
    {
      "uid": "loki-prom-metrics",
      "title": "Loki Log Metrics (Prometheus)",
      "tags": ["loki", "logs", "prometheus", "kubernetes"],
      "schemaVersion": 39,
      "version": 2,
      "refresh": "30s",
      "time": {
        "from": "now-6h",
        "to": "now"
      },
      "templating": {
        "list": [
          {
            "name": "namespace",
            "type": "query",
            "datasource": {
              "type": "prometheus",
              "uid": "$${DS_PROMETHEUS}"
            },
            "query": "label_values(loki_lines_total_by_namespace, namespace)",
            "multi": true,
            "includeAll": true,
            "refresh": 2,
            "sort": 1
          },
          {
            "name": "app",
            "type": "query",
            "datasource": {
              "type": "prometheus",
              "uid": "$${DS_PROMETHEUS}"
            },
            "query": "label_values(loki_lines_total_by_namespace_app{namespace=~\"$namespace\"}, app)",
            "multi": true,
            "includeAll": true,
            "refresh": 2,
            "sort": 1
          },
          {
            "name": "pod",
            "type": "query",
            "datasource": {
              "type": "prometheus",
              "uid": "$${DS_PROMETHEUS}"
            },
            "query": "label_values(loki_lines_total_by_pod{namespace=~\"$namespace\"}, pod)",
            "multi": true,
            "includeAll": true,
            "refresh": 2,
            "sort": 1
          }
        ]
      },
      "panels": [
        {
          "type": "timeseries",
          "title": "Log Lines / sec by Namespace",
          "datasource": {
            "type": "prometheus",
            "uid": "$${DS_PROMETHEUS}"
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
          "type": "timeseries",
          "title": "Log Lines / sec by App",
          "datasource": {
            "type": "prometheus",
            "uid": "$${DS_PROMETHEUS}"
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
          "type": "barchart",
          "title": "Top Pods by Log Volume",
          "datasource": {
            "type": "prometheus",
            "uid": "$${DS_PROMETHEUS}"
          },
          "targets": [
            {
              "expr": "topk(10, loki_lines_total_by_pod{namespace=~\"$namespace\", pod=~\"$pod\"})",
              "legendFormat": "{{pod}}",
              "refId": "A"
            }
          ],
          "gridPos": { "x": 0, "y": 8, "w": 12, "h": 8 }
        },
        {
          "type": "timeseries",
          "title": "Bytes / sec by Namespace",
          "datasource": {
            "type": "prometheus",
            "uid": "$${DS_PROMETHEUS}"
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
          "type": "timeseries",
          "title": "Error Lines / sec by Namespace",
          "datasource": {
            "type": "prometheus",
            "uid": "$${DS_PROMETHEUS}"
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
          "type": "barchart",
          "title": "Top Pods by Error Rate",
          "datasource": {
            "type": "prometheus",
            "uid": "$${DS_PROMETHEUS}"
          },
          "targets": [
            {
              "expr": "topk(10, loki_error_lines_by_pod{namespace=~\"$namespace\", pod=~\"$pod\"})",
              "legendFormat": "{{pod}}",
              "refId": "A"
            }
          ],
          "gridPos": { "x": 12, "y": 16, "w": 12, "h": 8 }
        },
        {
          "type": "timeseries",
          "title": "Error Ratio (%) by Namespace",
          "datasource": {
            "type": "prometheus",
            "uid": "$${DS_PROMETHEUS}"
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
      ]
    }
