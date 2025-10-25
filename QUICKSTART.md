# ⚡ クイックスタートガイド

このガイドでは、最速で Lambda 関数をローカルで動作させる手順を説明します。

## 🚀 5分で動かす

### 1. Docker コンテナを起動

```bash
docker compose up -d
```

### 2. コンテナに入る

```bash
docker compose exec app bash
```

### 3. Lambda 関数の直接テスト（サーバー不要）

```bash
./test-local.sh
```

これで4つのテストケースが実行されます。

### 4. ローカルサーバーを起動してブラウザからアクセス

コンテナ内で：

```bash
npm run local
```

サーバーが起動したら、**別のターミナルで**以下を実行：

```bash
# ホストマシンから（Docker の外から）
curl "http://localhost:3000/?list=山田,大田,伊藤"
```

または、ブラウザで開く：
```
http://localhost:3000/?list=山田,大田,伊藤
```

### 5. API のテスト（サーバー起動中）

**別のターミナル**を開いて：

```bash
cd /path/to/random-assign-python-lambda
./test-api.sh
```

## 📋 よく使うコマンド

```bash
# コンテナを起動
docker compose up -d

# コンテナに入る
docker compose exec app bash

# Lambda 関数を直接テスト（サーバー不要）
./test-local.sh

# ローカルサーバーを起動（コンテナ内で実行）
npm run local

# API をテスト（ホストマシンから実行、サーバー起動中）
./test-api.sh

# コンテナを停止
docker compose down
```

## 🎯 期待される結果

### Lambda 直接テスト (`./test-local.sh`)

```json
{
    "statusCode": 200,
    "headers": {
        "Content-Type": "application/json; charset=utf-8",
        "Access-Control-Allow-Origin": "*"
    },
    "body": "{\"winner\": \"山田\", \"candidates\": [\"山田\", \"大田\", \"伊藤\"], \"count\": 3}"
}
```

### API テスト (`curl` または `./test-api.sh`)

```json
{
    "winner": "山田",
    "candidates": ["山田", "大田", "伊藤"],
    "count": 3
}
```

## 🐛 トラブルシューティング

### サーバーが起動しない

serverless offline はフォアグラウンドで実行されるため、別のターミナルでテストする必要があります。

### ポート 3000 が使用中

```bash
# 他のプロセスがポート3000を使用していないか確認
lsof -i :3000

# 使用中の場合は、そのプロセスを停止するか、
# serverless.yml の httpPort を変更してください
```

### コンテナに入れない

```bash
# コンテナの状態を確認
docker compose ps

# STATUS が "Up" であることを確認
# "Exited" の場合は、docker compose up -d で再起動
```

## 📖 詳細情報

詳しい情報は [README.md](README.md) を参照してください。

