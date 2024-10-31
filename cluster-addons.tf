# nginx_ingress.tf
provider "kubernetes" {
  config_path = local_file.kubeconfig_file.filename
}

provider "helm" {
  kubernetes {
    config_path = local_file.kubeconfig_file.filename
  }
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

