# homelab-infra

this is how i run my stuff. opinionated, deliberately simple, built for one tired human operating at 3am. your mileage may vary.

## what is this

reference configs for a single-node-ish homelab setup. not a tutorial, not a framework — just the actual files i'd use to stand up infrastructure from scratch.

the stack:

- **k3s** — single cluster, few nodes. full k8s is overkill for a homelab ([why?](./docs/decisions/001-why-k3s-not-k8s.md))
- **argocd** — gitops, pull-based deploys ([why?](./docs/decisions/002-argocd-for-gitops.md))
- **prometheus + grafana** — monitoring, with [alerting rules](./kubernetes/monitoring/alerting-rules.yaml) and [runbooks](./docs/runbooks/) so the alerts actually mean something at 3am ([why prometheus, not datadog?](./docs/decisions/003-prometheus-vs-datadog.md))
- **external-secrets** — secrets management (not yet implemented, placeholder)
- **terraform** — cloud-adjacent bits. vpc, dns, whatever needs an api call
- **ansible** — node bootstrap. ssh hardening, package installs, the boring stuff

## repo layout

```
terraform/
  modules/vpc/         — vpc with sensible defaults
  modules/k3s-cluster/ — ec2-based k3s cluster
  environments/homelab/— wiring it all together

kubernetes/
  base/                — namespaces, storage classes
  argocd/              — argocd install + root app
  monitoring/          — prometheus + grafana helm values
                        + alerting rules + grafana dashboards
  apps/sample-app/     — example deployment with probes

ansible/
  playbooks/           — bootstrap, ssh hardening, monitoring
  roles/common/        — shared tasks for all nodes

ci/github-actions/     — terraform plan + k8s lint

docs/
  architecture.md      — how it all fits together
  decisions/           — ADRs for key choices
  runbooks/            — what to do when an alert fires
```

## table of contents

- [architecture overview](./docs/architecture.md)
- terraform
  - [vpc module](./terraform/modules/vpc/)
  - [k3s-cluster module](./terraform/modules/k3s-cluster/)
  - [homelab environment](./terraform/environments/homelab/)
- kubernetes
  - [base manifests](./kubernetes/base/)
  - [argocd setup](./kubernetes/argocd/)
  - [monitoring](./kubernetes/monitoring/)
    - [alerting rules](./kubernetes/monitoring/alerting-rules.yaml)
    - [grafana dashboards](./kubernetes/monitoring/dashboards/)
  - [sample app](./kubernetes/apps/sample-app/)
- ansible
  - [bootstrap playbook](./ansible/playbooks/bootstrap-node.yml)
  - [ssh hardening](./ansible/playbooks/harden-ssh.yml)
  - [install monitoring (node_exporter)](./ansible/playbooks/install-monitoring.yml)
- ci/cd
  - [terraform plan](./ci/github-actions/terraform-plan.yml)
  - [k8s lint](./ci/github-actions/k8s-lint.yml)
- decisions
  - [why k3s](./docs/decisions/001-why-k3s-not-k8s.md)
  - [why argocd](./docs/decisions/002-argocd-for-gitops.md)
  - [prometheus vs datadog](./docs/decisions/003-prometheus-vs-datadog.md)
- runbooks
  - [high cpu throttling](./docs/runbooks/high-cpu-throttling.md)
  - [pod crashloopbackoff](./docs/runbooks/pod-crashloop.md)

## disclaimer

these are reference configs. secrets are placeholders. resource limits are tuned for my setup. don't blindly copy-paste this into production and then wonder why things are on fire.

if you're here from my resume — hi. this is how i think about infrastructure. ask me about any of it.
