# victoria-metrics-k8s-stack

## 概要

[victoria-metrics-k8s-stack](https://github.com/VictoriaMetrics/helm-charts/tree/master/charts/victoria-metrics-k8s-stack) Helm Chart を使用してKubernetesクラスタのメトリクス監視スタックをデプロイします。

以下のコンポーネントが含まれます:
- **VictoriaMetrics Single Server**: 高性能な時系列データベース (Prometheus 互換)
- **Grafana**: メトリクス・ログ・トレースの可視化ダッシュボード
- **vmalert**: アラートルール評価エンジン
- **vmagent**: メトリクス収集エージェント (Kubernetes メトリクスのスクレイプ)
- **kube-state-metrics**: Kubernetes リソース状態のメトリクスエクスポーター
- **node-exporter**: ノードレベルのハードウェア/OS メトリクスエクスポーター
- **victoria-metrics-operator**: VictoriaMetrics CR を管理するオペレーター

## バージョン

| Chart | App |
|-------|-----|
| 0.84.0 | v1.145.0 |

## インストール

```bash
cd victoria-metrics/
helmfile apply

> リリース名は `vm` です（ネーミング63文字制限のため短縮）
```

`helmfile.yaml` の `presync` hook で chart 同梱 CRD を毎回 `kubectl apply` します。
VictoriaMetrics Operator は chart upgrade 時に CRD 追加を伴うことがあり、Helm upgrade 単体では既存 CRD が更新されないためです。

## Datasource 設定 (相関分析)

Grafana には以下の Datasource が自動的にプロビジョニングされます:

| Datasource | UID | URL | 用途 |
|-----------|-----|-----|------|
| VictoriaMetrics | `victoriametrics` | 自動設定 | メトリクス参照 |
| VictoriaMetrics (DS) | `victoriametrics-ds` | 自動設定 | VM ネイティブクエリ |
| Loki | `loki` | `http://loki.monitoring.svc.cluster.local:3100` | ログ参照 |
| Tempo | `tempo` | `http://tempo.monitoring.svc.cluster.local:3200` | トレース参照 |

### 相関分析の仕組み

1. **メトリクス → トレース** (レイテンシメトリクスから Trace を参照)
   - VictoriaMetrics datasource に `exemplarTraceIdDestinations` を設定
   - Prometheus exemplar の `traceID`/`trace_id` ラベルから Tempo へジャンプ可能

2. **ログ → トレース** (エラーログから Trace を参照)
   - Loki datasource に `derivedFields` を設定
   - ログ内の `traceID=<32文字16進数>` パターンを検出して Tempo へジャンプ可能

3. **トレース → メトリクス**
   - Tempo datasource に `tracesToMetrics` を設定
   - トレースから該当サービスのスパンメトリクスへジャンプ可能

4. **トレース → ログ**
   - Tempo datasource に `tracesToLogsV2` を設定
   - トレースから該当時間帯・サービスのログへジャンプ可能

datasource の定義本体は [services/k8s-monitoring-stack/victoria-metrics/values.yaml](services/k8s-monitoring-stack/victoria-metrics/values.yaml) の `grafana.datasources` にあります。

## ストレージ設定

| コンポーネント | StorageClass | サイズ |
|-------------|-------------|--------|
| VictoriaMetrics | proxmox-data | 20Gi |
| Grafana | proxmox-data | 5Gi |

## Grafana アクセス

デフォルトポートフォワードでアクセス:

```bash
kubectl port-forward -n monitoring svc/victoria-metrics-grafana 3000:80
```

ブラウザで http://localhost:3000 を開く

- ユーザー名: `admin`
- パスワード: `admin-password` (**本番環境では必ず変更すること**)

## Scrapeの追加
`VMServiceScrape`や`VMStaticScrape`といったリソースを作成することでスクレイプ対象を追加できる。

- [VMServiceScrape](https://docs.victoriametrics.com/operator/resources/vmservicescrape/)
- [VMStaticScrape](https://docs.victoriametrics.com/operator/resources/vmstaticscrape/)

## 注意事項

- `grafana.adminPassword` は本番環境では Kubernetes Secret を参照するよう変更してください
- `vmsingle.spec.retentionPeriod` はデータ保持要件に応じて調整してください
