#!/bin/bash

# Set UTF-8 locale (try en_US.UTF-8, fallback to C.UTF-8)
if locale -a 2>/dev/null | grep -q "en_US.utf8\|en_US.UTF-8"; then
    export LC_ALL=en_US.UTF-8
    export LANG=en_US.UTF-8
else
    export LC_ALL=C.UTF-8
    export LANG=C.UTF-8
fi

# Get API base URL from argument (default: localhost)
BASE_URL="${1:-http://localhost:3000}"

echo "==================================="
echo "🌐 API Endpoint Test"
echo "==================================="
echo "URL: $BASE_URL"
echo ""

FAILED_TESTS=0
PASSED_TESTS=0

# Function to extract winner from HTML response
extract_winner_from_html() {
    echo "$1" | python3 -c "
import sys, re, io
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')
html = sys.stdin.read()
match = re.search(r'<div class=\"winner\">([^<]+)</div>', html)
print(match.group(1) if match else '')
" 2>/dev/null
}

# Test 1: GET request
echo "📝 Test 1: GET request"
echo "Command: curl --get --data-urlencode \"list=山田,大田,伊藤\" \"${BASE_URL}/\""
RESPONSE1=$(curl -s --get --data-urlencode "list=山田,大田,伊藤" "${BASE_URL}/")
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
echo "Command: curl -X POST -H \"Content-Type: application/json\" -d '{\"list\": [\"鈴木\", \"佐藤\", \"田中\", \"高橋\"]}'"
RESPONSE2=$(curl -s -X POST "${BASE_URL}/" \
  -H "Content-Type: application/json" \
  -d '{"list": ["鈴木", "佐藤", "田中", "高橋"]}')
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
echo "Command: curl -X POST -H \"Content-Type: application/json\" -d '{\"list\": \"Alice,Bob,Charlie,Diana\"}'"
RESPONSE3=$(curl -s -X POST "${BASE_URL}/" \
  -H "Content-Type: application/json" \
  -d '{"list": "Alice,Bob,Charlie,Diana"}')
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

# Test 4: Error case (no parameters)
echo "📝 Test 4: Error case (no parameters)"
echo "Command: curl \"${BASE_URL}/\""
RESPONSE4=$(curl -s "${BASE_URL}/")
echo "$RESPONSE4"

if echo "$RESPONSE4" | grep -q "BadRequest"; then
    echo "✅ Test 4 passed: Error returned for empty list"
    ((PASSED_TESTS++))
else
    echo "❌ Test 4 failed: No error returned for empty list"
    ((FAILED_TESTS++))
fi
echo ""
echo "-----------------------------------"
echo ""

echo "==================================="
echo "📊 Test Results Summary"
echo "==================================="
echo "✅ Passed: $PASSED_TESTS"
echo "❌ Failed: $FAILED_TESTS"
echo "==================================="
echo ""
echo "💡 Usage:"
echo "  Local: ./test-api.sh"
echo "  AWS:   ./test-api.sh https://your-lambda-url.lambda-url.ap-northeast-1.on.aws"
echo ""

if [ $FAILED_TESTS -gt 0 ]; then
    echo "❌ Tests Failed"
    exit 1
else
    echo "✅ All Tests Passed"
    exit 0
fi

