provider "proxmox" {
  pm_api_url          = var.proxmox_api_url
  pm_api_token_id     = var.PROXMOX_API_TOKEN_ID
  pm_api_token_secret = var.PROXMOX_API_TOKEN
  pm_tls_insecure     = var.proxmox_tls_insecure
  pm_parallel         = 3
  pm_timeout          = 600
}

resource "proxmox_vm_qemu" "k8s_vms" {
  for_each = { for vm in var.vms : vm.name => vm }

  # 基本設定
  name        = each.value.name
  target_node = each.value.target_node
  vmid        = each.value.vm_id
  description = "Kubernetes ${each.value.role} node - Managed by Terraform"
  
  # テンプレートからクローン
  clone      = var.template_name
  full_clone = true
  
  # VM起動設定
  start_at_node_boot = true
  agent              = 1
  boot               = "order=scsi0"
  
  # SCSIコントローラー設定
  scsihw = "virtio-scsi-single"
  
  # Cloud-init設定
  os_type      = "cloud-init"
  ipconfig0    = "ip=${each.value.ip_address}/24,gw=${var.network_config.gateway}"
  nameserver   = var.network_config.nameserver
  searchdomain = var.network_config.domain
  ciuser       = var.default_user
  cipassword   = var.default_password
  sshkeys      = length(var.ssh_public_keys) > 0 ? join("\n", var.ssh_public_keys) : ""
  
  # CPU設定
  cpu {
    cores   = coalesce(
      each.value.cores,
      each.value.role == "ControlPlane" ? var.cp_spec.cores : var.node_spec.cores
    )
    sockets = coalesce(
      each.value.sockets,
      each.value.role == "ControlPlane" ? var.cp_spec.sockets : var.node_spec.sockets
    )
  }
  
  # メモリ設定
  memory = coalesce(
    each.value.memory,
    each.value.role == "ControlPlane" ? var.cp_spec.memory : var.node_spec.memory
  )
  
  # ディスク設定
  disks {
    scsi {
      scsi0 {
        disk {
          storage  = var.vm_spec.storage
          size     = coalesce(
            each.value.disk1_size,
            each.value.role == "ControlPlane" ? var.cp_spec.disk1_size : var.node_spec.disk1_size
          )
          iothread = true
        }
      }
      scsi1 {
        disk {
          storage  = var.vm_spec.storage
          size     = coalesce(
            each.value.disk2_size,
            each.value.role == "ControlPlane" ? var.cp_spec.disk2_size : var.node_spec.disk2_size
          )
          iothread = true
        }
      }
    }
    ide {
      ide2 {
        cloudinit {
          storage = var.vm_spec.storage
        }
      }
    }
  }
  
  # ネットワーク設定
  network {
    id     = 0
    model  = "virtio"
    bridge = var.vm_spec.network_bridge
    tag    = var.vm_spec.vlan_tag
  }
  
  # タグ設定
  tags = join(";", compact([
    "kubernetes",
    each.value.role != null ? lower(each.value.role) : null,
    "terraform"
  ]))
  
  # ライフサイクル設定
  lifecycle {
    ignore_changes = [
      network,
    ]
  }
}
