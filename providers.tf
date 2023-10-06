terraform {

  required_providers {

    rancher2 = {
      source  = "rancher/rancher2"
      version = "3.1.1"
    }
  } # End of required_providers
}   # End of terraform

provider "rancher2" {
  api_url   = file("${path.cwd}/files/.rancher-api-url")
  token_key = file("${path.cwd}/files/.rancher-bearer-token")
}
