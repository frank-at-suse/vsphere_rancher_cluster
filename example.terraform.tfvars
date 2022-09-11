rancher_env = {
  cloud_credential    = "cloud-credential"
  cluster_annotations = { "foo" = "bar" }
  cluster_labels      = { "something" = "amazing" }
  rke2_version        = "v1.24.4+rke2r1"
}

metallb = {
  ending_ip   = "1.2.3.4"
  starting_ip = "1.2.3.5"
}

# These are machine specs for nodes.  Be mindful of System Requirements!
node = {
  ctl_plane = { hdd_capacity = 40960, name = "ctl-plane", quantity = 3, vcpu = 4, vram = 4096 }
  worker    = { hdd_capacity = 81920, name = "worker", quantity = 3, vcpu = 4, vram = 8192 }
}

vsphere_env = {
  cloud_image_name = "your-image-here"
  compute_node     = "esxi.node.local"
  datacenter       = "datacenter"
  datastore        = "fast"
  ds_url           = "ds:///vmfs/volumes/.../"
  library_name     = "rancher-templates"
  server           = "appliance.fqdn or IP"
  user             = "rancher_user@vsphere.local"
  vm_network       = "k8s"
}
