# Rook Ceph Setup

全てのNodeでディレクトリを作成。
```bash
mkdir -p /var/lib/rook
```

インストール
```bash
helmfile apply
```

Cephクラスタを作成
```bash
kubectl apply -f cluste.yaml
```