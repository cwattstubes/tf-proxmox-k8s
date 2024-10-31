provider "proxmox" {
  endpoint = "https://192.168.210.30:8006/"
  insecure = true # Only needed if your Proxmox server is using a self-signed certificate
}
