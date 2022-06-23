terraform {

  required_providers {

    rancher2  = {
      source  = "rancher/rancher2"
      version = "1.24.0"
    }
  } # End of required_providers
}   # End of terraform

  provider "rancher2" {
    access_key = file( "${path.cwd}/files/.rancher-access-key" )
    api_url    = file( "${path.cwd}/files/.rancher-api-url" )
    secret_key = file( "${path.cwd}/files/.rancher-secret-key" )
  }
