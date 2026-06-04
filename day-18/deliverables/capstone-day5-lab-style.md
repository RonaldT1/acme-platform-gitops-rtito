# Day-17

## Lab Walkthrough

The Day 17 lab added Istio Ambient mode to an EKS cluster that already had Cilium chained mode working from the previous lab baseline.

The main technical work was:

- rename the inherited environment from `day16` to `day17`
- restore infra and base controllers after `terraform destroy`
- keep the app on port `3000` and add `/api/version`
- install Istio with Helm instead of `istioctl install`
- resolve the `ztunnel` authentication issue by aligning cluster names
- create the waypoint without `istioctl`
- validate mTLS, traffic split, and fault injection

The most important troubleshooting result was the `ztunnel` fix. `ztunnel` identified itself as cluster `bootcamp-eks`, but `istiod` still treated the local cluster as `Kubernetes`. Once `global.multiCluster.clusterName: bootcamp-eks` was added to `istiod-values.yaml`, all `ztunnel` pods became ready.

Traffic validation ended with these real outcomes:

- weighted routing reached both app versions
- a non-mesh client was rejected by `STRICT` mTLS
- delay injection was visible in waypoint logs even though the shell timer did not increment `slow_2s`
