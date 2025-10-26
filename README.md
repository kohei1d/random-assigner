# Random Assignner

A random assignment API built with AWS Lambda + Serverless Framework v4.  
Local development, testing, and deployment all work seamlessly within a Docker environment.

## Features

Provides an API that randomly selects one person from a list of candidates.

### Request Methods

#### 1. GET Request (Query Parameters)
```bash
GET /?list=Alice,Bob,Carol
```

#### 2. POST Request (JSON Body)
```bash
POST /
Content-Type: application/json

{
  "list": ["Alice", "Bob", "Carol"]
}
```

Or

```bash
POST /
Content-Type: application/json

{
  "list": "Alice,Bob,Carol"
}
```

### Success Response Example

```json
{
  "winner": "Alice",
  "candidates": ["Alice", "Bob", "Carol"]
}
```

### Error Response Example

When no candidates are specified:

```json
{
  "error": "BadRequest",
  "message": "Please specify candidates in the list parameter. Example: ?list=Alice,Bob,Carol"
}
```

> **Note**: The actual error message in the implementation is currently in Japanese. The example above shows what the message would be in English.

---

## Tech Stack

- **Runtime**: Python 3.12 (AWS Lambda official image)
- **Infrastructure**: AWS Lambda + Lambda Function URL
- **Deployment Tool**: Serverless Framework v4
- **Development Environment**: Docker (`public.ecr.aws/lambda/python:3.12`) + docker compose

---

## Quick Start

Steps to get up and running quickly:

```bash
# 1. Clone the repository (or navigate to it)
cd /path/to/random-assign-python-lambda

# 2. .env file is already created (with license key configured)

# 3. Install dependencies
docker compose run --rm app npm install

# 4. Start local server
docker compose run --rm --service-ports app npm run local

# 5. Test from another terminal
curl "http://localhost:3000/?list=Alice,Bob,Carol"
```

---

## Setup

### 1. Environment Variables Configuration

```bash
# Serverless Framework access key
SERVERLESS_ACCESS_KEY=your-serverless-access-key

# AWS credentials (required for deployment)
AWS_ACCESS_KEY_ID=your-aws-access-key-id
AWS_SECRET_ACCESS_KEY=your-aws-secret-access-key
AWS_REGION=ap-northeast-1
```

For new setup, you can copy from the template:

```bash
cp env.template .env
```

### 2. Install Dependencies

```bash
docker compose run --rm app npm install
```

---

## Local Development

### Start Local Server

Run the following command:

```bash
docker compose run --rm --service-ports app npm run local
```

Once the server is running, you can access it via browser or curl:

```bash
# Open in browser
open http://localhost:3000/?list=Alice,Bob,Carol

# Test with curl (GET)
curl "http://localhost:3000/?list=Alice,Bob,Carol"

# Test with curl (POST)
curl -X POST http://localhost:3000/ \
  -H "Content-Type: application/json" \
  -d '{"list": ["Alice", "Bob", "Carol"]}'
```

### Using Test Scripts

#### 1. Direct Lambda Function Test (No Server Required)

```bash
docker compose run --rm app npm run test
```

This script directly executes the Lambda function without starting a server and runs multiple test cases.

#### 2. API Endpoint Test

```bash
# Test local server (from host machine)
./test-api.sh

# Test deployed AWS Lambda
./test-api.sh https://your-lambda-url.lambda-url.ap-northeast-1.on.aws
```

This script tests the API by sending actual HTTP requests.

### Local Invoke Test (Individual Execution)

You can test by directly executing the Lambda function without starting a server:

```bash
docker compose run --rm app npm run invoke-local
```

---

## Deploy to AWS

### 1. Execute Deployment

Run the following command:

```bash
docker compose run --rm app npm run deploy
```

When deployment completes, the Lambda Function URL will be displayed:

```
✔ Service deployed to stack random-assigner-dev (123s)

functions:
  randomAssign: random-assigner-dev-randomAssign
    url: https://xxxxxxxxxx.lambda-url.ap-northeast-1.on.aws/
```

### 2. Test Deployed API

```bash
# GET request
curl "https://xxxxxxxxxx.lambda-url.ap-northeast-1.on.aws/?list=Alice,Bob,Carol"

# POST request
curl -X POST https://xxxxxxxxxx.lambda-url.ap-northeast-1.on.aws/ \
  -H "Content-Type: application/json" \
  -d '{"list": ["Alice", "Bob", "Carol"]}'
```

### 3. View Logs

```bash
docker compose run --rm app npm run logs
```

### 4. Check Deployment Info

```bash
docker compose run --rm app npm run info
```

### 5. Remove Resources

```bash
docker compose run --rm app npm run remove
```

---

## Available Commands

| Command | Description |
|---------|------|
| `docker compose run --rm --service-ports app npm run local` | Start local server (localhost:3000) |
| `docker compose run --rm app npm run invoke-local` | Execute Lambda function locally |
| `docker compose run --rm app npm run deploy` | Deploy to AWS |
| `docker compose run --rm app npm run remove` | Remove resources from AWS |
| `docker compose run --rm app npm run info` | Display deployment information |
| `docker compose run --rm app npm run logs` | Display CloudWatch logs |

> **Note**: The `--service-ports` flag is required for `npm run local` to expose port 3000 to the host machine.

---

## Troubleshooting

### License Key Error

```
Error: License key not found
```

Check that `SERVERLESS_ACCESS_KEY` is correctly configured in the `.env` file.

### AWS Authentication Error

```
Error: AWS credentials not found
```

Check that AWS credentials are correctly configured in the `.env` file.

### Port Already in Use

```
Error: Port 3000 is already in use
```

If another process is using port 3000, change the `httpPort` in `serverless.yml`.

---

## Project Structure

```
.
├── handler.py              # Lambda function handler
├── serverless.yml          # Serverless Framework config (local development)
├── serverless.deploy.yml   # Serverless Framework config (AWS deployment)
├── package.json            # Node.js dependencies
├── Dockerfile              # Docker image definition
├── docker compose.yml      # Docker Compose configuration
├── env.template            # Environment variables template
├── .env                    # Environment variables (auto-generated, Git ignored)
├── test-local.sh           # Lambda function direct test script
├── test-api.sh             # API endpoint test script
└── README.md               # This file
```

---

## Security Notes

- **Never** commit the `.env` file to Git
- It is recommended to add proper authentication and authorization mechanisms for production environments
- Lambda Function URL is a public URL, so do not include sensitive information

---

## 🛡️ AWS Free Tier Protection

このプロジェクトには、AWS Lambda の無料枠を超えないようにする保護機能が組み込まれています。

### 設定済みの保護機能

- **同時実行数制限**: 5リクエストまで（`serverless.yml` に設定済み）
- これにより、大量のリクエストが来ても制限を超えることはありません

### 使用状況の確認

```bash
# 今月の使用状況を確認
./check-usage.sh
```

### 緊急停止

無料枠を超えそうな場合、即座にLambdaを停止できます：

```bash
# Lambda を停止
./emergency-stop.sh

# Lambda を再開
./emergency-resume.sh
```

### 詳細な設定ガイド

詳しくは [FREE_TIER_PROTECTION.md](FREE_TIER_PROTECTION.md) をご覧ください。

---

## License

MIT

