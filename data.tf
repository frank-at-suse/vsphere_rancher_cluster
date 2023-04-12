data "http" "kube_vip_rbac" {
  url = "https://kube-vip.io/manifests/rbac.yaml"
}

data "http" "kube_vip_version" {
  method = "GET"
  url    = "https://api.github.com/repos/kube-vip/kube-vip/releases/latest"
}

data "rancher2_cloud_credential" "auth" {
  name = var.rancher_env.cloud_credential
}

data "rancher2_namespace" "kube_system" {
  name       = "kube-system"
  project_id = data.rancher2_project.system.id
}

data "rancher2_project" "system" {
  name       = "System"
  cluster_id = rancher2_cluster_v2.rke2.cluster_v1_id
}