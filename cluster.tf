resource "talos_machine_secrets" "machine_secrets" {}

data "talos_client_configuration" "talosconfig" {
  cluster_name         = var.cluster_name
  client_configuration = talos_machine_secrets.machine_secrets.client_configuration
  endpoints            = [var.talos_cp_01_ip_addr]
}

data "talos_machine_configuration" "machineconfig_cp" {
  cluster_name     = var.cluster_name
  cluster_endpoint = "https://${var.talos_cp_01_ip_addr}:6443"
  machine_type     = "controlplane"
  machine_secrets  = talos_machine_secrets.machine_secrets.machine_secrets
}

resource "talos_machine_configuration_apply" "cp_config_apply" {
  depends_on                  = [proxmox_virtual_environment_vm.talos_cp_01]
  client_configuration        = talos_machine_secrets.machine_secrets.client_configuration
  machine_configuration_input = data.talos_machine_configuration.machineconfig_cp.machine_configuration
  count                       = 1
  node                        = var.talos_cp_01_ip_addr
}

data "talos_machine_configuration" "machineconfig_worker" {
  cluster_name     = var.cluster_name
  cluster_endpoint = "https://${var.talos_cp_01_ip_addr}:6443"
  machine_type     = "worker"
  machine_secrets  = talos_machine_secrets.machine_secrets.machine_secrets
}

resource "talos_machine_configuration_apply" "worker_config_apply" {
  for_each = { for worker in local.workers : worker.name => worker }

  client_configuration        = talos_machine_secrets.machine_secrets.client_configuration
  machine_configuration_input = data.talos_machine_configuration.machineconfig_worker.machine_configuration
  node                        = each.value.ip_address  # Referencing ip_address in each worker configuration
}

resource "talos_machine_bootstrap" "bootstrap" {
  depends_on           = [talos_machine_configuration_apply.cp_config_apply]
  client_configuration = talos_machine_secrets.machine_secrets.client_configuration
  node                 = var.talos_cp_01_ip_addr
}

data "talos_cluster_health" "health" {
  depends_on           = [talos_machine_configuration_apply.cp_config_apply, talos_machine_configuration_apply.worker_config_apply]
  client_configuration = data.talos_client_configuration.talosconfig.client_configuration
  control_plane_nodes  = [var.talos_cp_01_ip_addr]
  
  # Use the IP addresses from local.workers to dynamically list worker node IPs
  worker_nodes         = [for worker in local.workers : worker.ip_address]
  
  endpoints            = data.talos_client_configuration.talosconfig.endpoints
}

data "talos_cluster_kubeconfig" "kubeconfig" {
  depends_on           = [talos_machine_bootstrap.bootstrap, data.talos_cluster_health.health]
  client_configuration = talos_machine_secrets.machine_secrets.client_configuration
  node                 = var.talos_cp_01_ip_addr
}

output "talosconfig" {
  value     = data.talos_client_configuration.talosconfig.talos_config
  sensitive = true
}

output "kubeconfig" {
  value     = data.talos_cluster_kubeconfig.kubeconfig.kubeconfig_raw
  sensitive = true
}

resource "local_file" "kubeconfig_file" {
  content  = data.talos_cluster_kubeconfig.kubeconfig.kubeconfig_raw
  filename = "${path.module}/generated_kubeconfig"
}

