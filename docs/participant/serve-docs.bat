@echo off
REM 生成済みのHTMLドキュメントをローカルサーバーで配信するスクリプト（Windows用）

echo ==================================
echo Vector Search ハンズオン
echo ドキュメントサーバーを起動中...
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

REM Pythonのバージョンを確認
where python >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    set PYTHON_CMD=python
    goto :found_python
)

where python3 >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    set PYTHON_CMD=python3
    goto :found_python
)

echo ❌ Pythonが見つかりません
echo.
echo Pythonをインストールするか、open-docs.bat を使用してください
echo.
pause
exit /b 1

:found_python
echo ✓ Pythonが見つかりました: %PYTHON_CMD%
echo.
echo ドキュメントサーバーを起動しています...
echo ブラウザで http://localhost:8000 にアクセスしてください
echo.
echo 終了するには Ctrl+C を押してください
echo.

REM siteディレクトリに移動してHTTPサーバーを起動
cd site
%PYTHON_CMD% -m http.server 8000

@REM Made with Bob
