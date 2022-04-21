rancher_env = {
    cloud_credential    = "cloud-credential"
    cluster_annotations = { "key1"="value1","key2"="value2" }
    cluster_labels      = { key="value" }
    rke2_version        = "v1.23.4+rke2r2"
}

metallb = {
  ending_ip   = "1.2.3.4"
  starting_ip = "1.2.3.5"
}

vsphere_env = {
  cloud_image_name = "ubuntu"
  compute_node     = "esxi.node.local"
  datacenter       = "datacenter"
  datastore        = "fast"
  ds_url           = "ds:///vmfs/volumes/.../"
  library_name     = "rancher-templates"
  server           = "appliance.fqdn or IP"
  user             = "rancher_user@vsphere.local"
  vm_network       = "k8s"
}