# ADR-002: argocd for gitops

## status

accepted

## context

need a deployment mechanism for kubernetes manifests. options: manual kubectl apply, helm-only pipeline, flux, argocd, or ci-driven push deploys (e.g., github actions doing kubectl apply).

## decision

argocd with the app-of-apps pattern.

## rationale

manual kubectl apply doesn't scale and creates drift. ci-driven push deploys mean your cluster state depends on ci running successfully — if ci is down, you can't deploy (or worse, you can't roll back).

gitops — where the cluster pulls desired state from git — solves both problems. the cluster continuously reconciles toward what's in the repo. drift is auto-corrected. rollback is a git revert.

argocd over flux because:
- the web ui is genuinely useful for understanding what's deployed and what's out of sync
- the app-of-apps pattern lets us point argocd at a directory and it recursively discovers everything
- better visualization of dependency graphs and sync status
- flux is great too, but argocd's ui wins for a solo operator who wants to glance at a dashboard

the app-of-apps pattern means we have one root Application that points at kubernetes/. argocd discovers all manifests recursively. adding a new app is just committing yaml to the right directory.

## consequences

- all deployments go through git — no more "just kubectl apply this real quick"
- argocd itself needs to be bootstrapped manually (chicken-and-egg)
- web ui provides visibility into cluster state
- sync policies handle auto-pruning of deleted resources
