# RKE2 Cluster with vSphere CPI/CSI & MetalLB
![Rancher](https://img.shields.io/badge/rancher-%230075A8.svg?style=for-the-badge&logo=rancher&logoColor=white) ![Terraform](https://img.shields.io/badge/terraform-%235835CC.svg?style=for-the-badge&logo=terraform&logoColor=white) 	![Kubernetes](https://img.shields.io/badge/kubernetes-%23326ce5.svg?style=for-the-badge&logo=kubernetes&logoColor=white)

## Reason for Being
This Terraform plan is for creating a multi-node RKE2 cluster with vSphere CPI/CSI & MetalLB already installed and configured.  RKE2's NGiNX Ingress Controller is also set as a LoadBalancer service to work in concert with MetalLB.  Along with those quality-of-life additions, this cluster plan takes the standard RKE2 security posture a couple of steps further by way of installing with CIS 1.6 Profile enabled, using Calico's Wireguard backend for encrypting pod-to-pod communication, & enforcing the use TLS 1.3 across Control Plane components.

There is a lot of HereDoc in the "rke_config" section of cluster.tf so that it's easier to see what's going on - you'll probably want to put this info in a template file to keep the plan a bit neater than what's seen here.

A default installation of RKE2 via Rancher Server will run containerd within the "systemd" control group and the Kubelet within the "cgroupfs" control group - this plan passes to the Kubelet a "--cgroup-driver=systemd" argument so that there is only a single cgroup manager running - better aligining the cluster with upstream K8S reccomendations ( see: https://kubernetes.io/docs/setup/production-environment/container-runtimes/#cgroup-drivers).

## Environment Prerequisites 
- Functional Rancher Management Server with vSphere Cloud Credential
- vCenter >= 7.x and credentials with appropriate permissions (see https://rancher.com/docs/rancher/v2.6/en/cluster-provisioning/rke-clusters/node-pools/vsphere/creating-credentials)
- Virtual Machine Hardware Compatibility at Version >= 15
- Create the following in the files/ directory:

    | NAME | PURPOSE |
    | ------ | ------ |
    | .rancher-access-key | API access key generated via Rancher UI |
    | .rancher-api-url | URL for Rancher Management Server |
    | .rancher-secret-key | API secret key generated via Rancher UI |
    | .ssh-public-key | SSH public key for additional OS user |
    | .vsphere-passwd | Password associated with vSphere user |

## Caveats
 - vSphere CSI volumes are **RWO only** if not using vSAN Datastore
 - Using Wireguard as CNI backend comes at a performance penalty (see https://projectcalico.docs.tigera.io/security/encrypt-cluster-pod-traffic)

## To Run
    > terraform apply

## Tested Versions

| SOFTWARE | VERSION | DOCS |
| ------ | ------ | ------ |
| MetalLB | 0.12.1 | https://metallb.universe.tf
| Rancher Server | 2.6.5 | https://rancher.com/docs/rancher/v2.6/en/overview
| Rancher Terraform Provider| 1.24.0 | https://registry.terraform.io/providers/rancher/rancher2/latest/docs
| RKE2 | 1.23.6+rke2r2, 1.23.7+rke2r2 | https://docs.rke2.io
| Terraform | 1.2.1 | https://www.terraform.io/docs
| Ubuntu | 20.04 LTS Cloud Image | https://ubuntu.com/server/docs/cloud-images/introduction
| SLES 15 | JeOS (Just Enough OS) Service Pack 3 | https://www.suse.com/download/sles/
| vSphere | 7.0.3 Build 19480866 | https://docs.vmware.com/en/VMware-vSphere/index.html
