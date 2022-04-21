terraform {

  required_providers {

    rancher2  = {
      source  = "rancher/rancher2"
      version = "1.23.0"
    }

    vsphere   = {
      source  = "hashicorp/vsphere"
      version = "2.1.1"
    } 
  }
}

  provider "rancher2" {
    access_key = file( "${path.cwd}/files/.rancher-access-key" )
    api_url    = file( "${path.cwd}/files/.rancher-api-url" )
    secret_key = file( "${path.cwd}/files/.rancher-secret-key" )
  }

  provider "vsphere" {
    allow_unverified_ssl = true
    user                 = var.vsphere_env.user
    password             = file( "${path.cwd}/files/.vsphere-passwd" )
    vsphere_server       = var.vsphere_env.server
  }