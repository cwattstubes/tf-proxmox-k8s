tf-proxmox-k8s: Terraform for Deploying Kubernetes on Proxmox
This repository provides Terraform configurations to automate the deployment of a Kubernetes (K8s) cluster on a Proxmox Virtual Environment (PVE). By leveraging Terraform, users can define and manage their infrastructure as code, ensuring consistent and repeatable deployments.

Features
Automated VM Provisioning: Utilizes the Proxmox provider to create virtual machines tailored for Kubernetes nodes.
Cluster Configuration: Defines the desired state of the Kubernetes cluster, including the number of master and worker nodes.
Add-ons Management: Supports the deployment of additional Kubernetes components and services.
Prerequisites
Before using this repository, ensure the following:

Proxmox VE: A running instance of Proxmox Virtual Environment with API access enabled.
Terraform: Installed on your local machine.
Proxmox Provider for Terraform: Configured to interact with your Proxmox VE instance.


Repository Structure
main.tf: Entry point for Terraform configuration, orchestrating the deployment process.
providers.tf: Specifies the required providers and their configurations.
variables.tf: Declares variables used throughout the Terraform scripts.
vm.tf: Contains definitions for virtual machine resources.
cluster.tf: Configures the Kubernetes cluster settings.
cluster-addons.tf: Manages additional Kubernetes components and services.
files.tf: Handles file provisioning and templates.
.gitignore: Lists files and directories to be ignored by Git.
