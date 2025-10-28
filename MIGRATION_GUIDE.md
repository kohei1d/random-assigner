# Serverless Framework から AWS SAM への移行ガイド

このドキュメントでは、本プロジェクトを Serverless Framework から AWS SAM へ移行した内容と手順について説明します。

## 移行の背景

- Serverless Framework v4 がライセンスキーを要求するようになり、運用コストが増加
- AWS SAM はAWS公式のサーバレスアプリケーションフレームワークで、無料で使用可能
- シンプルなLambda中心のアプリケーションには AWS SAM が適している

## 移行内容

### 1. ファイルの変更

#### 新規作成されたファイル
- `template.yaml` - AWS SAM テンプレート（Serverless Framework の `serverless.yml` と `serverless.deploy.yml` の代替）
- `events/test-event.json` - ローカルテスト用のイベントファイル
- `samconfig.toml.template` - SAM デプロイ設定のテンプレート
- `MIGRATION_GUIDE.md` - このファイル

#### 更新されたファイル
- `package.json` - Serverless Framework のコマンドを SAM CLI のコマンドに変更
- `Dockerfile` - SAM CLI をインストール
- `docker-compose.yml` - Serverless Framework の環境変数を削除
- `env.template` - Serverless Framework のライセンスキーを削除
- `.gitignore` - SAM 関連のファイル（`.aws-sam/`, `samconfig.toml`）を追加
- `README.md` - SAM を使用した開発・デプロイ手順に更新
- `test-local.sh` - SAM local invoke を使用するように変更

#### 参考のために残されたファイル
- `serverless.yml` - ローカル開発時の設定（参考用）
- `serverless.deploy.yml` - デプロイ時の設定（参考用）

これらのファイルは、移行前の設定を参照する目的で残しています。

## 主要な変更点

### コマンドの対応表

| 旧コマンド（Serverless Framework） | 新コマンド（AWS SAM） |
|-----------------------------------|---------------------|
| `npm run local` | `npm run local` （内部で `sam local start-api` を使用） |
| `npm run invoke-local` | `npm run invoke-local` （内部で `sam local invoke` を使用） |
| `npm run deploy` | `npm run build && npm run deploy` |
| `npm run remove` | `npm run delete` |
| `npm run info` | （SAM では CloudFormation コンソールで確認） |
| `npm run logs` | `npm run logs` |

### テンプレートの違い

**Serverless Framework (serverless.deploy.yml)**
```yaml
service: random-assigner

provider:
  name: aws
  runtime: python3.12
  region: ap-northeast-1
  memorySize: 128
  timeout: 10
  architecture: x86_64
  
functions:
  randomAssign:
    handler: handler.lambda_handler
    url: true
```

**AWS SAM (template.yaml)**
```yaml
AWSTemplateFormatVersion: '2010-09-09'
Transform: AWS::Serverless-2016-10-31
Description: Random Assigner - Serverless Application using AWS SAM

Globals:
  Function:
    Timeout: 10
    MemorySize: 128
    Runtime: python3.12
    Architectures:
      - x86_64

Resources:
  RandomAssignFunction:
    Type: AWS::Serverless::Function
    Properties:
      CodeUri: .
      Handler: handler.lambda_handler
      Events:
        ApiEvent:
          Type: HttpApi
          Properties:
            Path: /
            Method: ANY
      FunctionUrlConfig:
        AuthType: NONE
```

## 移行手順

### 1. 環境構築

```bash
# リポジトリをクローン
git clone <repository-url>
cd random-assigner

# 環境変数ファイルを作成（Serverless Framework のライセンスキーは不要）
cp env.template .env
# .env ファイルを編集して AWS 認証情報を設定

# Docker イメージをビルド（SAM CLI を含む）
docker compose build

# 依存関係をインストール（package.json に Serverless Framework は不要）
docker compose run --rm app npm install
```

### 2. ローカル開発

```bash
# SAM アプリケーションをビルド
docker compose run --rm app npm run build

# ローカルサーバーを起動
docker compose run --rm --service-ports app npm run local

# 別のターミナルでテスト
curl "http://localhost:3000/?list=Alice,Bob,Carol"
```

### 3. ローカルテスト

```bash
# Lambda 関数を直接テスト
docker compose run --rm app npm run test

# または個別に実行
docker compose run --rm app npm run invoke-local
```

### 4. AWS へのデプロイ

```bash
# ビルド
docker compose run --rm app npm run build

# 初回デプロイ（ガイド付き）
docker compose run --rm app npm run deploy

# 2回目以降のデプロイ
docker compose run --rm app npm run deploy-no-confirm
```

## デプロイ時の注意点

### 初回デプロイ時の設定

`npm run deploy` を実行すると、対話形式で以下の設定を聞かれます：

```
Configuring SAM deploy
======================

Looking for config file [samconfig.toml] :  Not found

Setting default arguments for 'sam deploy'
=========================================
Stack Name [sam-app]: random-assigner
AWS Region [us-east-1]: ap-northeast-1
#Shows you resources changes to be deployed and require a 'Y' to initiate deploy
Confirm changes before deploy [y/N]: y
#SAM needs permission to be able to create roles to connect to the resources in your template
Allow SAM CLI IAM role creation [Y/n]: Y
#Preserves the state of previously provisioned resources when an operation fails
Disable rollback [y/N]: N
RandomAssignFunction has no authorization defined, Is this okay? [y/N]: y
Save arguments to configuration file [Y/n]: Y
SAM configuration file [samconfig.toml]: (Enter)
SAM configuration environment [default]: (Enter)
```

これらの設定は `samconfig.toml` に保存され、次回以降は自動的に使用されます。

### Lambda Function URL について

デプロイが完了すると、以下のような出力が表示されます：

```
CloudFormation outputs from deployed stack
Outputs
Key                 RandomAssignFunctionUrl
Description         Lambda Function URL for Random Assigner
Value               https://xxxxxxxxxx.lambda-url.ap-northeast-1.on.aws/
```

この URL を使用してアプリケーションにアクセスできます。

## トラブルシューティング

### SAM CLI が見つからない

```bash
# Docker イメージを再ビルド
docker compose build --no-cache
```

### テンプレートの検証エラー

```bash
# テンプレートを検証
docker compose run --rm app npm run validate
```

### デプロイエラー

```bash
# CloudFormation スタックの状態を確認
aws cloudformation describe-stacks --stack-name random-assigner

# スタックを削除して再デプロイ
docker compose run --rm app npm run delete
docker compose run --rm app npm run deploy
```

## 参考リンク

- [AWS SAM 公式ドキュメント](https://docs.aws.amazon.com/serverless-application-model/)
- [AWS SAM CLI リファレンス](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/serverless-sam-cli-command-reference.html)
- [SAM テンプレート仕様](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/sam-specification.html)

## まとめ

AWS SAM への移行により、以下のメリットが得られました：

1. **コスト削減**: Serverless Framework のライセンスキーが不要
2. **AWS 公式サポート**: AWS が公式にサポートするツール
3. **シンプルな構成**: CloudFormation ベースで理解しやすい
4. **ローカル開発**: `sam local` でローカルテストが容易

既存の Lambda 関数のコードは一切変更せず、インフラ構成の定義方法のみを変更することで、スムーズに移行できました。
