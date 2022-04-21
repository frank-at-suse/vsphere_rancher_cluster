# RKE2 Cluster with vSphere CPI/CSI & MetalLB
![Rancher](https://img.shields.io/badge/rancher-%230075A8.svg?style=for-the-badge&logo=rancher&logoColor=white) ![Ubuntu](https://img.shields.io/badge/Ubuntu-E95420?style=for-the-badge&logo=ubuntu&logoColor=white) ![Terraform](https://img.shields.io/badge/terraform-%235835CC.svg?style=for-the-badge&logo=terraform&logoColor=white) 	![Kubernetes](https://img.shields.io/badge/kubernetes-%23326ce5.svg?style=for-the-badge&logo=kubernetes&logoColor=white)

## Reason for Being
This Terraform plan is for creating a multi-node RKE2 cluster with vSphere CPI/CSI & MetalLB already installed and configured.  RKE2's NGiNX Ingress Controller is also set as a LoadBalancer service to work in concert with MetalLB.  Along with those quality-of-life additions, this cluster plan takes the standard RKE2 security posture a couple of steps further by way of installing with CIS 1.5 Profile enabled as well as using Wireguard for pod-to-pod networking.

## Environment Prerequisites 
- Functional Rancher Management Server with vSphere Cloud Credential
- vCenter >= 7.x and credentials with appropriate permissions (see https://rancher.com/docs/rancher/v2.6/en/cluster-provisioning/rke-clusters/node-pools/vsphere/creating-credentials)
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
    > terraform apply -parallelism=1 
Parallelism needs to be forced to 1 for this plan (Terraform default is 10) or else the Helm catalogs will encounter HTTP 500 & "resource not found" errors and the plan will fail.  If you still encounter any Helm/catalog errors during apply, simply re-running the plan is enough to resolve them.

## Tested Versions

| SOFTWARE | VERSION | DOCS |
| ------ | ------ | ------ |
| MetalLB | 0.12.1 | https://metallb.universe.tf
| Rancher Server | 2.6.4, 2.6.5-rc1 | https://rancher.com/docs/rancher/v2.6/en/overview
| Rancher Terraform Provider| 1.23.0 | https://registry.terraform.io/providers/rancher/rancher2/latest/docs
| RKE2 | 1.22.7+rke2r2, 1.23.4+rke2r2 | https://docs.rke2.io
| Terraform | 1.1.8 | https://www.terraform.io/docs
| Ubuntu | 20.04 LTS Cloud Image | https://ubuntu.com/server/docs/cloud-images/introduction
| vSphere | 7.0.3 Build 19480866 | https://docs.vmware.com/en/VMware-vSphere/index.html
| vSphere CPI | 1.2.101 | https://github.com/rancher/rke2-charts/tree/main/charts/rancher-vsphere-cpi/rancher-vsphere-cpi
| vSphere CSI | 2.5.1-rancher101 | https://github.com/rancher/rke2-charts/tree/main/charts/rancher-vsphere-csi/rancher-vsphere-csi
