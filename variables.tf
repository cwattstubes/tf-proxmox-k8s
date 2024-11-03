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

# GitHub Personal Access Token (with default placeholder)
variable "github_token" {
  description = "Personal Access Token for GitHub to manage repository deploy keys"
  type        = string
  sensitive   = true
  default     = ""  # Replace with your token
}

# GitHub Repository Name (default placeholder for demo purposes)
variable "github_repo_name" {
  description = "The name of the GitHub repository for ArgoCD to sync from"
  type        = string
  default     = "argocd"  # Replace with your repo name
}

# GitHub Owner (User or Organization)
variable "github_owner" {
  description = "GitHub username or organization name"
  type        = string
  default     = "cwattstubes"  # Replace with your GitHub username or organization
}

# Domain for ArgoCD Ingress
variable "argocd_domain" {
  description = "The domain name for accessing ArgoCD"
  type        = string
  default     = "argocd.k8s.yourdomain.com"  # Replace with your domain
}

# Path to SSH private key for ArgoCD access (if using an existing key)
variable "ssh_private_key_path" {
  description = "The path to the SSH private key file for ArgoCD (leave empty if generating a new key)"
  type        = string
  default     = ""  # Leave empty if using generated SSH keys
}

# Kubernetes Namespace for ArgoCD
variable "argocd_namespace" {
  description = "Namespace in Kubernetes where ArgoCD is installed"
  type        = string
  default     = "argocd"
}

# Ingress TLS Secret Name (optional, if using HTTPS)
variable "tls_secret_name" {
  description = "Name of the TLS secret for ArgoCD ingress"
  type        = string
  default     = "argocd-tls"  # Adjust if using a different TLS secret
}
