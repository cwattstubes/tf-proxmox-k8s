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
      servers = ["192.168.200.1"]
    } 
    ip_config {
      ipv4 {
        address = "${var.talos_cp_01_ip_addr}/24"
        gateway = var.default_gateway
      }
    }
  }
}

resource "proxmox_virtual_environment_vm" "talos_worker_01" {
  depends_on = [ proxmox_virtual_environment_vm.talos_cp_01 ]
  name        = "talos-worker-01"
  description = "Managed by Terraform"
  tags        = ["terraform"]
  node_name   = "smnode1"
  on_boot     = true

  cpu {
    cores = 4
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
      servers = ["192.168.200.1"]
    } 
    ip_config {
      ipv4 {
        address = "${var.talos_worker_01_ip_addr}/24"
        gateway = var.default_gateway
      }
    }
  }
}

resource "proxmox_virtual_environment_vm" "talos_worker_02" {
  depends_on = [ proxmox_virtual_environment_vm.talos_cp_01 ]
  name        = "talos-worker-02"
  description = "Managed by Terraform"
  tags        = ["terraform"]
  node_name   = "smnode1"
  on_boot     = true

  cpu {
    cores = 4
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
      servers = ["192.168.200.1"]
    }
    ip_config {
      ipv4 {
        address = "${var.talos_worker_02_ip_addr}/24"
        gateway = var.default_gateway
      }
    }
  }
}
