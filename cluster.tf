resource "random_pet" "cluster_name" {
  length = 2
  prefix = "vsphere-${terraform.workspace}"
}

resource "rancher2_machine_config_v2" "nodes" {
  for_each      = var.node
  generate_name = replace( each.key, "_", "-" )

  vsphere_config {
    cfgparam   = ["disk.enableUUID=TRUE"] # Disk UUID is Required for vSphere Storage Provider
    clone_from = var.vsphere_env.cloud_image_name
    cloud_config = templatefile( "${path.cwd}/files/user_data_${each.key}.tftmpl",
      {
        ssh_user       = "rancher",
        ssh_public_key = file( "${path.cwd}/files/.ssh-public-key", )
      }) # End of templatefile
    content_library = var.vsphere_env.library_name
    cpu_count       = each.value.vcpu
    creation_type   = "library"
    datacenter      = var.vsphere_env.datacenter
    datastore       = var.vsphere_env.datastore
    disk_size       = each.value.hdd_capacity
    hostsystem      = var.vsphere_env.compute_node
    memory_size     = each.value.vram
    network         = var.vsphere_env.vm_network
    vcenter         = var.vsphere_env.server
  }
} # End of rancher2_machine_config_v2

resource "rancher2_cluster_v2" "rke2" {
  annotations        = var.rancher_env.cluster_annotations
  kubernetes_version = var.rancher_env.rke2_version
  labels             = var.rancher_env.cluster_labels
  name               = random_pet.cluster_name.id

  local_auth_endpoint {
    enabled = true
  }

  rke_config {
    chart_values = <<EOF
      rke2-calico:
        felixConfiguration:
          wireguardEnabled: true
          
      rke2-ingress-nginx:
        controller:
          publishService:
            enabled: true
          service:
            enabled: true
    EOF

    machine_global_config = <<EOF
      cni: ${var.rancher_env.cni}
      etcd-arg: [ "--experimental-initial-corrupt-check=true" ]
      kube-apiserver-arg: [ "--enable-admission-plugins=AlwaysPullImages,NodeRestriction","--tls-min-version=VersionTLS13" ]
      kube-controller-manager-arg: [ "--terminated-pod-gc-threshold=10","--tls-min-version=VersionTLS13" ]
      kube-proxy-arg: [ "--ipvs-strict-arp=true" ]
      kube-scheduler-arg: [ "--tls-min-version=VersionTLS13" ]
      kubelet-arg: [ "--cgroup-driver=systemd","--event-qps=0","--make-iptables-util-chains=true","--tls-min-version=VersionTLS13" ]
      profile: cis-1.6
    EOF

    dynamic "machine_pools" {
      for_each = var.node
      content {
        cloud_credential_secret_name   = data.rancher2_cloud_credential.auth.id
        control_plane_role             = machine_pools.key == "ctl_plane" ? true : false
        etcd_role                      = machine_pools.key == "ctl_plane" ? true : false
        name                           = replace(machine_pools.key, "_", "-")
        quantity                       = machine_pools.value.quantity
        unhealthy_node_timeout_seconds = 120
        worker_role                    = machine_pools.key != "ctl_plane" ? true : false

        machine_config {
          kind = rancher2_machine_config_v2.nodes[machine_pools.key].kind
          name = replace(rancher2_machine_config_v2.nodes[machine_pools.key].name, "_", "-")
        }
      } # End of dynamic for_each content
    }   # End of machine_pools

    machine_selector_config {
      config = {
        cloud-provider-name      = "rancher-vsphere"
        disable-cloud-controller = true # Disables built-in RKE2 Cloud Controller
        protect-kernel-defaults  = true # Required to install RKE2 with CIS Profile enabled
      }
    } # End machine_selector_config
  }   # End of rke_config
}     # End of rancher2_cluster_v2
