variable "cluster_name" {
  type    = string
  default = "homelab"
}

variable "default_gateway" {
  type    = string
  default = "192.168.200.1"
}

variable "talos_cp_01_ip_addr" {
  type    = string
  default = "192.168.200.40"
}

variable "talos_worker_01_ip_addr" {
  type    = string
  default = "192.168.200.41"
}

variable "talos_worker_02_ip_addr" {
  type    = string
  default = "192.168.200.42"
}
