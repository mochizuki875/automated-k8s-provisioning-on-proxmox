# Terragrunt configuration for cluster3
terraform {
  source = "../../modules/k8s-cluster"
}

# 親設定を継承
include "root" {
  path = find_in_parent_folders("root.hcl")
}

# cluster3固有の設定
inputs = {
  # 使用するテンプレート
  template_name = "ubuntu-2404-cloudinit-template"
  
  # ControlPlaneノードのデフォルトスペック
  cp_spec = {
    cores     = 4
    sockets   = 1
    memory    = 8192
    disk_size = "64G"
  }
  
  # Nodeのデフォルトスペック
  node_spec = {
    cores     = 8
    sockets   = 1
    memory    = 16384
    disk_size = "128G"
  }
  
  # VM定義
  vms = [
    # ControlPlaneノード
    {
      name        = "cluster3-cp-01"
      target_node = "pve01"
      vm_id       = 401
      ip_address  = "192.168.1.301"
      role        = "ControlPlane"
    },
    # Nodeノード
    {
      name        = "cluster3-node-01"
      target_node = "pve02"
      vm_id       = 411
      ip_address  = "192.168.1.311"
      role        = "Node"
    },
    {
      name        = "cluster3-node-02"
      target_node = "pve03"
      vm_id       = 412
      ip_address  = "192.168.1.312"
      role        = "Node"
    },
    {
      name        = "cluster3-node-03"
      target_node = "pve01"
      vm_id       = 413
      ip_address  = "192.168.1.313"
      role        = "Node"
    }
  ]
}
