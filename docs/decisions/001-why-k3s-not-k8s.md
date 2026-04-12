# ADR-001: k3s instead of full kubernetes

## status

accepted

## context

need a kubernetes distribution for a homelab setup running on 2-3 nodes. options are full kubeadm-managed k8s, k3s, microk8s, or kind/minikube.

## decision

k3s.

## rationale

full kubeadm k8s has a lot of moving parts — separate etcd cluster, multiple control plane components to manage, certificate rotation headaches, and upgrades that require careful orchestration. for a homelab with one operator, that's unnecessary operational burden.

k3s gives us the kubernetes api surface we need (it passes conformance tests) but bundles everything into a single binary. etcd is replaced with embedded sqlite or embedded etcd (we use embedded etcd for HA-readiness). upgrades are literally replacing one binary.

the tradeoffs:
- some k8s features are stripped (cloud controller manager, in-tree storage drivers) — we don't need them
- the community is smaller than mainline k8s — but large enough, and rancher/suse backs it
- debugging can be slightly different since components are bundled — acceptable for a homelab

microk8s was considered but snap-based distribution adds a layer of indirection i don't want to troubleshoot at 3am. kind/minikube are dev tools, not production-shaped.

## consequences

- simpler upgrades and operations
- less memory overhead on nodes
- some cloud-provider integrations need manual setup
- need to install additional components (ingress controller, etc) that full k8s might bundle
