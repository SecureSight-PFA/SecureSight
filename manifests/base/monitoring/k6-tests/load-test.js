{
  "__inputs"= [],
  "__requires"= [],
  "annotations"= { "list": [] },
  "editable"= true,
  "fiscalYearStartMonth"= 0,
  "graphTooltip"= 1,
  "id"= null,
  "links"= [],
  "panels"= [

    {
      "collapsed": false,
      "gridPos": { "h": 1, "w": 24, "x": 0, "y": 0 },
      "id": 200,
      "title": "Success Rate — per service",
      "type": "row"
    },

    { "datasource": { "type": "prometheus", "uid": "${datasource}" }, "fieldConfig": { "defaults": { "color": { "mode": "thresholds" }, "thresholds": { "steps": [{ "color": "red", "value": null }, { "color": "yellow", "value": 0.95 }, { "color": "green", "value": 0.99 }] }, "unit": "percentunit", "min": 0, "max": 1 }, "overrides": [] }, "gridPos": { "h": 4, "w": 3, "x": 0, "y": 1 }, "id": 201, "options": { "reduceOptions": { "calcs": ["lastNotNull"] }, "colorMode": "background" }, "targets": [{ "expr": "sum(rate(response_total{namespace=\"sock-shop\", direction=\"inbound\", srv_port!=\"4191\", pod=~\"carts-[^-]+-[^-]+\"}[2m])) / sum(rate(response_total{namespace=\"sock-shop\", direction=\"inbound\", srv_port!=\"4191\", pod=~\"carts-[^-]+-[^-]+\"}[2m]))", "refId": "A" }], "title": "Carts", "type": "stat" },

    { "datasource": { "type": "prometheus", "uid": "${datasource}" }, "fieldConfig": { "defaults": { "color": { "mode": "thresholds" }, "thresholds": { "steps": [{ "color": "red", "value": null }, { "color": "yellow", "value": 0.95 }, { "color": "green", "value": 0.99 }] }, "unit": "percentunit", "min": 0, "max": 1 }, "overrides": [] }, "gridPos": { "h": 4, "w": 3, "x": 3, "y": 1 }, "id": 202, "options": { "reduceOptions": { "calcs": ["lastNotNull"] }, "colorMode": "background" }, "targets": [{ "expr": "sum(rate(response_total{namespace=\"sock-shop\", direction=\"inbound\", srv_port!=\"4191\", pod=~\"catalogue-[^-]+-[^-]+\"}[2m])) / sum(rate(response_total{namespace=\"sock-shop\", direction=\"inbound\", srv_port!=\"4191\", pod=~\"catalogue-[^-]+-[^-]+\"}[2m]))", "refId": "A" }], "title": "Catalogue", "type": "stat" },

    { "datasource": { "type": "prometheus", "uid": "${datasource}" }, "fieldConfig": { "defaults": { "color": { "mode": "thresholds" }, "thresholds": { "steps": [{ "color": "red", "value": null }, { "color": "yellow", "value": 0.95 }, { "color": "green", "value": 0.99 }] }, "unit": "percentunit", "min": 0, "max": 1 }, "overrides": [] }, "gridPos": { "h": 4, "w": 3, "x": 6, "y": 1 }, "id": 203, "options": { "reduceOptions": { "calcs": ["lastNotNull"] }, "colorMode": "background" }, "targets": [{ "expr": "sum(rate(response_total{namespace=\"sock-shop\", direction=\"inbound\", srv_port!=\"4191\", pod=~\"front-end-[^-]+-[^-]+\"}[2m])) / sum(rate(response_total{namespace=\"sock-shop\", direction=\"inbound\", srv_port!=\"4191\", pod=~\"front-end-[^-]+-[^-]+\"}[2m]))", "refId": "A" }], "title": "Front-end", "type": "stat" },

    { "datasource": { "type": "prometheus", "uid": "${datasource}" }, "fieldConfig": { "defaults": { "color": { "mode": "thresholds" }, "thresholds": { "steps": [{ "color": "red", "value": null }, { "color": "yellow", "value": 0.95 }, { "color": "green", "value": 0.99 }] }, "unit": "percentunit", "min": 0, "max": 1 }, "overrides": [] }, "gridPos": { "h": 4, "w": 3, "x": 9, "y": 1 }, "id": 204, "options": { "reduceOptions": { "calcs": ["lastNotNull"] }, "colorMode": "background" }, "targets": [{ "expr": "sum(rate(response_total{namespace=\"sock-shop\", direction=\"inbound\", srv_port!=\"4191\", pod=~\"orders-[^-]+-[^-]+\"}[2m])) / sum(rate(response_total{namespace=\"sock-shop\", direction=\"inbound\", srv_port!=\"4191\", pod=~\"orders-[^-]+-[^-]+\"}[2m]))", "refId": "A" }], "title": "Orders", "type": "stat" },

    { "datasource": { "type": "prometheus", "uid": "${datasource}" }, "fieldConfig": { "defaults": { "color": { "mode": "thresholds" }, "thresholds": { "steps": [{ "color": "red", "value": null }, { "color": "yellow", "value": 0.95 }, { "color": "green", "value": 0.99 }] }, "unit": "percentunit", "min": 0, "max": 1 }, "overrides": [] }, "gridPos": { "h": 4, "w": 3, "x": 12, "y": 1 }, "id": 205, "options": { "reduceOptions": { "calcs": ["lastNotNull"] }, "colorMode": "background" }, "targets": [{ "expr": "sum(rate(response_total{namespace=\"sock-shop\", direction=\"inbound\", srv_port!=\"4191\", pod=~\"payment-[^-]+-[^-]+\"}[2m])) / sum(rate(response_total{namespace=\"sock-shop\", direction=\"inbound\", srv_port!=\"4191\", pod=~\"payment-[^-]+-[^-]+\"}[2m]))", "refId": "A" }], "title": "Payment", "type": "stat" },

    { "datasource": { "type": "prometheus", "uid": "${datasource}" }, "fieldConfig": { "defaults": { "color": { "mode": "thresholds" }, "thresholds": { "steps": [{ "color": "red", "value": null }, { "color": "yellow", "value": 0.95 }, { "color": "green", "value": 0.99 }] }, "unit": "percentunit", "min": 0, "max": 1 }, "overrides": [] }, "gridPos": { "h": 4, "w": 3, "x": 15, "y": 1 }, "id": 206, "options": { "reduceOptions": { "calcs": ["lastNotNull"] }, "colorMode": "background" }, "targets": [{ "expr": "sum(rate(response_total{namespace=\"sock-shop\", direction=\"inbound\", srv_port!=\"4191\", pod=~\"shipping-[^-]+-[^-]+\"}[2m])) / sum(rate(response_total{namespace=\"sock-shop\", direction=\"inbound\", srv_port!=\"4191\", pod=~\"shipping-[^-]+-[^-]+\"}[2m]))", "refId": "A" }], "title": "Shipping", "type": "stat" },

    { "datasource": { "type": "prometheus", "uid": "${datasource}" }, "fieldConfig": { "defaults": { "color": { "mode": "thresholds" }, "thresholds": { "steps": [{ "color": "red", "value": null }, { "color": "yellow", "value": 0.95 }, { "color": "green", "value": 0.99 }] }, "unit": "percentunit", "min": 0, "max": 1 }, "overrides": [] }, "gridPos": { "h": 4, "w": 3, "x": 18, "y": 1 }, "id": 207, "options": { "reduceOptions": { "calcs": ["lastNotNull"] }, "colorMode": "background" }, "targets": [{ "expr": "sum(rate(response_total{namespace=\"sock-shop\", direction=\"inbound\", srv_port!=\"4191\", pod=~\"user-[^-]+-[^-]+\"}[2m])) / sum(rate(response_total{namespace=\"sock-shop\", direction=\"inbound\", srv_port!=\"4191\", pod=~\"user-[^-]+-[^-]+\"}[2m]))", "refId": "A" }], "title": "User", "type": "stat" },

    { "datasource": { "type": "prometheus", "uid": "${datasource}" }, "fieldConfig": { "defaults": { "color": { "mode": "thresholds" }, "thresholds": { "steps": [{ "color": "red", "value": null }, { "color": "yellow", "value": 0.95 }, { "color": "green", "value": 0.99 }] }, "unit": "percentunit", "min": 0, "max": 1 }, "overrides": [] }, "gridPos": { "h": 4, "w": 3, "x": 21, "y": 1 }, "id": 208, "options": { "reduceOptions": { "calcs": ["lastNotNull"] }, "colorMode": "background" }, "targets": [{ "expr": "sum(rate(response_total{namespace=\"sock-shop\", direction=\"inbound\", srv_port!=\"4191\", pod=~\"queue-master-[^-]+-[^-]+\"}[2m])) / sum(rate(response_total{namespace=\"sock-shop\", direction=\"inbound\", srv_port!=\"4191\", pod=~\"queue-master-[^-]+-[^-]+\"}[2m]))", "refId": "A" }], "title": "Queue-master", "type": "stat" },

    {
      "datasource": { "type": "prometheus", "uid": "${datasource}" },
      "fieldConfig": { "defaults": { "color": { "mode": "palette-classic" }, "custom": { "lineWidth": 2, "fillOpacity": 10 }, "unit": "percentunit", "min": 0, "max": 1 }, "overrides": [] },
      "gridPos": { "h": 8, "w": 24, "x": 0, "y": 5 },
      "id": 209,
      "options": { "legend": { "calcs": ["mean", "min"], "displayMode": "table", "placement": "bottom" }, "tooltip": { "mode": "multi" } },
      "targets": [{
        "expr": "label_replace(\n  sum(rate(response_total{namespace=\"sock-shop\", direction=\"inbound\", srv_port!=\"4191\", classification=\"success\"}[2m])) by (pod)\n  /\n  sum(rate(response_total{namespace=\"sock-shop\", direction=\"inbound\", srv_port!=\"4191\"}[2m])) by (pod),\n  \"service\", \"$1\", \"pod\", \"^([a-z-]+)-[^-]+-[^-]+$\"\n)",
        "legendFormat": "{{service}}", "refId": "A"
      }],
      "title": "Success rate over time — all services",
      "type": "timeseries"
    },

    {
      "collapsed": false,
      "gridPos": { "h": 1, "w": 24, "x": 0, "y": 13 },
      "id": 210,
      "title": "Request Rate (RPS)",
      "type": "row"
    },
    {
      "datasource": { "type": "prometheus", "uid": "${datasource}" },
      "fieldConfig": { "defaults": { "color": { "mode": "palette-classic" }, "custom": { "lineWidth": 2, "fillOpacity": 10 }, "unit": "reqps" }, "overrides": [] },
      "gridPos": { "h": 8, "w": 24, "x": 0, "y": 14 },
      "id": 211,
      "options": { "legend": { "calcs": ["mean", "max"], "displayMode": "table", "placement": "bottom" }, "tooltip": { "mode": "multi" } },
      "targets": [{
        "expr": "label_replace(\n  sum(rate(request_total{namespace=\"sock-shop\", direction=\"inbound\", srv_port!=\"4191\"}[2m])) by (pod),\n  \"service\", \"$1\", \"pod\", \"^([a-z-]+)-[^-]+-[^-]+$\"\n)",
        "legendFormat": "{{service}}", "refId": "A"
      }],
      "title": "Requests per second — all services",
      "type": "timeseries"
    },

    {
      "collapsed": false,
      "gridPos": { "h": 1, "w": 24, "x": 0, "y": 22 },
      "id": 220,
      "title": "Latency (P50 / P95 / P99)",
      "type": "row"
    },
    {
      "datasource": { "type": "prometheus", "uid": "${datasource}" },
      "fieldConfig": { "defaults": { "color": { "mode": "palette-classic" }, "custom": { "lineWidth": 2, "fillOpacity": 10 }, "unit": "ms" }, "overrides": [] },
      "gridPos": { "h": 8, "w": 8, "x": 0, "y": 23 },
      "id": 221,
      "options": { "legend": { "calcs": ["mean", "max"], "displayMode": "table", "placement": "bottom" }, "tooltip": { "mode": "multi" } },
      "targets": [{
        "expr": "label_replace(\n  histogram_quantile(0.50, sum(rate(response_latency_ms_bucket{namespace=\"sock-shop\", direction=\"inbound\", srv_port!=\"4191\"}[2m])) by (le, pod)),\n  \"service\", \"$1\", \"pod\", \"^([a-z-]+)-[^-]+-[^-]+$\"\n)",
        "legendFormat": "{{service}}", "refId": "A"
      }],
      "title": "P50 latency — all services",
      "type": "timeseries"
    },
    {
      "datasource": { "type": "prometheus", "uid": "${datasource}" },
      "fieldConfig": { "defaults": { "color": { "mode": "palette-classic" }, "custom": { "lineWidth": 2, "fillOpacity": 10 }, "unit": "ms" }, "overrides": [] },
      "gridPos": { "h": 8, "w": 8, "x": 8, "y": 23 },
      "id": 222,
      "options": { "legend": { "calcs": ["mean", "max"], "displayMode": "table", "placement": "bottom" }, "tooltip": { "mode": "multi" } },
      "targets": [{
        "expr": "label_replace(\n  histogram_quantile(0.95, sum(rate(response_latency_ms_bucket{namespace=\"sock-shop\", direction=\"inbound\", srv_port!=\"4191\"}[2m])) by (le, pod)),\n  \"service\", \"$1\", \"pod\", \"^([a-z-]+)-[^-]+-[^-]+$\"\n)",
        "legendFormat": "{{service}}", "refId": "A"
      }],
      "title": "P95 latency — all services",
      "type": "timeseries"
    },
    {
      "datasource": { "type": "prometheus", "uid": "${datasource}" },
      "fieldConfig": { "defaults": { "color": { "mode": "palette-classic" }, "custom": { "lineWidth": 2, "fillOpacity": 10 }, "unit": "ms" }, "overrides": [] },
      "gridPos": { "h": 8, "w": 8, "x": 16, "y": 23 },
      "id": 223,
      "options": { "legend": { "calcs": ["mean", "max"], "displayMode": "table", "placement": "bottom" }, "tooltip": { "mode": "multi" } },
      "targets": [{
        "expr": "label_replace(\n  histogram_quantile(0.99, sum(rate(response_latency_ms_bucket{namespace=\"sock-shop\", direction=\"inbound\", srv_port!=\"4191\"}[2m])) by (le, pod)),\n  \"service\", \"$1\", \"pod\", \"^([a-z-]+)-[^-]+-[^-]+$\"\n)",
        "legendFormat": "{{service}}", "refId": "A"
      }],
      "title": "P99 latency — all services",
      "type": "timeseries"
    },

    {
      "collapsed": false,
      "gridPos": { "h": 1, "w": 24, "x": 0, "y": 31 },
      "id": 230,
      "title": "TCP Connections & Throughput",
      "type": "row"
    },
    {
      "datasource": { "type": "prometheus", "uid": "${datasource}" },
      "fieldConfig": { "defaults": { "color": { "mode": "palette-classic" }, "custom": { "lineWidth": 2, "fillOpacity": 10 }, "unit": "short" }, "overrides": [] },
      "gridPos": { "h": 8, "w": 8, "x": 0, "y": 32 },
      "id": 231,
      "options": { "legend": { "calcs": ["mean", "max"], "displayMode": "table", "placement": "bottom" }, "tooltip": { "mode": "multi" } },
      "targets": [{
        "expr": "label_replace(\n  sum(tcp_open_connections{namespace=\"sock-shop\", direction=\"inbound\"}) by (pod),\n  \"service\", \"$1\", \"pod\", \"^([a-z-]+)-[^-]+-[^-]+$\"\n)",
        "legendFormat": "{{service}}", "refId": "A"
      }],
      "title": "Open TCP connections — all services",
      "type": "timeseries"
    },
    {
      "datasource": { "type": "prometheus", "uid": "${datasource}" },
      "fieldConfig": { "defaults": { "color": { "mode": "palette-classic" }, "custom": { "lineWidth": 2, "fillOpacity": 10 }, "unit": "Bps" }, "overrides": [] },
      "gridPos": { "h": 8, "w": 8, "x": 8, "y": 32 },
      "id": 232,
      "options": { "legend": { "calcs": ["mean", "max"], "displayMode": "table", "placement": "bottom" }, "tooltip": { "mode": "multi" } },
      "targets": [{
        "expr": "label_replace(\n  sum(rate(tcp_read_bytes_total{namespace=\"sock-shop\", direction=\"inbound\"}[2m])) by (pod),\n  \"service\", \"$1\", \"pod\", \"^([a-z-]+)-[^-]+-[^-]+$\"\n)",
        "legendFormat": "{{service}}", "refId": "A"
      }],
      "title": "TCP bytes received — all services",
      "type": "timeseries"
    },
    {
      "datasource": { "type": "prometheus", "uid": "${datasource}" },
      "fieldConfig": { "defaults": { "color": { "mode": "palette-classic" }, "custom": { "lineWidth": 2, "fillOpacity": 10 }, "unit": "Bps" }, "overrides": [] },
      "gridPos": { "h": 8, "w": 8, "x": 16, "y": 32 },
      "id": 233,
      "options": { "legend": { "calcs": ["mean", "max"], "displayMode": "table", "placement": "bottom" }, "tooltip": { "mode": "multi" } },
      "targets": [{
        "expr": "label_replace(\n  sum(rate(tcp_write_bytes_total{namespace=\"sock-shop\", direction=\"inbound\"}[2m])) by (pod),\n  \"service\", \"$1\", \"pod\", \"^([a-z-]+)-[^-]+-[^-]+$\"\n)",
        "legendFormat": "{{service}}", "refId": "A"
      }],
      "title": "TCP bytes sent — all services",
      "type": "timeseries"
    },

    {
      "collapsed": false,
      "gridPos": { "h": 1, "w": 24, "x": 0, "y": 40 },
      "id": 240,
      "title": "Error Rate",
      "type": "row"
    },
    {
      "datasource": { "type": "prometheus", "uid": "${datasource}" },
      "fieldConfig": { "defaults": { "color": { "mode": "palette-classic" }, "custom": { "lineWidth": 2, "fillOpacity": 10 }, "unit": "percentunit", "min": 0 }, "overrides": [] },
      "gridPos": { "h": 8, "w": 24, "x": 0, "y": 41 },
      "id": 241,
      "options": { "legend": { "calcs": ["mean", "max"], "displayMode": "table", "placement": "bottom" }, "tooltip": { "mode": "multi" } },
      "targets": [{
        "expr": "label_replace(\n  sum(rate(response_total{namespace=\"sock-shop\", direction=\"inbound\", srv_port!=\"4191\", classification!=\"success\"}[2m])) by (pod)\n  /\n  sum(rate(response_total{namespace=\"sock-shop\", direction=\"inbound\", srv_port!=\"4191\"}[2m])) by (pod),\n  \"service\", \"$1\", \"pod\", \"^([a-z-]+)-[^-]+-[^-]+$\"\n)",
        "legendFormat": "{{service}}", "refId": "A"
      }],
      "title": "Error rate over time — all services",
      "type": "timeseries"
    }
  ],

  "refresh"= "30s",
  "schemaVersion"= 38,
  "tags"= ["sock-shop", "linkerd", "service-mesh"],
  "templating"= {
    "list": [
      {
        "current": {},
        "hide": 0,
        "includeAll": false,
        "name": "datasource",
        "options": [],
        "query": "prometheus",
        "refresh": 1,
        "type": "datasource",
        "label": "Datasource"
      }
    ]
  },
  "time"= { "from": "now-1h", "to": "now" },
  "timepicker"= {},
  "timezone"= "browser",
  "title"= "Sock Shop — Linkerd Golden Signals",
  "uid"= "sockshop-linkerd-golden",
  "version"= 1
}