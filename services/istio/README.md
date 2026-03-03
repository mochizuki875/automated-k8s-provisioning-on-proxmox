# Istio

```bash
istioctl install -f istiooperator.yaml
```


Ciliumとあわせて使う時はCilium側で以下の設定が必要
Ciliumの必須要件（kubeProxyReplacement: true の場合）:

| 設定                                 | 要件   |
| ---------------------------------- | ---- |
| `kubeProxyReplacement: true`       | ✅ 必須 |
| `cni.exclusive: false`             | ✅ 必須 |
| `socketLB.hostNamespaceOnly: true` | ✅ 必須 |
