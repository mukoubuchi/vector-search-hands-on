#!/bin/bash

# 共通関数のユニットテスト

# テストフレームワーク
TEST_COUNT=0
TEST_PASSED=0
TEST_FAILED=0

assert_equals() {
    local expected="$1"
    local actual="$2"
    local test_name="$3"
    
    TEST_COUNT=$((TEST_COUNT + 1))
    
    if [ "$expected" = "$actual" ]; then
        echo "✓ PASS: $test_name"
        TEST_PASSED=$((TEST_PASSED + 1))
        return 0
    else
        echo "✗ FAIL: $test_name"
        echo "  Expected: $expected"
        echo "  Actual:   $actual"
        TEST_FAILED=$((TEST_FAILED + 1))
        return 1
    fi
}

assert_success() {
    local test_name="$1"
    
    TEST_COUNT=$((TEST_COUNT + 1))
    
    if [ $? -eq 0 ]; then
        echo "✓ PASS: $test_name"
        TEST_PASSED=$((TEST_PASSED + 1))
        return 0
    else
        echo "✗ FAIL: $test_name"
        TEST_FAILED=$((TEST_FAILED + 1))
        return 1
    fi
}

assert_failure() {
    local test_name="$1"
    
    TEST_COUNT=$((TEST_COUNT + 1))
    
    if [ $? -ne 0 ]; then
        echo "✓ PASS: $test_name"
        TEST_PASSED=$((TEST_PASSED + 1))
        return 0
    else
        echo "✗ FAIL: $test_name"
        TEST_FAILED=$((TEST_FAILED + 1))
        return 1
    fi
}

# 共通関数を読み込み
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"

echo "=========================================="
echo "共通関数ライブラリのテスト"
echo "=========================================="
echo ""

# バリデーション関数のテスト
echo "=== バリデーション関数のテスト ==="

# validate_not_empty
validate_not_empty "test_var" "value" > /dev/null 2>&1
assert_success "validate_not_empty: 値が存在する場合"

validate_not_empty "test_var" "" > /dev/null 2>&1
assert_failure "validate_not_empty: 値が空の場合"

# validate_port
validate_port "8080" > /dev/null 2>&1
assert_success "validate_port: 有効なポート番号"

validate_port "0" > /dev/null 2>&1
assert_failure "validate_port: 無効なポート番号（0）"

validate_port "70000" > /dev/null 2>&1
assert_failure "validate_port: 無効なポート番号（範囲外）"

validate_port "abc" > /dev/null 2>&1
assert_failure "validate_port: 無効なポート番号（文字列）"

# validate_url
validate_url "https://example.com" > /dev/null 2>&1
assert_success "validate_url: 有効なHTTPS URL"

validate_url "http://example.com" > /dev/null 2>&1
assert_success "validate_url: 有効なHTTP URL"

validate_url "ftp://example.com" > /dev/null 2>&1
assert_failure "validate_url: 無効なプロトコル"

validate_url "example.com" > /dev/null 2>&1
assert_failure "validate_url: プロトコルなし"

echo ""

# IPアドレス取得のテスト
echo "=== IPアドレス取得のテスト ==="
IP=$(get_ip_address)
if [ -n "$IP" ] && [ "$IP" != "IPアドレスを手動で確認してください" ]; then
    echo "✓ PASS: get_ip_address: IPアドレスを取得"
    TEST_COUNT=$((TEST_COUNT + 1))
    TEST_PASSED=$((TEST_PASSED + 1))
else
    echo "⚠ SKIP: get_ip_address: IPアドレスを取得できませんでした（環境依存）"
fi

echo ""

# テスト結果サマリー
echo "=========================================="
echo "テスト結果"
echo "=========================================="
echo "総テスト数: $TEST_COUNT"
echo "成功: $TEST_PASSED"
echo "失敗: $TEST_FAILED"
echo ""

if [ $TEST_FAILED -eq 0 ]; then
    echo "✓ すべてのテストが成功しました"
    exit 0
else
    echo "✗ $TEST_FAILED 件のテストが失敗しました"
    exit 1
fi

# Made with Bob