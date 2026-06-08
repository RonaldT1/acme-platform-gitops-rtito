# Day-19

## High-Level Steps

1. Confirm the existing EKS node kernel is `>= 5.8` so Falco can use `modern_ebpf`.
2. Add the Falco Helm values file:
   - `exercises/aws-bootcamp/infra/falco-values.yaml`
3. Install Falco chart `9.0.0` in namespace `falco`.
4. Create a ConfigMap with the custom runtime rule:
   - `exercises/aws-bootcamp/k8s/falco/rules/bootcamp-shell-in-container.yaml`
5. Mount the custom rules into the Falco DaemonSet with:
   - `exercises/aws-bootcamp/infra/falco-values-extra.yaml`
6. Apply the Alertmanager route for Falco alerts:
   - `exercises/aws-bootcamp/k8s/observability/alertmanager-route-falco.yaml`
7. Add the Tetragon Helm values file:
   - `exercises/aws-bootcamp/infra/tetragon-values.yaml`
8. Install Tetragon chart `1.7.0` in namespace `tetragon`.
9. Apply the namespaced enforcement policy:
   - `exercises/aws-bootcamp/k8s/tetragon/tp-block-shell.yaml`
10. Verify the runtime flow end to end:
   - `kubectl exec` shell attempt in `bootcamp-prod` is killed with exit code `137`
   - Falco logs show `Shell spawned in bootcamp-prod container`
   - Falcosidekick posts to Alertmanager
   - Tetragon exports the matching process exec and kill event

## Risks To Watch

- Falco fails on older kernels when `modern_ebpf` is not supported.
- A cluster-scoped `TracingPolicy` would be dangerous here; the lab must use `TracingPolicyNamespaced`.
- `enablePolicyFilter` must remain enabled in Tetragon or the namespaced policy will not apply.
- The custom Falco rule may need parent-process tuning if `kubectl exec` ancestry differs from the expected runtime path.
