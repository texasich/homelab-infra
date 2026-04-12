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

## notes

- prometheus retention is 15 days / 10GB, whichever comes first
- grafana has a couple of community dashboards pre-configured
- default grafana password is `changeme-please` — change it
- scrape interval is 30s because this is a homelab, not a trading platform
