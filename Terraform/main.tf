terraform {
  required_providers {
    proxmox = {
      source = "Telmate/proxmox"
      version = "2.9.6"
    }
  }
}

provider "proxmox" {
  pm_api_url = "https://192.168.1.2:8006/api2/json"
  pm_user="terraform-prov@pve"
  pm_password="terraform"
}

locals {
  vm_names = toset([
    "k3s-master",
    "k3s-worker",
  ])
}

resource "proxmox_vm_qemu" "k3s_cluster" {
    for_each = local.vm_names
    name        = each.key
    target_node = "factory"
    clone = "New-Template"
    memory = 2048
    oncreate = true
    onboot = true
    pool = "Projet-Infra"
    agent = 1
    nameserver = "192.168.10.253"
    network {
        bridge    = "vmbr2"
        tag = 10
        firewall  = false
        link_down = false
        model     = "virtio"
    }
    disk {
      type = "virtio"
      storage = "DATA"
      size = "32G"
    }
}

output "instance_ips_master" {
  value = proxmox_vm_qemu.k3s_cluster["k3s-master"].default_ipv4_address
}

output "instance_ips_worker" {
  value = proxmox_vm_qemu.k3s_cluster["k3s-worker"].default_ipv4_address
}