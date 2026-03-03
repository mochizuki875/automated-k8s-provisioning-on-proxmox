# loki

## 概要

[Grafana Loki](https://github.com/grafana/loki/tree/main/production/helm/loki) Helm Chart を使用してログ収集・保存システムをデプロイします。

**Monolithic (SingleBinary) モード**でインストールします。全てのコンポーネントが1つのプロセスで動作するため、小規模なクラスタに適しています。

## バージョン

| Chart | App |
|-------|-----|
| 6.53.0 | 3.6.5 |

## インストール

```bash
cd loki/
helmfile apply
```

## デプロイモード

- **deploymentMode**: `SingleBinary` (Monolithic モード)
- 全 Loki コンポーネント (distributor, ingester, querier, ruler 等) が単一プロセスで動作
- 分散コンポーネント (read/write/backend) は無効化済み
- Nginx Gateway は無効化済み (直接サービスURLでアクセス)

## ストレージ設定

| 設定 | 値 |
|-----|-----|
| ストレージタイプ | filesystem (ローカルファイルシステム) |
| データパス | `/var/loki/chunks` |
| StorageClass | proxmox-data |
| PVC サイズ | 10Gi |
| スキーマ | v13 (TSDB) |

## サービス URL

```
http://loki.monitoring.svc.cluster.local:3100
```

Grafana Datasource (victoria-metrics チャート側) からこの URL でアクセスします。

## ログ収集

Loki 自体はログを収集しません。別途ログ収集エージェントが必要です:
- **Promtail**: Kubernetes Pod のログを収集して Loki に送信
- **Grafana Alloy** (旧 Grafana Agent): OpenTelemetry ベースのログ収集
- **Fluent Bit**: 高パフォーマンスなログ転送エージェント

ログを Loki に送信する際、トレース相関のためにログに `traceID` フィールドを含めることを推奨します。

## Grafana との連携

Grafana の Loki Datasource で以下の設定が有効になっています:

- **Derived Fields**: ログ内の `traceID=<hex>` パターンを検出して Tempo トレースへのリンクを生成
  - パターン: `(?:traceID|trace_id|traceId)[=: ]+([a-fA-F0-9]{32})`

## 注意事項

- SingleBinary モードはログ取り込み量が少ない環境向けです
- 高トラフィック環境では `deploymentMode: SimpleScalable` への変更を検討してください
- `loki.auth_enabled: false` のため、全テナントのログにアクセス可能です
