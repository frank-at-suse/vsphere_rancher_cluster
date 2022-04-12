resource "rancher2_app_v2" "vsphere-cloud-provider" {
  chart_name    = "rancher-vsphere-cpi"
  chart_version = "1.2.101"
  cluster_id    = rancher2_cluster_v2.rke2.cluster_v1_id
  name          = "vsphere-cpi"
  namespace     = data.rancher2_namespace.kube_system.id
  repo_name     = "rancher-rke2-charts"
  values        = <<EOF
    vCenter:
      datacenters: ${var.vsphere_env.datacenter}
      host: ${var.vsphere_env.server}
      password: ${file( "${path.cwd}/files/.vsphere-passwd" )}
      username: ${var.vsphere_env.user}
  EOF
}