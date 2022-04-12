resource "rancher2_app_v2" "metallb" {
  chart_name    = "metallb"
  chart_version = "0.12.1"
  cluster_id    = rancher2_cluster_v2.rke2.cluster_v1_id
  name          = "metallb"
  namespace     = rancher2_namespace.metallb_system.name
  repo_name     = "metallb"
  values        = templatefile( "${path.cwd}/files/metallb-configmap.yaml",
    {
      ending_ip   = var.metallb.ending_ip,
      starting_ip = var.metallb.starting_ip,
    })
}

resource "rancher2_namespace" "metallb_system" {
  name             = "metallb-system"
  project_id       = data.rancher2_project.system.id
  wait_for_cluster = true
}