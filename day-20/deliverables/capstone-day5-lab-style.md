# Day-19

## Lab Walkthrough

This lab adds runtime detection and enforcement for shell execution inside production pods.

The main technical work is:

- verify the node kernel is new enough for Falco `modern_ebpf`
- install Falco and Falcosidekick
- add a custom Falco rule for shell execution in `bootcamp-prod`
- route Falco events into Alertmanager
- install Tetragon with policy filtering enabled
- apply a namespaced `TracingPolicyNamespaced` that kills `/bin/sh` and `/bin/bash`
- prove detection and enforcement with a controlled `kubectl exec`

The main pitfalls to validate during execution are:

- Falco falling back or failing because `modern_ebpf` is unsupported
- the custom rule not matching because of parent-process assumptions
- applying a cluster-wide Tetragon policy by mistake
- forgetting that `enablePolicyFilter` must stay enabled

The intended final validation is:

- Falco emits `Shell spawned in bootcamp-prod container`
- Alertmanager receives the Falco alert through Falcosidekick
- Tetragon kills the shell before it runs and the exec returns `137`
