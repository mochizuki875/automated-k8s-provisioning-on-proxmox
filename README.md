# Automated Kubernetes Provisioning on Proxmox
- `ansible/create-proxmox-template`: VM templateの作成
- `terraform`: Proxmox上にKubernetesクラスタ用VMを作成
- `ansible/install-kubeadm`: VMへのソフトウェアインストールと設定(`kubeadm init`の直前まで)