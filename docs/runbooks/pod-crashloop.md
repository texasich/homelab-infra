# runbook: PodCrashLoopBackOff

**alert:** `PodCrashLoopBackOff`
**severity:** page
**fires when:** a container in a pod has been in `CrashLoopBackOff` for >10 minutes.

## what this means

a container has crashed, kubelet restarted it, it crashed again. after enough cycles the kubelet starts backing off (10s, 20s, 40s … capped at 5m). the workload is effectively down for that pod's slot in the deployment.

if this is a single replica, the service is offline. if it's one of many, capacity is degraded and the bad pod is poisoning rollouts.

## investigate

1. **identify the pod and find recent state:**

   ```bash
   kubectl -n <ns> get pods -o wide
   kubectl -n <ns> describe pod <pod>
   ```

   in `describe`, scroll to the `State` / `Last State` block. note the `Exit Code` and `Reason`.

2. **read the logs from the crashed container, not the live one:**

   ```bash
   kubectl -n <ns> logs <pod> -c <container> --previous
   ```

   `--previous` is the one that matters — without it you're reading the live container that's about to die again.

3. **map the exit code to a likely cause:**

   | code  | meaning                                 |
   |-------|-----------------------------------------|
   | 0     | clean exit — process not designed to be long-lived (wrong command? init container masquerading as a workload?) |
   | 1     | generic application error — read the logs |
   | 137   | SIGKILL — almost always OOMKilled (confirm in `describe`: `Reason: OOMKilled`) |
   | 139   | SIGSEGV — segfault, native crash |
   | 143   | SIGTERM — usually a shutdown timeout, not a crash |

4. **check recent events on the pod and workload:**

   ```bash
   kubectl -n <ns> get events --sort-by=.lastTimestamp | tail -20
   ```

## common causes & fixes

- **OOMKilled (exit 137):** memory limit too low or a memory leak. raise the limit, then profile if the new limit also fills up. don't just keep raising.
- **missing config / secret:** `describe` shows `CreateContainerConfigError` or env var missing in logs. check the `ConfigMap` / `Secret` exists in the right namespace and the pod's service account can read it.
- **failed liveness probe:** logs show the app started fine but kubelet kills it. compare `livenessProbe.initialDelaySeconds` against actual cold-start time. tune up, or add a `startupProbe`.
- **image pull errors:** `ErrImagePull` / `ImagePullBackOff` in `describe`. check tag exists, registry creds are correct (`imagePullSecrets`), and the node can reach the registry.
- **bad command / args:** exit 0 or 127. usually a recent change to `command:` or `args:` in the manifest. `git diff` against the last working revision.

## remediate

- if a recent deploy introduced this, **roll back first, debug second**:

  ```bash
  kubectl -n <ns> rollout undo deployment/<name>
  kubectl -n <ns> rollout status deployment/<name>
  ```

- if a config/secret is the cause, fix the resource — the pod will pick it up on its next restart cycle (no need to delete the pod, but you can to speed it up).
- if you needed to raise a limit, push the change through the normal manifest path (kustomize / helm / argocd), not `kubectl edit`. an `edit` will get reconciled away within seconds.

## escalate

if rollback doesn't recover the workload, or if the crash is happening on a workload that hasn't changed (suggesting a node, network, or dependency problem), escalate. before paging anyone, capture: the pod yaml, `--previous` logs, recent events, and what changed in the last 24h.

## related

- alert definition: `kubernetes/monitoring/alerting-rules.yaml`
- adjacent alert: `PodRestartingFrequently` — pre-CrashLoopBackOff signal
