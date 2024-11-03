terraform {
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
      version = "0.60.0"
    }
    talos = {
      source = "siderolabs/talos"
      version = "0.5.0"
    }
    github = {
      source  = "integrations/github"
      version = "~> 5.0"  # Use the latest stable version or your desired version
    }
  }
}
