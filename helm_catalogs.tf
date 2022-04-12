# To avoid issues like https://github.com/rancher/terraform-provider-rancher2/issues/662#issuecomment-1063125260
resource "rancher2_cluster_sync" "active_cluster" {
  cluster_id    = rancher2_cluster_v2.rke2.cluster_v1_id
  state_confirm = 75 # Catalog resources will wait for 4 minutes after cluster reaches active state
}

resource "rancher2_catalog_v2" "metallb" {
  cluster_id = rancher2_cluster_sync.active_cluster.id
  name       = "metallb"
  url        = "https://metallb.github.io/metallb"
}

resource "rancher2_catalog_v2" "rancher_rke2_charts" {
  cluster_id = rancher2_cluster_sync.active_cluster.id
  name       = "rancher-rke2-charts"
  git_repo   = "https://git.rancher.io/rke2-charts.git"
  git_branch = "main"
}