resource "proxmox_virtual_environment_vm" "talos_cp_01" {
  name        = "talos-cp-01"
  description = "Managed by Terraform"
  tags        = ["terraform"]
  node_name   = "saturn"
  on_boot     = true

  cpu {
    cores = 2
    type = "host"
  }

  memory {
    dedicated = 4096
  }

  agent {
    enabled = true
  }

  network_device {
    bridge = "vnet1"
    mtu = "1450"
  }

  disk {
    datastore_id = "saturn-nfs"
    file_id      = proxmox_virtual_environment_download_file.talos_nocloud_image.id
    file_format  = "raw"
    interface    = "virtio0"
    size         = 20
  }

  operating_system {
    type = "l26" # Linux Kernel 2.6 - 5.X.
  }

  initialization {
    datastore_id = "local"
    dns {
      servers = [var.dns_server]
    } 
    ip_config {
      ipv4 {
        address = "${var.talos_cp_01_ip_addr}/24"
        gateway = var.default_gateway
      }
    }
  }
}

locals {
  # Create a list of worker configurations by merging defaults
  workers = flatten([
    for group_name, group in var.worker_groups : [
      for index, ip in group.ip_addresses : {
        name         = "${group_name}-worker-${index + 1}"
        node_name    = coalesce(group.node_name, var.worker_defaults.node_name)
        cpu          = coalesce(group.cpu, var.worker_defaults.cpu)
        memory       = coalesce(group.memory, var.worker_defaults.memory)
        datastore_id = coalesce(group.datastore_id, var.worker_defaults.datastore_id)
        disk_size    = coalesce(group.disk_size, var.worker_defaults.disk_size)
        bridge       = var.worker_defaults.bridge
        ip_address   = ip
      }
    ]
  ])
}

resource "null_resource" "destroy_step1" {
  depends_on = [helm_release.nginx_ingress]
}

resource "proxmox_virtual_environment_vm" "talos_worker" {
  depends_on                  = [proxmox_virtual_environment_vm.talos_cp_01]

  for_each = { for worker in local.workers : worker.name => worker }

  name        = each.value.name
  node_name   = each.value.node_name
  description = "Managed by Terraform"
  tags        = ["terraform"]
  on_boot     = true

  agent {
    enabled = true
  }

  cpu {
    cores = each.value.cpu
    type  = "host"
  }

  memory {
    dedicated = each.value.memory
  }

  network_device {
    bridge = each.value.bridge
    mtu    = "1450"
  }

  operating_system {
    type = "l26" # Linux Kernel 2.6 - 5.X.
  }

  disk {
    datastore_id = each.value.datastore_id
    size         = each.value.disk_size
    file_id      = proxmox_virtual_environment_download_file.talos_nocloud_image.id
    file_format  = "raw"
    interface    = "virtio0"
  }

  initialization {
    datastore_id = each.value.datastore_id
    dns {
      servers = [var.dns_server]
    } 
    ip_config {
      ipv4 {
        address = "${each.value.ip_address}/24"
        gateway = var.default_gateway
      }
    }
  }
}

