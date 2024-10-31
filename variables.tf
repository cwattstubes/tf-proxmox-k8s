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

variable "num_worker_nodes" {
  type    = number
  default = 2  # Set a default value; can be overridden when applying Terraform
}

variable "talos_cp_01_ip_addr" {
  type    = string
  default = "192.168.200.40"
}

variable "worker_ip_addresses" {
  type = list(string)
  description = "List of IP addresses for worker nodes"
  default = ["192.168.200.41", "192.168.200.42"]  # Adjust as needed
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
      datastore_id = "saturn-nfs"
      disk_size    = 15
      ip_addresses = ["192.168.200.42", "192.168.200.44"]
    },
    group2 = {
      node_name    = "smnode1"
      # Omitting some settings to fall back on defaults
      ip_addresses = ["192.168.200.41", "192.168.200.43"]
    }
  }
}


variable "talos_worker_01_ip_addr" {
  type    = string
  default = "192.168.200.41"
}

variable "talos_worker_02_ip_addr" {
  type    = string
  default = "192.168.200.42"
}
