variable "cluster_name" {
  type    = string
  default = "homelab"
}

variable "default_gateway" {
  type    = string
  default = "192.168.200.1"
}

variable "dns_server" {
  type    = string
  default = "192.168.200.1"
}

variable "talos_cp_01_ip_addr" {
  type    = string
  default = "192.168.200.40"
}

variable "worker_defaults" {
  type = object({
    cpu          = number
    memory       = number
    datastore_id = string
    disk_size    = number
    bridge       = string
    node_name    = string
  })
  default = {
    cpu          = 2
    memory       = 2048
    datastore_id = "local"
    disk_size    = 15
    bridge       = "vnet1"
    node_name    = "default-node"
  }
}

variable "worker_groups" {
  type = map(object({
    node_name    = optional(string)
    cpu          = optional(number)
    memory       = optional(number)
    datastore_id = optional(string)
    disk_size    = optional(number)
    ip_addresses = list(string)
  }))

  default = {
    group1 = {
      node_name    = "saturn"
      cpu          = 2 
      memory       = 2048
      datastore_id = "local"
      disk_size    = 15
      #ip_addresses = ["192.168.200.42", "192.168.200.43"]
      ip_addresses = ["192.168.200.42"]
    },
    group2 = {
      node_name    = "smnode1"
      datastore_id = "local"
      # Omitting some settings to fall back on defaults
      ip_addresses = ["192.168.200.41", "192.168.200.43"]
      #ip_addresses = ["192.168.200.41"]
    }
  }
}
