# tempo

## 概要

[Grafana Tempo](https://github.com/grafana-community/helm-charts/tree/main/charts/tempo) Helm Chart を使用して分散トレーシングシステムをデプロイします。

**Single Binary モード**でインストールします。Metrics Generator を有効化し、サービスグラフ・スパンメトリクスを VictoriaMetrics に送信します。

## バージョン

| Chart | App |
|-------|-----|
| 1.26.5 | 2.10.1 |

## インストール

```bash
cd tempo/
helmfile apply
```

## 機能

### トレースレシーバー

| プロトコル | ポート | 用途 |
|-----------|-------|------|
| OTLP gRPC | 4317 | OpenTelemetry トレース受信 |
| OTLP HTTP | 4318 | OpenTelemetry トレース受信 |
| Jaeger gRPC | 14250 | Jaeger トレース受信 |
| Jaeger Thrift HTTP | 14268 | Jaeger トレース受信 |
| Jaeger Thrift Compact | 6831/UDP | Jaeger トレース受信 |
| Jaeger Thrift Binary | 6832/UDP | Jaeger トレース受信 |

### Metrics Generator

Tempo の Metrics Generator を有効化しています。収集されたトレースから以下を自動生成し、VictoriaMetrics に送信します:

- **service-graphs**: サービス間の依存関係グラフメトリクス
  - `traces_service_graph_request_total`
  - `traces_service_graph_request_failed_total`
  - `traces_service_graph_request_server_seconds_{bucket,sum,count}`
- **span-metrics**: スパンレベルのメトリクス
  - `traces_spanmetrics_calls_total`
  - `traces_spanmetrics_duration_seconds_{bucket,sum,count}`

これらのメトリクスにより Grafana の **サービスグラフ (Service Map)** 機能が利用可能になります。

## ストレージ設定

| 設定 | 値 |
|-----|-----|
| トレースストレージ | ローカルファイルシステム |
| データパス | `/var/tempo/traces` |
| WAL パス | `/var/tempo/wal` |
| メトリクスパス | `/var/tempo/metrics` |
| StorageClass | proxmox-data |
| PVC サイズ | 10Gi |
| データ保持期間 | 24h |

## サービス URL

```
# HTTP API (Grafana Tempo Datasource)
http://tempo.monitoring.svc.cluster.local:3200

# OTLP gRPC (トレース送信)
tempo.monitoring.svc.cluster.local:4317

# OTLP HTTP (トレース送信)
http://tempo.monitoring.svc.cluster.local:4318
```

## VictoriaMetrics への Remote Write

Metrics Generator は以下の URL にメトリクスを送信します:

```
http://vmsingle-victoria-metrics-victoria-metrics-k8s-stack.monitoring.svc.cluster.local:8428/api/v1/write
```

> **注意**: このURLは victoria-metrics チャートを release 名 `victoria-metrics` でインストールした場合の VMSingle サービス名です。

## Grafana との連携

Tempo Datasource (victoria-metrics チャート側) から以下の連携が設定されています:

- **tracesToLogsV2**: トレースから Loki ログへのリンク
- **tracesToMetrics**: トレースから VictoriaMetrics スパンメトリクスへのリンク
- **serviceMap**: VictoriaMetrics のサービスグラフメトリクスを表示
- **nodeGraph**: ノードグラフ表示

## トレース送信設定例 (OpenTelemetry SDK)

```yaml
# OpenTelemetry Collector 設定例
exporters:
  otlp:
    endpoint: "tempo.monitoring.svc.cluster.local:4317"
    tls:
      insecure: true
```

## 注意事項

- `tempo.retention: 24h` はトレースデータ保持要件に応じて調整してください
- Metrics Generator の remote_write URL は victoria-metrics チャートのリリース名に依存します
- Production環境では S3/GCS 等のオブジェクトストレージを使用することを推奨します
