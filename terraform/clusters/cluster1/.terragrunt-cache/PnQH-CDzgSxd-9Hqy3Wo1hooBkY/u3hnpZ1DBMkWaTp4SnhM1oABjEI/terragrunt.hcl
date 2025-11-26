# Terragrunt configuration for cluster1
terraform {
  source = "../../modules/k8s-cluster"
}

# 親設定を継承
include "root" {
  path = find_in_parent_folders("root.hcl")
}

# cluster1固有の設定
inputs = {
  # デフォルトユーザー
  default_user = "k8s-user"
  default_password = "password"

  # SSH公開鍵(不要な場合は空配列)
  ssh_public_keys = []
  
  # ネットワーク共通設定
  network_config = {
    gateway    = "192.168.2.1"
    nameserver = "192.168.2.1"
    domain     = "local"
  }

  # 使用するテンプレート
  template_name = "ubuntu-2404-cloudinit-template"
  
  # ControlPlaneノードのデフォルトスペック
  cp_spec = {
    cores     = 2
    sockets   = 1
    memory    = 4096
    disk_size = "50G"
  }
  
  # Nodeのデフォルトスペック
  node_spec = {
    cores     = 4
    sockets   = 1
    memory    = 8192
    disk_size = "50G"
  }
  
  # VM定義
  vms = [
    # ControlPlaneノード
    {
      name        = "k8s-cluster1-cp01"
      target_node = "pve01"
      vm_id       = 101
      ip_address  = "192.168.2.120"
      role        = "ControlPlane"
    },
    # Nodeノード
    {
      name        = "k8s-cluster1-node01"
      target_node = "pve01"
      vm_id       = 102
      ip_address  = "192.168.2.121"
      role        = "Node"
    },
    {
      name        = "k8s-cluster1-node02"
      target_node = "pve01"
      vm_id       = 103
      ip_address  = "192.168.2.122"
      role        = "Node"
    }
  ]
}
