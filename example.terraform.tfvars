cloud_credential = "vsphere"

metallb = {
  ending_ip   = "1.2.3.4"
  starting_ip = "1.2.3.5"
}

rke2_version = "v1.23.4+rke2r2"

vsphere_env = {
  cloud_image_name = "ubuntu"
  compute_node     = "esxi.node.local"
  datacenter       = "datacenter"
  datastore        = "fast"
  ds_url           = "ds:///vmfs/volumes/..."
  library_name     = "rancher-templates"
  server           = "appliance.fqdn or IP"
  user             = "rancher_user@vsphere.local"
  vm_network       = "k8s"
}