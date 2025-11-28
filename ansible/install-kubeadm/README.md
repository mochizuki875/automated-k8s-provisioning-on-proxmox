# Kubernetes Runtime Installation with Ansible
Kubernetesクラスタを構成するVMに必要なコンテナランタイム(containerd、runc、CNIプラグイン)とKubernetesコンポーネント(kubelet、kubeadm、kubectl)をインストール、セットアップする。

## ファイル構造

```
install-kubeadm/
├── clusters/                 # クラスタ毎の設定ディレクトリ
│   └── cluster1/             # cluster1の設定
│       ├── inventory.ini     # ホスト情報と認証設定
│       └── group_vars/
│           └── all.yml       # 変数定義(バージョン、kubeadm設定等)
└── install-k8s-runtime.yml   # メインplaybook
```

## 前提条件
- Ansible 2.9以上がインストールされていること
- 対象のVMにSSH接続できること
- 対象のVMでsudo権限があること

## 設定
### 1. クラスタディレクトリの作成
```bash
# クラスタ用のディレクトリ作成
mkdir -p clusters/cluster1/group_vars
```

### 2. インベントリファイル/変数ファイル作成
- `inventory.ini`
- `group_vars/all.yml`

### 3. SSH鍵認証の設定
対象VMへSSH接続できるように設定。

```bash
# 各Proxmoxノードに公開鍵をコピー
ssh-copy-id k8s-user@192.168.2.120
ssh-copy-id k8s-user@192.168.2.121
ssh-copy-id k8s-user@192.168.2.122

# 事前接続&確認
ssh k8s-user@192.168.2.120 "hostname"
ssh k8s-user@192.168.2.121 "hostname"
ssh k8s-user@192.168.2.122 "hostname"
```

## 実行
### 接続確認
```bash
# cluster1の全ノード
ansible k8s_nodes -i clusters/cluster1/inventory.ini -m ping
```

### 全タスクを実行

```bash
# cluster1に対して実行
ansible-playbook -i clusters/cluster1/inventory.ini install-k8s-runtime.yml
```


## Kubernetesクラスタ構築
```bash
kubeadm init --config kubeadm-config.yaml
mkdir ~/.kube
cp /etc/kubernetes/admin.conf ~/.kube/config
```