resource "talos_machine_secrets" "this" {
  talos_version = var.talos_version
}

data "talos_client_configuration" "this" {
  cluster_name         = var.cluster_name
  client_configuration = talos_machine_secrets.this.client_configuration
  endpoints            = [for node in values(var.controlplane_nodes) : node.ip]
}

data "talos_machine_configuration" "this_controlplane" {
  for_each = var.controlplane_nodes

  cluster_name       = var.cluster_name
  talos_version      = var.talos_version
  machine_type       = "controlplane"
  cluster_endpoint   = "https://${values(var.controlplane_nodes)[0].ip}:6443"
  machine_secrets    = talos_machine_secrets.this.machine_secrets
  kubernetes_version = var.kubernetes_version
}

data "talos_machine_configuration" "this_worker" {
  for_each = var.worker_nodes

  cluster_name       = var.cluster_name
  talos_version      = var.talos_version
  machine_type       = "worker"
  cluster_endpoint   = "https://${values(var.controlplane_nodes)[0].ip}:6443"
  machine_secrets    = talos_machine_secrets.this.machine_secrets
  kubernetes_version = var.kubernetes_version
}

resource "talos_machine_configuration_apply" "this_controlplane" {
  for_each = data.talos_machine_configuration.this_controlplane

  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = each.value.machine_configuration
  node                        = var.controlplane_nodes[each.key].ip
  config_patches              = concat(var.common_config_patches, var.controlplane_config_patches)
}

resource "talos_machine_configuration_apply" "this_worker" {
  for_each = data.talos_machine_configuration.this_worker

  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = each.value.machine_configuration
  node                        = var.worker_nodes[each.key].ip
  config_patches              = concat(var.common_config_patches, var.worker_config_patches)
}

resource "talos_machine_bootstrap" "this" {
  node                 = values(var.controlplane_nodes)[0].ip
  client_configuration = talos_machine_secrets.this.client_configuration

  depends_on = [
    talos_machine_configuration_apply.this_controlplane
  ]
}

data "talos_cluster_health" "this" {
  client_configuration = data.talos_client_configuration.this.client_configuration
  control_plane_nodes  = [for node in values(var.controlplane_nodes) : node.ip]
  worker_nodes         = [for node in values(var.worker_nodes) : node.ip]
  endpoints            = data.talos_client_configuration.this.endpoints
  timeouts = {
    read = "5m"
  }

  depends_on = [
    talos_machine_bootstrap.this,
    talos_machine_configuration_apply.this_worker
  ]
}

data "talos_cluster_kubeconfig" "this" {
  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = values(var.controlplane_nodes)[0].ip

  depends_on = [
    data.talos_cluster_health.this
  ]
}
