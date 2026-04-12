# homelab-infra

this is how i run my stuff. opinionated, deliberately simple, built for one tired human operating at 3am. your mileage may vary.

## what is this

reference configs for a single-node-ish homelab setup. not a tutorial, not a framework — just the actual files i'd use to stand up infrastructure from scratch.

the stack:

- **k3s** — single cluster, few nodes. full k8s is overkill for a homelab, k3s gives you 90% of the api surface with 10% of the operator burden
- **argocd** — gitops, pull-based deploys. push a manifest, argocd picks it up. if it's not in git it doesn't exist
- **prometheus + grafana** — monitoring. you will forget what's running if you don't have dashboards. set it up early
- **external-secrets** — secrets management. no more yaml-encoded base64 strings in your repo
- **terraform** — cloud-adjacent bits. vpc, dns, whatever needs an api call
- **ansible** — node bootstrap. ssh hardening, package installs, the boring stuff that makes nodes not terrible

## repo layout

```
terraform/       — hcl modules and environment configs
kubernetes/      — manifests, helm values, argocd apps
ansible/         — playbooks and roles for node setup
ci/              — github actions for linting and planning
docs/            — architecture notes and decision records
```

## table of contents

- [terraform modules](./terraform/)
- [kubernetes manifests](./kubernetes/)
- [ansible playbooks](./ansible/)
- [ci/cd workflows](./ci/)
- [architecture docs](./docs/)

## disclaimer

these are reference configs. secrets are placeholders. resource limits are tuned for my setup. don't blindly copy-paste this into production and then wonder why things are on fire.

if you're here from my resume — hi. this is how i think about infrastructure. ask me about any of it.
