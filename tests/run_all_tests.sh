#!/bin/bash

# 全テストを実行するスクリプト

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "=========================================="
echo "Vector Search ハンズオン - 全テスト実行"
echo "=========================================="
echo ""

# 色定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Bashスクリプトのテスト
echo "=== Bashスクリプトのテスト ==="
if [ -f "$SCRIPT_DIR/test_common.sh" ]; then
    if bash "$SCRIPT_DIR/test_common.sh"; then
        echo -e "${GREEN}✓ Bashスクリプトのテストが成功しました${NC}"
        PASSED_TESTS=$((PASSED_TESTS + 1))
    else
        echo -e "${RED}✗ Bashスクリプトのテストが失敗しました${NC}"
        FAILED_TESTS=$((FAILED_TESTS + 1))
    fi
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
else
    echo -e "${YELLOW}⚠ test_common.sh が見つかりません${NC}"
fi

echo ""

# Pythonスクリプトのテスト
echo "=== Pythonスクリプトのテスト ==="
if [ -f "$SCRIPT_DIR/test_python_scripts.py" ]; then
    if command -v python3 &> /dev/null; then
        if python3 "$SCRIPT_DIR/test_python_scripts.py"; then
            echo -e "${GREEN}✓ Pythonスクリプトのテストが成功しました${NC}"
            PASSED_TESTS=$((PASSED_TESTS + 1))
        else
            echo -e "${RED}✗ Pythonスクリプトのテストが失敗しました${NC}"
            FAILED_TESTS=$((FAILED_TESTS + 1))
        fi
        TOTAL_TESTS=$((TOTAL_TESTS + 1))
    else
        echo -e "${YELLOW}⚠ python3 が見つかりません${NC}"
    fi
else
    echo -e "${YELLOW}⚠ test_python_scripts.py が見つかりません${NC}"
fi

echo ""

# ShellCheckによる静的解析
echo "=== ShellCheck 静的解析 ==="
if command -v shellcheck &> /dev/null; then
    SHELL_SCRIPTS=(
        "$PROJECT_ROOT/start-docs.sh"
        "$PROJECT_ROOT/deploy-to-code-engine.sh"
        "$PROJECT_ROOT/lib/common.sh"
        "$PROJECT_ROOT/lib/deploy-helpers.sh"
        "$PROJECT_ROOT/setup/instructor/start-all.sh"
        "$PROJECT_ROOT/setup/instructor/stop-all.sh"
        "$PROJECT_ROOT/setup/instructor/check_docs_url.sh"
        "$PROJECT_ROOT/setup/instructor/check-deploy-status.sh"
    )
    
    SHELLCHECK_FAILED=0
    for script in "${SHELL_SCRIPTS[@]}"; do
        if [ -f "$script" ]; then
            echo "チェック中: $(basename "$script")"
            if shellcheck "$script"; then
                echo -e "${GREEN}✓ $(basename "$script")${NC}"
            else
                echo -e "${RED}✗ $(basename "$script")${NC}"
                SHELLCHECK_FAILED=1
            fi
        fi
    done
    
    if [ $SHELLCHECK_FAILED -eq 0 ]; then
        echo -e "${GREEN}✓ ShellCheck 静的解析が成功しました${NC}"
        PASSED_TESTS=$((PASSED_TESTS + 1))
    else
        echo -e "${RED}✗ ShellCheck 静的解析で問題が見つかりました${NC}"
        FAILED_TESTS=$((FAILED_TESTS + 1))
    fi
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
else
    echo -e "${YELLOW}⚠ shellcheck が見つかりません（スキップ）${NC}"
    echo "  インストール: brew install shellcheck"
fi

echo ""

# テスト結果サマリー
echo "=========================================="
echo "テスト結果サマリー"
echo "=========================================="
echo "総テストスイート数: $TOTAL_TESTS"
echo -e "成功: ${GREEN}$PASSED_TESTS${NC}"
echo -e "失敗: ${RED}$FAILED_TESTS${NC}"
echo ""

if [ $FAILED_TESTS -eq 0 ]; then
    echo -e "${GREEN}✓ すべてのテストが成功しました！${NC}"
    exit 0
else
    echo -e "${RED}✗ $FAILED_TESTS 件のテストスイートが失敗しました${NC}"
    exit 1
fi

# Made with Bob