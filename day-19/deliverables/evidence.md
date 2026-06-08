# Day-19

## Verified Results

- Kernel pre-check succeeded on all four nodes.
  - OS image: `Amazon Linux 2023.11.20260526`
  - Kernel: `6.1.172-216.329.amzn2023.x86_64`
  - This was sufficient for Falco `modern_ebpf`.

- Falco installed successfully.
  - `kubectl -n falco get ds falco`
  - Result: `DESIRED=4 CURRENT=4 READY=4 UP-TO-DATE=4 AVAILABLE=4`

- Falco confirmed the modern eBPF driver path.
  - `kubectl -n falco logs ds/falco --tail=200 | grep -iE "modern|driver|BPF"`
  - Result included: `Opening 'syscall' source with modern BPF probe.`

- Tetragon installed successfully.
  - `kubectl -n tetragon get ds tetragon`
  - Result: `DESIRED=4 CURRENT=4 READY=4 UP-TO-DATE=4 AVAILABLE=4`

- The Tetragon policy was applied only in the intended namespace.
  - `kubectl -n bootcamp-prod get tracingpolicynamespaced`
  - Result included: `block-shell-exec`

- Tetragon enforcement was proven.
  - `kubectl -n bootcamp-prod exec -it $POD -- /bin/sh`
  - Result: `command terminated with exit code 137`

- Scope control was proven outside `bootcamp-prod`.
  - `kubectl run shell-test -n default --rm -it --image=busybox -- sh`
  - Result: interactive shell opened successfully in `default`

## Falco Detection Evidence

- Falco did detect shell execution inside `bootcamp-prod`.
  - Evidence came from Falco's built-in rule, not the intended custom rule.
  - Relevant log result:
    - `rule":"Terminal shell in container"`
    - `k8s_ns_name":"bootcamp-prod"`
    - `proc.name":"sh"`
    - `proc.exepath":"/bin/busybox"`

- Screenshot captured:
  - `FalcoRuleWorking`

## What Happened During Testing

- The original custom Falco rule did not work on the first attempt because the custom rules `ConfigMap` was created but not mounted into the Falco DaemonSet.
- After fixing the mount, Falco rejected the first version of the custom rule because the condition failed to compile.
- After simplifying the rule, the custom rules file loaded successfully:
  - `/etc/falco/rules.d/bootcamp-shell.yaml | schema validation: ok`
- Even with the simplified rule loaded, the expected custom alert text was not observed in practice.
- When Tetragon enforcement was enabled, it killed `/bin/sh` fast enough that Falco did not reliably emit the intended shell alert for that same attempt.
- When the namespaced Tetragon policy was temporarily removed, Falco successfully detected the shell via the built-in rule `Terminal shell in container`.

## Alertmanager / Falcosidekick Status

- Alertmanager and the `AlertmanagerConfig` resource were installed successfully in namespace `observability`.
- Falcosidekick was deployed and running.
- However, this run did not produce conclusive evidence that Falcosidekick published the Falco event to Alertmanager:
  - `kubectl -n falco logs deploy/falco-falcosidekick --tail=30 | grep -i alertmanager` did not show a `Post OK (200)` result.
  - `amtool` queries for the expected alert names returned no active alerts at query time.

## Screenshots Worth Keeping

- Falco detection:
  - `FalcoRuleWorking`
- Tetragon enforcement:
  - screenshot showing `command terminated with exit code 137`
- Verification block:
  - Falco DaemonSet healthy
  - modern BPF probe message
  - Tetragon DaemonSet healthy
  - `block-shell-exec` visible in `bootcamp-prod`
  - successful shell in `default` namespace

## Summary

- Falco was installed and operational with the modern eBPF probe.
- Tetragon was installed and operational with namespaced enforcement.
- Runtime detection was demonstrated with Falco.
- Runtime enforcement was demonstrated with Tetragon.
- The exact custom Falco alert text and a clean Alertmanager delivery proof were not fully demonstrated in this run.
