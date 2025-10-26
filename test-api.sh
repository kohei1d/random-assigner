#!/bin/bash

# API のベース URL を引数から取得（デフォルトは localhost）
BASE_URL="${1:-http://localhost:3000}"

echo "==================================="
echo "🌐 API エンドポイントのテスト"
echo "==================================="
echo "URL: $BASE_URL"
echo ""

# テスト1: GET リクエスト
echo "📝 テスト1: GET リクエスト"
echo "コマンド: curl \"${BASE_URL}/?list=山田,大田,伊藤\""
curl -s "${BASE_URL}/?list=山田,大田,伊藤" | python3 -m json.tool
echo ""
echo "-----------------------------------"
echo ""

# テスト2: POST リクエスト（JSON配列）
echo "📝 テスト2: POST リクエスト（JSON配列）"
echo "コマンド: curl -X POST -H \"Content-Type: application/json\" -d '{\"list\": [\"鈴木\", \"佐藤\", \"田中\", \"高橋\"]}'"
curl -s -X POST "${BASE_URL}/" \
  -H "Content-Type: application/json" \
  -d '{"list": ["鈴木", "佐藤", "田中", "高橋"]}' | python3 -m json.tool
echo ""
echo "-----------------------------------"
echo ""

# テスト3: POST リクエスト（カンマ区切り文字列）
echo "📝 テスト3: POST リクエスト（カンマ区切り文字列）"
echo "コマンド: curl -X POST -H \"Content-Type: application/json\" -d '{\"list\": \"Alice,Bob,Charlie,Diana\"}'"
curl -s -X POST "${BASE_URL}/" \
  -H "Content-Type: application/json" \
  -d '{"list": "Alice,Bob,Charlie,Diana"}' | python3 -m json.tool
echo ""
echo "-----------------------------------"
echo ""

# テスト4: エラーケース（パラメータなし）
echo "📝 テスト4: エラーケース（パラメータなし）"
echo "コマンド: curl \"${BASE_URL}/\""
curl -s "${BASE_URL}/" | python3 -m json.tool
echo ""
echo "-----------------------------------"
echo ""

echo "==================================="
echo "✅ テスト完了"
echo "==================================="
echo ""
echo "💡 使い方:"
echo "  ローカル: ./test-api.sh"
echo "  AWS:     ./test-api.sh https://your-lambda-url.lambda-url.ap-northeast-1.on.aws"

