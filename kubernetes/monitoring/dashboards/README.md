# grafana dashboards

reference dashboards for the homelab cluster. JSON, importable directly.

## what's here

- `sre-golden-signals.json` — the four golden signals (latency, traffic, errors, saturation) for ingress-fronted workloads. expects `nginx_ingress_controller_*` metrics + cAdvisor + kube-state-metrics, all of which the kube-prometheus-stack helm chart wires up by default.

## importing

### option 1: grafana UI

1. open grafana → **Dashboards** → **New** → **Import**
2. paste the JSON or upload the file
3. when prompted, pick your Prometheus datasource (the dashboard uses `${DS_PROMETHEUS}` so it'll ask)
4. save

### option 2: configmap + sidecar (recommended)

if you installed grafana via the helm chart in this repo, the sidecar is enabled and watches for ConfigMaps with the label `grafana_dashboard=1`:

```bash
kubectl create configmap sre-golden-signals \
  --from-file=sre-golden-signals.json \
  -n monitoring \
  --dry-run=client -o yaml \
  | kubectl label -f - --local -o yaml grafana_dashboard=1 \
  | kubectl apply -f -
```

the sidecar will pick it up within ~30s and the dashboard will appear under the **Dashboards** list. delete the ConfigMap to remove it.

### option 3: dashboards-as-code

if you're managing dashboards via terraform / argocd / grafana-operator, just point your config at the JSON file in this directory and let your tooling reconcile it.

## variables

both dashboards use:

- `$DS_PROMETHEUS` — prometheus datasource (auto-prompted on import)
- `$namespace` — multi-select, defaults to all namespaces

## notes

- the dashboards assume the ingress-nginx controller is the source of HTTP traffic metrics. if you use traefik (k3s default), swap the `nginx_ingress_controller_*` queries for `traefik_service_*` equivalents — the panel structure stays the same.
- saturation panels rely on workloads having CPU/memory requests + limits set. workloads without them will show as `NaN` and that's expected.
