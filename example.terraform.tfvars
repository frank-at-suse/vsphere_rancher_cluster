rancher_env = {
    cloud_credential    = "cloud-credential"
    cluster_annotations = { "key1"="value1","key2"="value2" }
    cni                 = "calico"
    ctl_plane_count     = 3
    cluster_labels      = { key="value" }
    p2p_encryption      = true
    rke2_version        = "v1.23.4+rke2r2"
    worker_count        = 3
}

metallb = {
  ending_ip   = "1.2.3.4"
  starting_ip = "1.2.3.5"
}

vsphere_env = {
  cloud_image_name = "ubuntu"
  compute_node     = "esxi.node.local"
  cpi_chart_ver    = "100.3.0+up1.2.1"
  csi_chart_ver    = "100.3.0+up2.5.1-rancher1"
  datacenter       = "datacenter"
  datastore        = "fast"
  ds_url           = "ds:///vmfs/volumes/.../"
  library_name     = "rancher-templates"
  server           = "appliance.fqdn or IP"
  user             = "rancher_user@vsphere.local"
  vm_network       = "k8s"
}

# These are machine specs for nodes.  Be mindful of System Requirements!
ctl_plane_node = {
  vram         = 4096
  vcpu         = 2
  hdd_capacity = 81920
}

worker_node = {
  vram         = 8192
  vcpu         = 4
  hdd_capacity = 30720
}