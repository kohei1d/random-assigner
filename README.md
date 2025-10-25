# 🎲 Random Assignment API

AWS Lambda + Serverless Framework v4 で構築したランダム割り当て API です。  
Docker 環境でローカル開発・テスト・デプロイが完結します。

## 🎯 機能

候補者リストからランダムに1人を選出する API を提供します。

### リクエスト方法

#### 1. GET リクエスト（クエリパラメータ）
```bash
GET /?list=山田,大田,伊藤
```

#### 2. POST リクエスト（JSON ボディ）
```bash
POST /
Content-Type: application/json

{
  "list": ["山田", "大田", "伊藤"]
}
```

または

```bash
POST /
Content-Type: application/json

{
  "list": "山田,大田,伊藤"
}
```

### レスポンス例

```json
{
  "winner": "山田",
  "candidates": ["山田", "大田", "伊藤"],
  "count": 3
}
```

---

## 🛠️ 技術スタック

- **ランタイム**: Python 3.12 (AWS Lambda 公式イメージ)
- **インフラ**: AWS Lambda + Lambda Function URL
- **デプロイツール**: Serverless Framework v4
- **開発環境**: Docker (`public.ecr.aws/lambda/python:3.12`) + docker-compose

---

## ⚡ クイックスタート

最速で動作確認する手順：

```bash
# 1. リポジトリのクローン（または移動）
cd /path/to/random-assign-python-lambda

# 2. .env ファイルはすでに作成済み（ライセンスキー設定済み）

# 3. Docker コンテナを起動
docker-compose up -d

# 4. コンテナに入る
docker-compose exec app bash

# 5. 依存関係をインストール
npm install

# 6. ローカルサーバーを起動
npm run local

# 7. 別のターミナルでテスト
curl "http://localhost:3000/?list=山田,大田,伊藤"
```

---

## 📦 セットアップ

### 1. 環境変数ファイルの確認

`.env` ファイルは既に作成済みで、Serverless Framework のライセンスキーが設定されています。

AWS へデプロイする場合は、`.env` ファイルを編集して AWS 認証情報を設定してください：

```bash
# AWS 認証情報（デプロイ時に必要）
AWS_ACCESS_KEY_ID=your-aws-access-key-id
AWS_SECRET_ACCESS_KEY=your-aws-secret-access-key
AWS_REGION=ap-northeast-1
```

新規セットアップの場合は、テンプレートからコピーできます：

```bash
cp env.template .env
```

### 2. Docker コンテナの起動

```bash
docker-compose up -d
```

### 3. コンテナに入る

```bash
docker-compose exec app bash
```

### 4. 依存関係のインストール

```bash
npm install
```

---

## 🚀 ローカル開発

### ローカルサーバーの起動

コンテナ内で以下のコマンドを実行：

```bash
npm run local
```

サーバーが起動したら、ブラウザまたは curl でアクセスできます：

```bash
# ブラウザで開く
open http://localhost:3000/?list=山田,大田,伊藤

# curl でテスト (GET)
curl "http://localhost:3000/?list=山田,大田,伊藤"

# curl でテスト (POST)
curl -X POST http://localhost:3000/ \
  -H "Content-Type: application/json" \
  -d '{"list": ["山田", "大田", "伊藤"]}'
```

### テストスクリプトの利用

#### 1. Lambda 関数の直接テスト（サーバー不要）

```bash
./test-local.sh
```

このスクリプトは、サーバーを立ち上げずに Lambda 関数を直接実行し、複数のテストケースを実行します。

#### 2. API エンドポイントのテスト

```bash
# ローカルサーバーのテスト
./test-api.sh

# デプロイ済み AWS Lambda のテスト
./test-api.sh https://your-lambda-url.lambda-url.ap-northeast-1.on.aws
```

このスクリプトは、実際の HTTP リクエストを送信して API をテストします。

### ローカル invoke テスト（個別実行）

サーバーを立ち上げずに直接 Lambda 関数を実行してテストできます：

```bash
npm run invoke-local
```

または直接 serverless コマンドを使用：

```bash
serverless invoke local -f randomAssign --data '{"queryStringParameters":{"list":"山田,大田,伊藤"}}'
```

---

## 🌐 AWS へのデプロイ

### 1. デプロイ実行

コンテナ内で以下のコマンドを実行：

```bash
npm run deploy
```

または

```bash
serverless deploy
```

デプロイが完了すると、Lambda Function URL が表示されます：

```
✔ Service deployed to stack random-assign-api-dev (123s)

functions:
  randomAssign: random-assign-api-dev-randomAssign
    url: https://xxxxxxxxxx.lambda-url.ap-northeast-1.on.aws/
```

### 2. デプロイされた API のテスト

```bash
# GET リクエスト
curl "https://xxxxxxxxxx.lambda-url.ap-northeast-1.on.aws/?list=山田,大田,伊藤"

# POST リクエスト
curl -X POST https://xxxxxxxxxx.lambda-url.ap-northeast-1.on.aws/ \
  -H "Content-Type: application/json" \
  -d '{"list": ["山田", "大田", "伊藤"]}'
```

### 3. ログの確認

```bash
npm run logs
```

または

```bash
serverless logs -f randomAssign --tail
```

### 4. デプロイ情報の確認

```bash
npm run info
```

### 5. リソースの削除

```bash
npm run remove
```

---

## 📋 利用可能なコマンド

| コマンド | 説明 |
|---------|------|
| `npm run local` | ローカルサーバーを起動 (localhost:3000) |
| `npm run invoke-local` | Lambda 関数をローカルで直接実行 |
| `npm run deploy` | AWS にデプロイ |
| `npm run remove` | AWS からリソースを削除 |
| `npm run info` | デプロイ情報を表示 |
| `npm run logs` | CloudWatch ログを表示 |

---

## 🐛 トラブルシューティング

### ライセンスキーエラー

```
Error: License key not found
```

`.env` ファイルに `SERVERLESS_ACCESS_KEY` が正しく設定されているか確認してください。

### AWS 認証エラー

```
Error: AWS credentials not found
```

`.env` ファイルに AWS の認証情報が正しく設定されているか確認してください。

### ポートが使用中

```
Error: Port 3000 is already in use
```

他のプロセスが 3000 番ポートを使用している場合は、`serverless.yml` の `httpPort` を変更してください。

---

## 📂 プロジェクト構成

```
.
├── handler.py              # Lambda 関数のハンドラー
├── serverless.yml          # Serverless Framework 設定
├── package.json            # Node.js 依存関係
├── Dockerfile              # Docker イメージ定義
├── docker-compose.yml      # Docker Compose 設定
├── env.template            # 環境変数テンプレート
├── .env                    # 環境変数（自動生成、Git除外）
├── test-local.sh           # Lambda 関数の直接テストスクリプト
├── test-api.sh             # API エンドポイントのテストスクリプト
└── README.md               # このファイル
```

---

## 🔒 セキュリティノート

- `.env` ファイルは絶対に Git にコミットしないでください
- 本番環境では適切な認証・認可の仕組みを追加することを推奨します
- Lambda Function URL は公開 URL なので、機密情報を含まないようにしてください

---

## 📝 ライセンス

MIT

