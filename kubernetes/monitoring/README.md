# monitoring

prometheus + grafana via helm charts.

## install

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

helm install prometheus prometheus-community/kube-prometheus-stack \
  -n monitoring -f prometheus-values.yaml

helm install grafana grafana/grafana \
  -n monitoring -f grafana-values.yaml
```

## alerting + dashboards

- alerting rules live in [`alerting-rules.yaml`](./alerting-rules.yaml) — apply after the helm install
- the SRE golden-signals dashboard is in [`dashboards/`](./dashboards/) with import instructions

## notes

- prometheus retention is 15 days / 10GB, whichever comes first
- grafana has a couple of community dashboards pre-configured
- default grafana password is `changeme-please` — change it
- scrape interval is 30s because this is a homelab, not a trading platform
