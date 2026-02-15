# Cilium
## Install
https://docs.cilium.io/en/v1.12/gettingstarted/k8s-install-helm/
https://github.com/cilium/cilium/tree/main/install/kubernetes/cilium
https://docs.cilium.io/en/stable/network/concepts/ipam/

## kube-proxy-less
https://docs.cilium.io/en/stable/network/kubernetes/kubeproxy-free/

## Cilium LoadBalancer
https://docs.cilium.io/en/stable/network/lb-ipam/
https://docs.cilium.io/en/stable/network/l2-announcements/

```bash
kubectl apply -f cilium-loadbalancer-ip-pool.yaml
kubectl apply -f cilium-l2announcement-policy.yaml
```

## Gateway API Support
https://docs.cilium.io/en/stable/network/servicemesh/gateway-api/gateway-api/

Gateway API CRDのインストール
[kubernetes-sigs/gateway-api](https://github.com/kubernetes-sigs/gateway-api)で提供されているマニフェストを使う
※先にCRDをインストールしてからCiliumをインストールしないとGatewayClassが作成されないので注意
```bash
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.2.1/standard-install.yaml
```