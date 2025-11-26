# Ansible Playbooks for Proxmox Template Management
Proxmoxクラスタの各ノードにCloud-initテンプレートを作成するためのAnsible playbook。

## ファイル構成
```
ansible/create-proxmox-template/
├── README.md              
├── inventory.ini          # Proxmoxノードのインベントリ
├── create-template.yml    # テンプレート作成playbook
├── delete-template.yml    # テンプレート削除playbook
└── group_vars/            
    └── all.yml            # 変数設定
```

## セットアップ
### 1. Ansibleのインストール
[Installing Ansible on Ubuntu](https://docs.ansible.com/projects/ansible/latest/installation_guide/installation_distros.html#installing-ansible-on-ubuntu)

```bash
sudo apt update
sudo apt install -y software-properties-common
sudo add-apt-repository --yes --update ppa:ansible/ansible
sudo apt install -y ansible
```

### 2. SSH鍵認証の設定
ProxmoxノードへパスワードなしでSSH接続できるように設定。

```bash
# SSH鍵がない場合は生成
ssh-keygen

# 各Proxmoxノードに公開鍵をコピー
ssh-copy-id root@pve01.local
ssh-copy-id root@pve02.local
ssh-copy-id root@pve03.local

# 事前接続&確認
ssh root@pve01.local "hostname"
ssh root@pve02.local "hostname"
ssh root@pve03.local "hostname"
```

### 3. インベントリファイル/変数ファイル作成
- `inventory.ini`
- `group_vars/all.yml`

### 4. 疎通確認
Ansibleから各Proxmoxノードへの接続を確認。

```bash
# Ping疎通確認
ansible proxmox_nodes -i inventory.ini -m ping
```

## 使用方法
### テンプレート作成
全ノードに一括でテンプレートを作成。

```bash
ansible-playbook -i inventory.ini create-template.yml
```

### テンプレート削除
全ノードからテンプレートを削除。

```bash
ansible-playbook -i inventory.ini delete-template.yml
```

## 参考
- [Ansible Documentation](https://docs.ansible.com/)
- [virt-customize Documentation](https://libguestfs.org/virt-customize.1.html)
- [Proxmox VE qm Command Reference](https://pve.proxmox.com/pve-docs/qm.1.html)
