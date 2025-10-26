#!/bin/bash

# Set UTF-8 locale (try en_US.UTF-8, fallback to C.UTF-8)
if locale -a 2>/dev/null | grep -q "en_US.utf8\|en_US.UTF-8"; then
    export LC_ALL=en_US.UTF-8
    export LANG=en_US.UTF-8
else
    export LC_ALL=C.UTF-8
    export LANG=C.UTF-8
fi

echo "==================================="
echo "🧪 Lambda Function Local Test"
echo "==================================="
echo ""

FAILED_TESTS=0
PASSED_TESTS=0

# Function to extract winner from HTML response
extract_winner_from_html() {
    echo "$1" | python3 -c "
import sys, json, re, io
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')
full_input = sys.stdin.read()
json_match = re.search(r'\{[\s\S]*\}', full_input)
if json_match:
    data = json.loads(json_match.group(0))
    html = data.get('body', '')
    match = re.search(r'<div class=\"winner\">([^<]+)</div>', html)
    print(match.group(1) if match else '')
else:
    print('')
" 2>/dev/null
}

# Test 1: GET request (query parameters)
echo "📝 Test 1: GET request (query parameters)"
RESPONSE1=$(npx serverless invoke local -f randomAssign --data '{
  "queryStringParameters": {
    "list": "山田,大田,伊藤"
  }
}' 2>&1)

echo "$RESPONSE1"
WINNER1=$(extract_winner_from_html "$RESPONSE1")

if [[ "$WINNER1" == "山田" || "$WINNER1" == "大田" || "$WINNER1" == "伊藤" ]]; then
    printf "✅ Test 1 passed: Winner「%s」is in the candidate list\n" "$WINNER1"
    ((PASSED_TESTS++))
else
    printf "❌ Test 1 failed: Winner「%s」is not in the candidate list (山田,大田,伊藤)\n" "$WINNER1"
    ((FAILED_TESTS++))
fi

echo ""
echo "-----------------------------------"
echo ""

# Test 2: POST request (JSON array)
echo "📝 Test 2: POST request (JSON array)"
RESPONSE2=$(npx serverless invoke local -f randomAssign --data '{
  "body": "{\"list\": [\"鈴木\", \"佐藤\", \"田中\", \"高橋\"]}"
}' 2>&1)

echo "$RESPONSE2"
WINNER2=$(extract_winner_from_html "$RESPONSE2")

if [[ "$WINNER2" == "鈴木" || "$WINNER2" == "佐藤" || "$WINNER2" == "田中" || "$WINNER2" == "高橋" ]]; then
    printf "✅ Test 2 passed: Winner「%s」is in the candidate list\n" "$WINNER2"
    ((PASSED_TESTS++))
else
    printf "❌ Test 2 failed: Winner「%s」is not in the candidate list (鈴木,佐藤,田中,高橋)\n" "$WINNER2"
    ((FAILED_TESTS++))
fi

echo ""
echo "-----------------------------------"
echo ""

# Test 3: POST request (comma-separated string)
echo "📝 Test 3: POST request (comma-separated string)"
RESPONSE3=$(npx serverless invoke local -f randomAssign --data '{
  "body": "{\"list\": \"Alice,Bob,Charlie,Diana\"}"
}' 2>&1)

echo "$RESPONSE3"
WINNER3=$(extract_winner_from_html "$RESPONSE3")

if [[ "$WINNER3" == "Alice" || "$WINNER3" == "Bob" || "$WINNER3" == "Charlie" || "$WINNER3" == "Diana" ]]; then
    printf "✅ Test 3 passed: Winner「%s」is in the candidate list\n" "$WINNER3"
    ((PASSED_TESTS++))
else
    printf "❌ Test 3 failed: Winner「%s」is not in the candidate list (Alice,Bob,Charlie,Diana)\n" "$WINNER3"
    ((FAILED_TESTS++))
fi

echo ""
echo "-----------------------------------"
echo ""

# Test 4: Error case (empty list)
echo "📝 Test 4: Error case (empty list)"
RESPONSE4=$(npx serverless invoke local -f randomAssign --data '{}' 2>&1)

echo "$RESPONSE4"

if echo "$RESPONSE4" | grep -q "BadRequest"; then
    echo "✅ Test 4 passed: Error returned for empty list"
    ((PASSED_TESTS++))
else
    echo "❌ Test 4 failed: No error returned for empty list"
    ((FAILED_TESTS++))
fi

echo ""
echo "==================================="
echo "📊 Test Results Summary"
echo "==================================="
echo "✅ Passed: $PASSED_TESTS"
echo "❌ Failed: $FAILED_TESTS"
echo "==================================="

if [ $FAILED_TESTS -gt 0 ]; then
    echo "❌ Tests Failed"
    exit 1
else
    echo "✅ All Tests Passed"
    exit 0
fi
