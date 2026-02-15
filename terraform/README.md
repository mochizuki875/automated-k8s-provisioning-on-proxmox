# Proxmox Kubernetes自動構築環境
TerragruntとTerraformを使用してProxmox上にKubernetesクラスタ用のVMを自動構築。

## ファイル構成
```
terraform/
├── terragrunt.hcl                       # 全クラスタ共通設定
├── .env.example                         # 環境変数テンプレート
├── .gitignore                           # Git無視設定
├── README.md                            
├── modules/                             # 再利用可能なモジュール
│   └── k8s-cluster/
│       ├── versions.tf                  # Terraform/プロバイダーバージョン設定
│       ├── variables.tf                 # 変数定義
│       ├── main.tf                      # VMリソース定義
│       ├── outputs.tf                   # 出力定義
│       └── templates/
│           └── cloud-init-user-data.yaml  # Cloud-initテンプレート
└── clusters/                            # クラスタ別設定
    ├── cluster1/
    │   └── terragrunt.hcl               # cluster1設定
    ├── cluster2/
    │   └── terragrunt.hcl               # cluster2設定
    └── cluster3/
        └── terragrunt.hcl               # cluster3設定
```

## 前提条件
### Proxmox環境
- Proxmoxバージョン: 9.1.1
- クラスタ構成: pve01, pve02, pve03

### 必要なツール
- Terraform >= 1.9
- Terragrunt >= 0.45
- [telmate/proxmox](https://github.com/Telmate/terraform-provider-proxmox/blob/master/docs/guides/installation.md)

### Proxmox側の準備
#### 1. VMテンプレートの作成
Ansibleで事前に作成。

(参考)Template削除
```bash
qm destroy 9000
```

#### 2. Proxmox APIユーザーとトークンの作成
すべての設定をCLIで実施します。Proxmoxノード上で以下のコマンドを実行。

```bash
# ユーザーを作成 (pveレルム)
pveum user add terraform@pve

# Terraformロールを作成
pveum role add TerraformRole -privs "VM.Allocate VM.Clone VM.Config.CDROM VM.Config.CPU VM.Config.Cloudinit VM.Config.Disk VM.Config.HWType VM.Config.Memory VM.Config.Network VM.Config.Options VM.Audit VM.PowerMgmt VM.Migrate Datastore.AllocateSpace Datastore.Audit Pool.Allocate Sys.Audit Sys.Modify Sys.Console SDN.Use Pool.Audit"

# ユーザーに権限を付与 (パス: /)
pveum aclmod / -user terraform@pve -role TerraformRole

# APIトークンを作成 (Privilege Separation無効)
pveum user token add terraform@pve terraform --privsep 0
```
```bash
┌──────────────┬──────────────────────────────────────┐
│ key          │ value                                │
╞══════════════╪══════════════════════════════════════╡
│ full-tokenid │ terraform@pve!terraform              │
├──────────────┼──────────────────────────────────────┤
│ info         │ {"privsep":"0"}                      │
├──────────────┼──────────────────────────────────────┤
│ value        │ xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx │
└──────────────┴──────────────────────────────────────┘
```

{{collapse(Proxmoxのロールに特定の権限を追加)

```bash
pveum role modify TerraformRole -privs "既存の権限 追加したい権限"
```

例: `Pool.Audit`を追加
```bash
pveum role modify TerraformRole -privs "VM.Allocate VM.Clone VM.Config.CDROM VM.Config.CPU VM.Config.Cloudinit VM.Config.Disk VM.Config.HWType VM.Config.Memory VM.Config.Network VM.Config.Options VM.Audit VM.PowerMgmt VM.Migrate Datastore.AllocateSpace Datastore.Audit Pool.Allocate Sys.Audit Sys.Modify Sys.Console SDN.Use Pool.Audit"
```

}}

APIトークンを環境変数に設定
```bash
export TF_VAR_PROXMOX_API_TOKEN_ID="<full-tokenid>"
export TF_VAR_PROXMOX_API_TOKEN="<value>"
```

## セットアップ手順
### 2. クラスタ設定のカスタマイズ
`terraform/clusters/`配下に構築するクラスタに対応するディレクトリを作成。
作成するディレクトリ配下に`terragrunt.hcl`を作成。

```bash
vim clusters/cluster1/terragrunt.hcl
```

主な設定項目:
- `template_name`: 使用するVMテンプレート
- `cp_spec`: ControlPlaneノードのスペック
- `node_spec`: Nodeのスペック
- `vms`: VM定義（名前、ノード、VM ID、IPアドレス、ロール）


### 3. VMを作成
VMを作成。

```bash
# cluster1をデプロイ
cd clusters/cluster1
terragrunt init
terragrunt plan
terragrunt apply
```

## 作成されるVMの設定内容
### ユーザー設定
- デフォルトユーザー: k8s-user
- パスワード: password
- パスワードなしsudo有効


## VMの削除

```bash
cd clusters/cluster1
terragrunt destroy
```

## 参考
- [Proxmox VE Documentation](https://pve.proxmox.com/wiki/Main_Page)
- [Terraform Proxmox Provider](https://registry.terraform.io/providers/Telmate/proxmox/latest/docs)
- [Terragrunt Documentation](https://terragrunt.gruntwork.io/)
- [Cloud-init Documentation](https://cloudinit.readthedocs.io/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
