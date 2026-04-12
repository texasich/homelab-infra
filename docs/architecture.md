# architecture overview

## the big picture

```
                    ┌─────────────┐
                    │   github    │
                    │  (this repo)│
                    └──────┬──────┘
                           │ git pull
                    ┌──────▼──────┐
                    │   argocd    │
                    │  (gitops)   │
                    └──────┬──────┘
                           │ sync
              ┌────────────┼────────────┐
              │            │            │
        ┌─────▼─────┐ ┌───▼───┐ ┌─────▼─────┐
        │ monitoring│ │  apps │ │  system   │
        │ namespace │ │  ns   │ │  configs  │
        └───────────┘ └───────┘ └───────────┘
              │
        ┌─────▼─────┐
        │prometheus +│
        │  grafana   │
        └───────────┘
```

## components

**infrastructure layer** — terraform provisions the vpc, subnets, security groups, and ec2 instances. nothing fancy. the vpc module wraps the standard terraform-aws-modules/vpc with sane defaults. k3s-cluster module handles the actual compute.

**node bootstrap** — ansible runs once per node to install packages, harden ssh, configure sysctl for kubernetes, and disable swap. after this, k3s handles the rest.

**cluster** — k3s, not full k8s. one server node (etcd embedded), two agent nodes. traefik disabled because i manage ingress separately. servicelb disabled because we use metallb or cloud lb.

**gitops** — argocd watches this repo. push a manifest, argocd syncs it. the root app pattern means argocd recursively syncs everything under kubernetes/. no manual kubectl apply in steady state.

**monitoring** — prometheus scrapes metrics, grafana displays them. 15-day retention, 30s scrape interval. community dashboards for node-exporter and cluster overview.

**ci** — github actions runs terraform fmt/validate/plan on PRs touching terraform/, and kubeconform + yamllint on PRs touching kubernetes/. catches the dumb mistakes before they hit the cluster.

## design principles

1. **boring is good** — no service mesh, no custom operators, no cutting-edge alpha features. proven tools, stable versions.
2. **one operator** — this is built for one person running things. no multi-tenancy, no RBAC complexity beyond the defaults.
3. **git is the source of truth** — if it's not in the repo, it doesn't exist. no snowflake configs applied by hand.
4. **resource limits everywhere** — every pod gets requests and limits. no unbounded resource consumption.
5. **secure defaults** — ssh hardened, pods run as non-root where possible, read-only root filesystems.
