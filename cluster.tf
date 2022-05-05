resource "random_pet" "cluster_name" {
  length = 2
  prefix = lower( "${rancher2_machine_config_v2.workers.kind}-${terraform.workspace}" )
}

# Rancher Machine Config for k8s Control Plane
resource "rancher2_machine_config_v2" "ctl_plane" {
  generate_name = "ctl-plane"

  vsphere_config {
    cfgparam        = [ "disk.enableUUID=TRUE" ] # Disk UUID is Required for vSphere Storage Provider
    clone_from      = var.vsphere_env.cloud_image_name
    cloud_config    = templatefile( "${path.cwd}/files/user-data-ctl-plane.yaml", 
      {
        ssh_user       = "rancher",
        ssh_public_key = file( "${path.cwd}/files/.ssh-public-key", )
      }) # End of templatefile
    content_library = var.vsphere_env.library_name
    cpu_count       = var.ctl_plane_node.vcpu
    creation_type   = "library"
    datacenter      = var.vsphere_env.datacenter
    datastore       = var.vsphere_env.datastore
    disk_size       = var.ctl_plane_node.hdd_capacity
    hostsystem      = var.vsphere_env.compute_node
    memory_size     = var.ctl_plane_node.vram
    network         = var.vsphere_env.vm_network
    vcenter         = var.vsphere_env.server
  }
}

# Rancher Machine Config for dedicated Workers pool
resource "rancher2_machine_config_v2" "workers" {
  generate_name = "workers"

  vsphere_config {
    cfgparam        = [ "disk.enableUUID=TRUE" ] # Disk UUID is Required for vSphere Storage Provider
    clone_from      = var.vsphere_env.cloud_image_name
    cloud_config    = templatefile( "${path.cwd}/files/user-data-ctl-plane.yaml", 
      {
        ssh_user       = "rancher",
        ssh_public_key = file( "${path.cwd}/files/.ssh-public-key", )
      }) # End of templatefile
    content_library = var.vsphere_env.library_name
    cpu_count       = var.worker_node.vcpu
    creation_type   = "library"
    datacenter      = var.vsphere_env.datacenter
    datastore       = var.vsphere_env.datastore
    disk_size       = var.worker_node.hdd_capacity
    hostsystem      = var.vsphere_env.compute_node
    memory_size     = var.worker_node.vram
    network         = var.vsphere_env.vm_network
    vcenter         = var.vsphere_env.server
  }
}

resource "rancher2_cluster_v2" "rke2" {
  annotations        = var.rancher_env.cluster_annotations
  kubernetes_version = var.rancher_env.rke2_version
  labels             = var.rancher_env.cluster_labels
  local_auth_endpoint {
    enabled  = true
  }
  name               = random_pet.cluster_name.id
  
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
      etcd-arg: [ "--experimental-initial-corrupt-check" ]
      kube-apiserver-arg: [ "--enable-admission-plugins=AlwaysPullImages,NodeRestriction" ]
      kube-controller-manager-arg: [ "--terminated-pod-gc-threshold=10" ]
      kube-proxy-arg: [ "--ipvs-strict-arp=true" ]
      kubelet-arg: [ "--cloud-provider=vsphere","--event-qps=0","--make-iptables-util-chains=true" ]
      profile: cis-1.5
    EOF

    machine_pools {
      cloud_credential_secret_name   = data.rancher2_cloud_credential.auth.id
      control_plane_role             = true
      etcd_role                      = true
      name                           = "ctl-plane"
      quantity                       = var.rancher_env.ctl_plane_count
      unhealthy_node_timeout_seconds = 120

      machine_config {
        kind = rancher2_machine_config_v2.ctl_plane.kind
        name = rancher2_machine_config_v2.ctl_plane.name
      }
    }

    machine_pools {
      cloud_credential_secret_name   = data.rancher2_cloud_credential.auth.id
      name                           = "workers"
      quantity                       = var.rancher_env.worker_count
      unhealthy_node_timeout_seconds = 120
      worker_role                    = true

      machine_config {
        kind = rancher2_machine_config_v2.workers.kind
        name = rancher2_machine_config_v2.workers.name
      }
    }

    machine_selector_config {
      config = {
        disable-cloud-controller = true # Disables built-in RKE2 Cloud Controller
        protect-kernel-defaults  = true # Required to install RKE2 with CIS Profile enabled
      }
    }
  }
}