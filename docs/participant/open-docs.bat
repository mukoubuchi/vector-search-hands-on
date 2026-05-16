@echo off
REM 生成済みのHTMLドキュメントをブラウザで開くスクリプト（Windows用）

echo ==================================
echo Vector Search ハンズオン
echo ドキュメントを開いています...
echo ==================================
echo.

REM siteディレクトリが存在するか確認
if not exist "site" (
    echo ❌ ドキュメントが見つかりません
    echo.
    echo 講師に連絡して、ドキュメントファイルを取得してください
    echo.
    pause
    exit /b 1
)

echo ✓ ドキュメントが見つかりました
echo.

REM index.htmlをデフォルトブラウザで開く
start "" "%CD%\site\index.html"

echo ✓ ブラウザでドキュメントを開きました
echo.
echo ドキュメントの閲覧を開始できます！
echo.
pause

@REM Made with Bob
