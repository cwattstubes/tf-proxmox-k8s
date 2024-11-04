# nginx_ingress.tf
provider "kubernetes" {
  config_path = local_file.kubeconfig_file.filename
}

provider "helm" {
  kubernetes {
    config_path = local_file.kubeconfig_file.filename
  }
}

provider "github" {
  token = var.github_token  # Use a personal access token with repo and admin:public_key scopes
  owner = var.github_owner
}


# Ensure the cluster is in a healthy state before proceeding with namespace creation
resource "kubernetes_namespace" "ingress_nginx" {
  metadata {
    name = "ingress-nginx"
    labels = {
      "pod-security.kubernetes.io/enforce" = "privileged"
      "pod-security.kubernetes.io/audit"   = "privileged"
      "pod-security.kubernetes.io/warn"    = "privileged"
    }
  }
  depends_on = [data.talos_cluster_health.health, local_file.kubeconfig_file, proxmox_virtual_environment_vm.talos_worker]

}

# Helm release for NGINX ingress, waits on namespace creation and cluster readiness
resource "helm_release" "nginx_ingress" {
  name       = "nginx-ingress"
  namespace  = kubernetes_namespace.ingress_nginx.metadata[0].name
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = "4.7.0"  # Specify the chart version you want

  # Set custom Helm values for the NGINX ingress configuration
  set {
    name  = "controller.kind"
    value = "DaemonSet"
  }

  #set {
  #  name  = "controller.hostNetwork"
  #  value = "true"
  #}
  set {
    name  = "controller.service.type"
    value = "NodePort"
  }
  set {
    name  = "controller.service.nodePorts.http"
    value = "30080"
  }

  set {
    name  = "controller.service.nodePorts.https"
    value = "30443"
  }

  set {
    name  = "controller.daemonset.useHostPort"
    value = "true"
  }

  set {
    name  = "controller.publishService.enabled"
    value = "false"
  }

  set {
    name  = "controller.admissionWebhooks.enabled"
    value = "false"
  }

  depends_on = [kubernetes_namespace.ingress_nginx]  # Wait for namespace before Helm release
}

# Helm Release for metrics api
resource "helm_release" "metrics_server" {
  name       = "metrics-server"
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"
  namespace  = "kube-system"
  version    = "3.10.0"  # Specify the version as needed

  set {
    name  = "args[0]"
    value = "--kubelet-insecure-tls"
  }

  set {
    name  = "args[1]"
    value = "--kubelet-preferred-address-types=InternalIP"
  }

  #depends_on = [kubernetes_namespace.kube_system]  # Ensure kube-system namespace exists
  depends_on = [data.talos_cluster_health.health, local_file.kubeconfig_file, proxmox_virtual_environment_vm.talos_worker]
}

#### ArgoCD

# Ensure the cluster is in a healthy state before proceeding with namespace creation
resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
    labels = {
      "pod-security.kubernetes.io/enforce" = "privileged"
      "pod-security.kubernetes.io/audit"   = "privileged"
      "pod-security.kubernetes.io/warn"    = "privileged"
    }
  }
  depends_on = [data.talos_cluster_health.health, local_file.kubeconfig_file, proxmox_virtual_environment_vm.talos_worker]

}

resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  namespace  = "argocd"

  #create_namespace = true  # Creates the namespace if it doesn’t exist

  values = [file("${path.module}/Charts/argocd/values.yaml")]  # Point to your custom values.yaml file


  depends_on = [kubernetes_secret.argocd_ssh_key, data.talos_cluster_health.health, local_file.kubeconfig_file, proxmox_virtual_environment_vm.talos_worker]
}


data "kubernetes_secret" "argocd_initial_admin_secret" {
  metadata {
    name      = "argocd-initial-admin-secret"
    namespace = "argocd"
  }
  depends_on = [helm_release.argocd]
}

output "argocd_admin_password" {
  value     = data.kubernetes_secret.argocd_initial_admin_secret.data["password"]
  sensitive = true
}

# Generate SSH key pair
resource "tls_private_key" "argocd_ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Kubernetes Secret for the SSH private key
resource "kubernetes_secret" "argocd_ssh_key" {
  metadata {
    name      = "argocd-ssh-key"
    namespace = "argocd"
    labels = {
      "argocd.argoproj.io/secret-type" = "repository"
    }
  }

#  data = {
#    sshPrivateKey = (tls_private_key.argocd_ssh_key.private_key_pem)
#  }
  data = {
    type          = ("git")
    url           = ("git@github.com:cwattstubes/argocd.git")
    sshPrivateKey = <<-EOF
       ${tls_private_key.argocd_ssh_key.private_key_pem}
      EOF
  }
  type = "Opaque"
}

# Output the public key to add to the Git provider
output "argocd_ssh_public_key" {
  value     = tls_private_key.argocd_ssh_key.public_key_openssh
  sensitive = true
}

output "argocd_private_key" {
  value     = tls_private_key.argocd_ssh_key.private_key_pem
  sensitive = true
}


# GitHub Deploy Key
resource "github_repository_deploy_key" "argocd_deploy_key" {
  depends_on = [tls_private_key.argocd_ssh_key]
  repository = var.github_repo_name  # Replace with your GitHub repository
  title      = "ArgoCD Deploy Key"
  key        = tls_private_key.argocd_ssh_key.public_key_openssh
  read_only  = true
}




