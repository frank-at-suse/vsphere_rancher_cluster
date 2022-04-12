variable "cloud_credential" {
  description = "Name of existing Rancher Server vSphere Cloud Credential"
  type        = string
}

variable "cluster_annotations" {
  description = "Optional. Annotations in Key=Value format"
  default     = {}
  type        = map(string)
}

variable "cluster_labels" {
  description = "Optional. Cluster Labels in Key=Value format. Handy for app provisioning via Fleet Cluster Groups"
  default     = {}
  type        = map(string)
}

variable "metallb" {
  description = "IP pool for metalLB L2 Configuration"
  type = object ({
    ending_ip   = string
    starting_ip = string
  })
}

variable "rke2_version" {
  description = "For list of RKE2 release versions, please visit: https://github.com/rancher/rke2/releases"
  type        = string
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
    vm_network       = string #
  })
}