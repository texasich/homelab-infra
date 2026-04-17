# runbook: ContainerCPUThrottlingHigh

**alert:** `ContainerCPUThrottlingHigh`
**severity:** ticket
**fires when:** a container has been CPU-throttled for >25% of CFS periods over the last 5 minutes, sustained for 15 minutes.

## what this means

the container is hitting its CPU limit and the kernel is throttling it. the workload runs slower than its code thinks it does — latency goes up, queues back up, downstream services see timeouts. the pod is *not* OOMKilled and won't restart on its own, so the symptom is degraded performance, not an outage.

## detection

prometheus alert. you can also reproduce the query in grafana / `promtool`:

```promql
sum by (namespace, pod, container) (
  rate(container_cpu_cfs_throttled_seconds_total{container!="", container!="POD"}[5m])
)
/
sum by (namespace, pod, container) (
  rate(container_cpu_cfs_periods_total{container!="", container!="POD"}[5m])
)
```

values close to `1.0` mean the container is being throttled in nearly every CFS period. anything sustained above `0.25` is worth investigating.

## investigate

1. **identify the pod and container** — alert label has it: `{{ namespace }}/{{ pod }}` container `{{ container }}`.

2. **check the configured limit and current usage:**

   ```bash
   kubectl -n <ns> get pod <pod> -o jsonpath='{.spec.containers[?(@.name=="<container>")].resources}' | jq
   kubectl -n <ns> top pod <pod> --containers
   ```

3. **check if this is new behavior or chronic.** in grafana, look at the throttling ratio over the last 24h. spike vs baseline tells you whether something changed (deploy, traffic shift) or this has always been undersized.

4. **correlate with latency / error rate** on the golden signals dashboard. throttling that doesn't move user-visible metrics is lower priority.

5. **check for noisy neighbor.** node-level CPU saturation:

   ```bash
   kubectl top node
   ```

   if the node is also pegged, the limit isn't the only problem — workloads are competing for CPU shares.

## remediate

- **most common fix:** raise the CPU limit. start with +50%, observe, iterate. update the deployment/helm values, don't `kubectl edit` in place.
- **better fix when traffic-driven:** add an HPA on CPU utilization so pods scale out before they get throttled.
- **if this is a known tight container** (sidecars, exporters), consider removing the limit entirely — kubernetes scheduling will still respect requests, and you avoid throttle latency.
- **if the workload is genuinely doing too much work**, profile it. throttling is a symptom; an inefficient hot loop is the cause.

## escalate / postmortem

if remediation doesn't bring throttling below 10% within an hour of the change rolling out, escalate. if the alert fires on a workload that just shipped, treat the deploy as suspect and consider a rollback while you investigate.

## related

- alert definition: `kubernetes/monitoring/alerting-rules.yaml`
- dashboard: SRE — Golden Signals (saturation row)
