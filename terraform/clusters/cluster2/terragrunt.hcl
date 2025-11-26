# Terragrunt configuration for cluster2
terraform {
  source = "../../modules/k8s-cluster"
}

# 親設定を継承
include "root" {
  path = find_in_parent_folders("root.hcl")
}

# cluster2固有の設定
inputs = {
  # 使用するテンプレート
  template_name = "ubuntu-2404-cloudinit-template"
  
  # ControlPlaneノードのデフォルトスペック
  cp_spec = {
    cores     = 2
    sockets   = 1
    memory    = 4096
    disk_size = "32G"
  }
  
  # Nodeのデフォルトスペック
  node_spec = {
    cores     = 2
    sockets   = 1
    memory    = 4096
    disk_size = "32G"
  }
  
  # VM定義
  vms = [
    # ControlPlaneノード
    {
      name        = "cluster2-cp-01"
      target_node = "pve01"
      vm_id       = 301
      ip_address  = "192.168.1.201"
      role        = "ControlPlane"
    },
    # Nodeノード
    {
      name        = "cluster2-node-01"
      target_node = "pve02"
      vm_id       = 311
      ip_address  = "192.168.1.211"
      role        = "Node"
    }
  ]
}
