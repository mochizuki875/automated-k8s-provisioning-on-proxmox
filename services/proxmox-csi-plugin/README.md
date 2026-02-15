# Proxmox CSI Plugin

- [Install plugin](https://github.com/sergelogvinov/proxmox-csi-plugin/blob/main/docs/install.md)

## Prerequirements
ProxmoxのAPIにアクセスするためのAPI Tokenを作成する。
```bash
pveum role add CSI -privs "VM.Audit VM.Allocate VM.Clone VM.Config.CPU VM.Config.Disk VM.Config.HWType VM.Config.Memory VM.Config.Options VM.Migrate VM.PowerMgmt Datastore.Allocate Datastore.AllocateSpace Datastore.Audit"
pveum user add kubernetes-csi@pve
pveum aclmod / -user kubernetes-csi@pve -role CSI
pveum user token add kubernetes-csi@pve csi -privsep 0


┌──────────────┬──────────────────────────────────────┐
│ key          │ value                                │
╞══════════════╪══════════════════════════════════════╡
│ full-tokenid │ kubernetes-csi@pve!csi               │
├──────────────┼──────────────────────────────────────┤
│ info         │ {"privsep":"0"}                      │
├──────────────┼──────────────────────────────────────┤
│ value        │ xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx │
└──────────────┴──────────────────────────────────────┘
```


Nodeにラベルを設定する。
```bash
kubectl label node k8s-cluster1-cp01 topology.kubernetes.io/region=pve-cluster
kubectl label node k8s-cluster1-node01 topology.kubernetes.io/region=pve-cluster
kubectl label node k8s-cluster1-node02 topology.kubernetes.io/region=pve-cluster
kubectl label node k8s-cluster1-node03 topology.kubernetes.io/region=pve-cluster

# VMが存在するProxmox Nodeを指定
kubectl label node k8s-cluster1-cp01 topology.kubernetes.io/zone=pve01
kubectl label node k8s-cluster1-node01 topology.kubernetes.io/zone=pve01
kubectl label node k8s-cluster1-node02 topology.kubernetes.io/zone=pve01
kubectl label node k8s-cluster1-node03 topology.kubernetes.io/zone=pve01
```

## Create values.yaml

`values.yaml`
```yaml
config:
  clusters:
    - url: https://pve01.local:8006/api2/json
      insecure: true
      token_id: "kubernetes-csi@pve!csi"
      token_secret: "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
      region: pve-cluster
    - url: https://pve02.local:8006/api2/json
      insecure: true
      token_id: "kubernetes-csi@pve!csi"
      token_secret: "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
      region: pve-cluster
    - url: https://pve03.local:8006/api2/json
      insecure: true
      token_id: "kubernetes-csi@pve!csi"
      token_secret: "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
      region: pve-cluster

storageClass:
  - name: proxmox-data-xfs
    storage: local-lvm
    reclaimPolicy: Delete
    fstype: xfs
    # ssd: "true"
  - name: proxmox-data
    storage: local-lvm
    reclaimPolicy: Delete
    fstype: ext4
    cache: writethrough
    # ssd: "true"

hostAliases:
  - ip: 192.168.2.171
    hostnames:
    - pve-cluster.local
    - pve01.local
  - ip: 192.168.2.172
    hostnames:
    - pve-cluster.local
    - pve02.local
  - ip: 192.168.2.173
    hostnames:
    - pve-cluster.local
    - pve03.local

# Deploy CSI controller only on control-plane nodes
nodeSelector:
  node-role.kubernetes.io/control-plane: ""
tolerations:
  - key: node-role.kubernetes.io/control-plane
    effect: NoSchedule
```


## Install
インストール
```bash
helmfile apply
```