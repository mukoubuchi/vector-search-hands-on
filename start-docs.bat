@echo off
REM MkDocsドキュメントサーバーを起動するスクリプト（Windows用）

echo ==================================
echo Vector Search ハンズオン
echo ドキュメントサーバーを起動中...
echo ==================================
echo.

REM MkDocsがインストールされているか確認
where mkdocs >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo ❌ MkDocsがインストールされていません
    echo.
    echo インストール方法:
    echo   pip install mkdocs mkdocs-material
    echo.
    pause
    exit /b 1
)

echo ✓ MkDocsが見つかりました
echo.
echo ドキュメントサーバーを起動しています...
echo ブラウザで http://localhost:8000 にアクセスしてください
echo.
echo 終了するには Ctrl+C を押してください
echo.

REM MkDocs 2.0 に関する Material の将来互換性警告を抑止して起動
set NO_MKDOCS_2_WARNING=true
mkdocs serve

@REM Made with Bob
