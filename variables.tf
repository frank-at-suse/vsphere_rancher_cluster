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
    cni                  = string
    ctl_plane_count      = number
    p2p_encryption       = bool
    rke2_version         = string
    worker_count         = number
  })
}

variable "vsphere_env" {
  description = "Variables for vSphere environment"
  type = object ({
    cloud_image_name = string #
    compute_node     = string #
    cpi_chart_ver    = string #
    csi_chart_ver    = string #
    datacenter       = string #
    datastore        = string #
    ds_url           = string #
    library_name     = string #
    server           = string #
    user             = string #
    vm_network       = list(string) #
  })
}

# These are machine specs for node roles.  Be mindful of System Requirements!
variable "ctl_plane_node" {
  type = object ({
    vram         = number
    vcpu         = number
    hdd_capacity = number
  })
}

variable "worker_node" {
  type = object ({
    vram         = number
    vcpu         = number
    hdd_capacity = number
})
}