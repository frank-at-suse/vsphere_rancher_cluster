resource "rancher2_app_v2" "vsphere_storage_provider" {
  chart_name    = "rancher-vsphere-csi"
  chart_version = var.vsphere_env.csi_chart_ver
  cluster_id    = rancher2_cluster_v2.rke2.cluster_v1_id
  name          = "vsphere-csi"
  namespace     = data.rancher2_namespace.kube_system.id
  repo_name     = "rancher-charts"
  values        = <<EOF
    storageClass:
      datastoreURL: ${var.vsphere_env.ds_url}
    vCenter:
      clusterId: ${rancher2_cluster_v2.rke2.cluster_v1_id}
      datacenters: ${var.vsphere_env.datacenter}
      host: ${var.vsphere_env.server}
      password: ${file( "${path.cwd}/files/.vsphere-passwd" )}
      username: ${var.vsphere_env.user}
  EOF
  lifecycle {
    ignore_changes = [
      namespace,
    ]
  } # Close lifecycle
}