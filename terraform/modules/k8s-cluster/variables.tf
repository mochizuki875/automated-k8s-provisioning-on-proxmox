# Proxmox接続設定
variable "proxmox_api_url" {
  description = "Proxmox API URL (例: https://pve01.local:8006/api2/json)"
  type        = string
}

variable "PROXMOX_API_TOKEN_ID" {
  description = "Proxmox APIトークンID (例: terraform@pve!terraform, 環境変数 TF_VAR_PROXMOX_API_TOKEN_ID から自動取得)"
  type        = string
}

variable "PROXMOX_API_TOKEN" {
  description = "Proxmox APIトークンシークレット (環境変数 TF_VAR_PROXMOX_API_TOKEN から自動取得)"
  type        = string
  sensitive   = true
}

variable "proxmox_tls_insecure" {
  description = "TLS証明書の検証をスキップするかどうか"
  type        = bool
  default     = true
}

variable "default_user" {
  description = "デフォルトユーザー名"
  type        = string
  default     = "k8s-user"
}

variable "default_password" {
  description = "デフォルトユーザーのパスワード"
  type        = string
  sensitive   = true
  default     = "password"
}

# SSH設定
variable "ssh_public_keys" {
  description = "VMに設定するSSH公開鍵のリスト"
  type        = list(string)
  default     = []
}

# VMテンプレート設定
variable "template_name" {
  description = "使用するVMテンプレート名"
  type        = string
  default     = "ubuntu-2404-cloudinit-template"
}

# ネットワーク設定
variable "network_config" {
  description = "ネットワーク設定"
  type = object({
    gateway    = string
    nameserver = string
    domain     = optional(string)
  })
}

# VM共通設定
variable "vm_spec" {
  description = "VM共通設定"
  type = object({
    storage        = string
    network_bridge = string
    vlan_tag       = optional(number)
  })
  default = {
    storage        = "local-lvm"
    network_bridge = "vmbr0"
  }
}

# ControlPlaneノードのデフォルト設定
variable "cp_spec" {
  description = "ControlPlaneノードのデフォルトスペック"
  type = object({
    cores     = number
    sockets   = number
    memory    = number
    disk_size = string
  })
  default = {
    cores     = 2
    sockets   = 1
    memory    = 4096
    disk_size = "50G"
  }
}

# Nodeのデフォルト設定
variable "node_spec" {
  description = "Nodeのデフォルトスペック"
  type = object({
    cores     = number
    sockets   = number
    memory    = number
    disk_size = string
  })
  default = {
    cores     = 4
    sockets   = 1
    memory    = 8192
    disk_size = "50G"
  }
}

# VM定義
variable "vms" {
  description = "作成するVMのリスト"
  type = list(object({
    name        = string
    target_node = string
    vm_id       = number
    ip_address  = string
    role        = string          # "ControlPlane" または "Node"
    cores       = optional(number)
    sockets     = optional(number)
    memory      = optional(number)
    disk_size   = optional(string)
  }))
}
