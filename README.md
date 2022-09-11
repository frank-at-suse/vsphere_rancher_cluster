# RKE2 Cluster with vSphere CPI/CSI & MetalLB
![Rancher](https://img.shields.io/badge/rancher-%230075A8.svg?style=for-the-badge&logo=rancher&logoColor=white) ![Terraform](https://img.shields.io/badge/terraform-%235835CC.svg?style=for-the-badge&logo=terraform&logoColor=white) 	![Kubernetes](https://img.shields.io/badge/kubernetes-%23326ce5.svg?style=for-the-badge&logo=kubernetes&logoColor=white)

## Reason for Being
This Terraform plan is for creating a multi-node CIS Benchmarked RKE2 cluster with vSphere CPI/CSI & MetalLB installed and configured.  RKE2's NGiNX Ingress Controller is also exposed as a LoadBalancer service to work in concert with MetalLB.  Along with those quality-of-life additions, this cluster plan takes the standard RKE2 security posture a couple of steps further by way of installing with CIS 1.6 Profile enabled, using Calico's Wireguard backend for encrypting pod-to-pod communication, & enforcing the use TLS 1.3 across Control Plane components.

There is a lot of HereDoc in the `rke_config` section of `cluster.tf` so that it's easier to see what's going on - you'll probably want to put this info in a template file to keep the plan a bit neater than what's seen here.

Some operating systems will run containerd within the "systemd" control group and the Kubelet within the "cgroupfs" control group - this plan passes to the Kubelet a `--cgroup-driver=systemd` argument to ensure that there will be only a single cgroup manager running - better aligining the cluster with upstream K8s reccomendations ( see: https://kubernetes.io/docs/setup/production-environment/container-runtimes/#cgroup-drivers).

## Environment Prerequisites 
- Functional Rancher Management Server with vSphere Cloud Credential
- vCenter >= 7.x and credentials with appropriate permissions (see https://rancher.com/docs/rancher/v2.6/en/cluster-provisioning/rke-clusters/node-pools/vsphere/creating-credentials)
- Virtual Machine Hardware Compatibility at Version >= 15
- Create the following in the files/ directory:

    | NAME | PURPOSE |
    | ------ | ------ |
    | .rancher-api-url | URL for Rancher Management Server
    | .rancher-bearer-token | API bearer token generated via Rancher UI
    | .ssh-public-key | SSH public key for additional OS user
    | .vsphere-passwd | Password associated with vSphere CPI/CSI credential

## Caveats
 - vSphere CSI volumes are **RWO only** unless using vSAN Datastore
 - Using Wireguard as CNI backend comes at a performance penalty (see https://projectcalico.docs.tigera.io/security/encrypt-cluster-pod-traffic)
 - MetalLB is configured in L2 mode, so **_ALL_** LoadBalancer service traffic goes **_only_** to the node that has the MetalLB VIP assigned, which is not suitable for production

## To Run
    > terraform apply

## Tested Versions

| SOFTWARE | VERSION | DOCS |
| ------ | ------ | ------ |
| MetalLB | 0.12.1 | https://metallb.universe.tf
| Rancher Server | 2.6.8 | https://rancher.com/docs/rancher/v2.6/en/overview
| Rancher Terraform Provider| 1.24.1 | https://registry.terraform.io/providers/rancher/rancher2/latest/docs
| RKE2 | 1.24.4+rke2r1 | https://docs.rke2.io
| Terraform | 1.2.7 | https://www.terraform.io/docs
| vSphere | 7.0.3 Build Build 20150588 | https://docs.vmware.com/en/VMware-vSphere/index.html
