# RKE2 Cluster with vSphere CPI/CSI & kube-vip

![Rancher](https://img.shields.io/badge/rancher-%230075A8.svg?style=for-the-badge&logo=rancher&logoColor=white) ![Terraform](https://img.shields.io/badge/terraform-%235835CC.svg?style=for-the-badge&logo=terraform&logoColor=white) ![Kubernetes](https://img.shields.io/badge/kubernetes-%23326ce5.svg?style=for-the-badge&logo=kubernetes&logoColor=white)

## Reason for Being

This Terraform plan is for creating a multi-node CIS Benchmarked RKE2 cluster with vSphere CPI/CSI & kube-vip installed and configured.  RKE2's NGiNX Ingress Controller is also exposed as a LoadBalancer service to work in concert with kube-vip.  Along with those quality-of-life additions, this cluster plan takes the standard RKE2 security posture a couple of steps further by way of installing with [CIS 1.23](https://docs.rke2.io/security/cis_self_assessment123) Profile enabled, using Calico's Wireguard backend for encrypting pod-to-pod communication, & enforcing the use TLS 1.3 across Control Plane components.

There is a lot of HereDoc in the `rke_config` section of `cluster.tf` so that it's easier to see what's going on - you'll probably want to put this info in a template file to keep the plan a bit neater than what's seen here.

Some operating systems will run containerd within the "systemd" control group and the Kubelet within the "cgroupfs" control group - this plan passes to the Kubelet a `--cgroup-driver=systemd` argument to ensure that there will be only a single cgroup manager running - better aligining the cluster with upstream K8s reccomendations ( see: <https://kubernetes.io/docs/setup/production-environment/container-runtimes/#cgroup-drivers>).

## Static IP Addressing

Static IPs _can_ be implemented if needed. Firstly, a [Network Protocol Profile needs to be created in vSphere](https://docs.vmware.com/en/VMware-vSphere/7.0/com.vmware.vsphere.networking.doc/GUID-D24DBAA0-68BD-49B9-9744-C06AE754972A.html). After the profile is created, two parts of this Terraform plan need to be changed: `cloud-init` and the `rancher2_machine_config_v2` resource in `cluster.tf`.

1. A script must be added with `write_files` and executed via `runcmd` in `cloud-init`. This script gathers instance metadata, via vmtools, and then applies it (the below example uses Netplan. Your OS, however, may use something different):

```yaml
- content: |
  #!/bin/bash
  vmtoolsd --cmd 'info-get guestinfo.ovfEnv' > /tmp/ovfenv
  IPAddress=$(sed -n 's/.*Property oe:key="guestinfo.interface.0.ip.0.address" oe:value="\([^"]*\).*/\1/p' /tmp/ovfenv)
  SubnetMask=$(sed -n 's/.*Property oe:key="guestinfo.interface.0.ip.0.netmask" oe:value="\([^"]*\).*/\1/p' /tmp/ovfenv)
  Gateway=$(sed -n 's/.*Property oe:key="guestinfo.interface.0.route.0.gateway" oe:value="\([^"]*\).*/\1/p' /tmp/ovfenv)
  DNS=$(sed -n 's/.*Property oe:key="guestinfo.dns.servers" oe:value="\([^"]*\).*/\1/p' /tmp/ovfenv)

  cat > /etc/netplan/01-netcfg.yaml <<EOF
  network:
    version: 2
    renderer: networkd
    ethernets:
      ens192:
        addresses: 
          - $IPAddress/24
        gateway4: $Gateway
        nameservers:
        addresses : [$DNS]
  EOF

  netplan apply

path: /root/netplan.sh
```

2. The below additions need to be made to `rancher2_machine_config_v2`.  This example would apply static IPv4 addresses to only the `ctl_plane` node pool:

```terraform
vapp_ip_allocation_policy = each.key == "ctl_plane" ? "fixedAllocated" : null
vapp_ip_protocol          = each.key == "ctl_plane" ? "IPv4" : null
vapp_property = each.key == "ctl_plane" ? [
  "guestinfo.interface.0.ip.0.address=ip:<vSwitch_from_Network_Protocol_Profile>",
  "guestinfo.interface.0.ip.0.netmask=$${netmask:<vSwitch_from_Network_Protocol_Profile>}",
  "guestinfo.interface.0.route.0.gateway=$${gateway:<vSwitch_from_Network_Protocol_Profile>}",
  "guestinfo.dns.servers=$${dns:<vSwitch_from_Network_Protocol_Profile>}",
] : null
vapp_transport = each.key == "ctl_plane" ? "com.vmware.guestInfo" : null
```

Using static IPs comes with some small caveats:

- In leu of "traditional" `cloud-init` logic to handle OS updates/upgrades & package installs:

```yaml
package_reboot_if_required: true
package_update: true
package_upgrade: true
packages:
  - <insert_awesome_package_name_here>
```

Scripting would need to be introduced to take care of this later on in the `cloud-init` process, if desired (i.e. a `write_file` using `defer: true`). Since `runcmd` happens later in the `cloud-init` process, the node would not have an IP available to successfully complete any `package*` logic requiring network access.

## Environment Prerequisites

- Functional Rancher Management Server with vSphere Cloud Credential
- vCenter >= 7.x and credentials with appropriate permissions (see <https://ranchermanager.docs.rancher.com/how-to-guides/new-user-guides/launch-kubernetes-with-rancher/use-new-nodes-in-an-infra-provider/vsphere/create-credentials>)
- Virtual Machine Hardware Compatibility at Version >= 15
- Create the following in the files/ directory:

    | NAME | PURPOSE |
    |:-----|:--------|
    | .rancher-api-url      | URL for Rancher Management Server |
    | .rancher-bearer-token | API bearer token generated via Rancher UI |
    | .ssh-public-key       | SSH public key for additional OS user |
    | .vsphere-passwd       | Password associated with vSphere CPI/CSI credential |

## CSI Driver Permissions

If you want to use a separate, least-privilege account for the CSI driver, these are the minimum permissions:
| CATEGORY | PERMISSION |
|:---------|:-----------|
| Cns                    | Searchable |
| Datastore              | Low level file operations |
| Host                   | Configuration<br/>- Storage partition configuration |
| Profile-driven storage | Profile-driven storage view |
| Virtual machine        | Change Configuration<br/>- Add existing disk<br/>- Add or remove device |

## Caveats

- vSphere CSI volumes are **RWO only** unless using vSAN Datastore
- Using Wireguard as CNI backend comes at a performance penalty (see <https://projectcalico.docs.tigera.io/security/encrypt-cluster-pod-traffic>)
- kube-vip is configured in L2 mode, so **_ALL_** LoadBalancer service traffic goes **_only_** to the node that has the VIP assigned, which is not suitable for production

## To Run

```bash
terraform apply
```

## Tested Versions

| SOFTWARE | VERSION | DOCS |
|:---------|:--------|:-----|
| kube-vip                   | 0.6.0         | <https://kube-vip.io/docs/> |
| Rancher Server             | 2.7.4         | <https://ranchermanager.docs.rancher.com/> |
| Rancher Terraform Provider | 3.0.0         | <https://registry.terraform.io/providers/rancher/rancher2/latest/docs> |
| RKE2                       | 1.25.9+rke2r1 | <https://docs.rke2.io> |
| Terraform                  | 1.4.6         | <https://www.terraform.io/docs> |
| vSphere                    | 7.0.3.01300   | <https://docs.vmware.com/en/VMware-vSphere/index.html> |
