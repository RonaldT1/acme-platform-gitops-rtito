# Day-19

## Runbook Summary

This runbook tracks the runtime security lab built on top of the existing EKS, Cilium, Istio Ambient, and Kyverno baseline.

### Scope

- install Falco `0.44.0` with chart `9.0.0`
- use the `modern_ebpf` driver
- add a custom rule for shell spawns in `bootcamp-prod`
- forward Falco events to Alertmanager with Falcosidekick
- install Tetragon `1.7.0`
- enforce a namespaced shell-blocking `TracingPolicyNamespaced`

### Validation Targets

- Falco DaemonSet healthy on every node
- Falco logs confirm `modern_ebpf`
- custom Falco rule is listed and loaded
- Falcosidekick posts alerts to Alertmanager
- Tetragon DaemonSet healthy on every node
- `block-shell-exec` exists only in namespace `bootcamp-prod`
- `kubectl exec ... /bin/sh` in `bootcamp-prod` exits with code `137`

### Residual Gaps

- This file is intentionally a runbook, not evidence.
- Exact outputs and screenshots still need to be added after the live cluster run.
