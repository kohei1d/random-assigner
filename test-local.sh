#!/bin/bash

echo "==================================="
echo "🧪 Lambda Function のローカルテスト"
echo "==================================="
echo ""

# テスト1: GET リクエスト（クエリパラメータ）
echo "📝 テスト1: GET リクエスト（クエリパラメータ）"
npx serverless invoke local -f randomAssign --data '{
  "queryStringParameters": {
    "list": "山田,大田,伊藤"
  }
}'

echo ""
echo "-----------------------------------"
echo ""

# テスト2: POST リクエスト（JSON配列）
echo "📝 テスト2: POST リクエスト（JSON配列）"
npx serverless invoke local -f randomAssign --data '{
  "body": "{\"list\": [\"鈴木\", \"佐藤\", \"田中\", \"高橋\"]}"
}'

echo ""
echo "-----------------------------------"
echo ""

# テスト3: POST リクエスト（カンマ区切り文字列）
echo "📝 テスト3: POST リクエスト（カンマ区切り文字列）"
npx serverless invoke local -f randomAssign --data '{
  "body": "{\"list\": \"Alice,Bob,Charlie,Diana\"}"
}'

echo ""
echo "-----------------------------------"
echo ""

# テスト4: エラーケース（空のリスト）
echo "📝 テスト4: エラーケース（空のリスト）"
npx serverless invoke local -f randomAssign --data '{}'

echo ""
echo "==================================="
echo "✅ テスト完了"
echo "==================================="

