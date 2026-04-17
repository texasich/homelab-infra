# ADR-003: prometheus + grafana over datadog

## status

accepted

## context

needed observability for the homelab cluster — metrics, dashboards, alerting. realistic options were a self-hosted prometheus + grafana stack vs a SaaS like datadog (or new relic, honeycomb, grafana cloud).

## decision

prometheus + grafana, self-hosted in the cluster via the kube-prometheus-stack helm chart.

## rationale

datadog is genuinely excellent — agent installs in five minutes, dashboards out of the box, the APM and log products are best-in-class. for a small team that wants to stop thinking about monitoring, it's the right answer.

it's also expensive in a way that doesn't make sense for a homelab. host-based pricing means the bill scales with how many nodes i run, custom metrics are billed separately, log retention adds up, and the "starter" tiers don't include the features the screenshots are sold on. a homelab with three nodes and a handful of services would burn through the free tier in days and then run a bill that's larger than the hardware it's monitoring.

prometheus is the opposite tradeoff: zero marginal cost, full ownership of the data, but i pay in operational time. retention is bounded by my disk. PromQL takes real practice. alerting requires writing rules by hand. the grafana side requires building or importing dashboards and keeping them current.

for a homelab — explicitly a learning environment where operating the stack IS the point — that's a feature, not a bug. the same skills transfer directly to most production environments i'd work in, where prometheus is the de facto standard. datadog skills mostly transfer to other datadog deployments.

## consequences

- no monthly bill; storage is bounded by local disk
- i own the operational burden: upgrades, retention tuning, alert hygiene
- skills i build here are portable to any prometheus-based environment
- if the cluster is down, monitoring is down — fine for a homelab, not fine for prod
- if i ever want long-term storage or a global view across clusters, the path is thanos / mimir / grafana cloud, not a rewrite
