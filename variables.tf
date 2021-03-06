variable "metallb" {
  description = "IP pool for metalLB L2 Configuration"
  type = object ({
    ending_ip   = string
    starting_ip = string
  })
}

variable "node" {
  type = object ({
    ctl_plane = map(any)
    worker    = map(any)
  })
}

variable "rancher_env" {
  description = "Variables for Rancher environment"
  type = object ({
    cloud_credential     = string
    cluster_annotations  = map(string)
    cluster_labels       = map(string)
    rke2_version         = string
  })
}

variable "vsphere_env" {
  description = "Variables for vSphere environment"
  type = object ({
    cloud_image_name = string #
    compute_node     = string #
    datacenter       = string #
    datastore        = string #
    ds_url           = string #
    library_name     = string #
    server           = string #
    user             = string #
    vm_network       = list(string) #
  })
}
