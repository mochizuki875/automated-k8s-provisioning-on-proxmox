# Terragrunt root configuration
# このファイルは全てのクラスタで共通の設定を定義

# Proxmox API設定(環境変数から取得)
inputs = {
  proxmox_api_url      = "https://pve01.local:8006/api2/json"
  proxmox_tls_insecure = true
  
  # VM共通設定
  vm_spec = {
    storage        = "local-lvm"
    network_bridge = "vmbr0"
  }
}
