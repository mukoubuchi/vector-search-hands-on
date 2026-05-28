# ポート設定

このハンズオンでは、複数のサービスが異なるポートで動作します。

## ポート一覧

| サービス | ポート | URL | 用途 |
|---------|--------|-----|------|
| **MkDocs（開発版）** | 8000 | http://localhost:8000 | ドキュメント編集用（自動リロード対応） |
| **MkDocs（コンテナ版）** | 8001 | http://localhost:8001 | 受講者共有用（安定配信） |
| **FastAPI（Swagger UI）** | 8002 | http://localhost:8002/docs | Vector Search API |
| **Milvus** | 19530 | localhost:19530 | ベクトルデータベース |

## 重要な注意事項

### ポート8000について

- **用途**: ドキュメント編集専用
- **起動方法**: `python -m mkdocs serve`（プロジェクトルートで実行）
- **特徴**: ファイル変更時に自動リロード
- **注意**: FastAPIアプリとは**別のポート**で動作

### ポート8002について

- **用途**: Vector Search APIのSwagger UI
- **起動方法**: `cd setup/participant && python app.py`
- **アクセス**: http://localhost:8002/docs
- **注意**: ポート8000とは**競合しない**

## トラブルシューティング

### Swagger UIが開けない場合

1. **FastAPIアプリが起動しているか確認**
   ```bash
   # プロセスを確認
   ps aux | grep "python.*app.py"
   ```

2. **正しいURLにアクセスしているか確認**
   - ❌ 間違い: http://localhost:8000/docs（MkDocsのポート）
   - ✅ 正しい: http://localhost:8002/docs（FastAPIのポート）

3. **ポートが使用中でないか確認**
   ```bash
   # ポート8002の使用状況を確認
   lsof -i :8002
   ```

### ポート競合が発生した場合

もしポート8002も使用中の場合は、[`app.py`](../setup/participant/app.py)の以下の行を変更してください：

```python
# 例: ポート8003に変更
uvicorn.run(
    "app:app",
    host="0.0.0.0",
    port=8003,  # ここを変更
    reload=True,
    log_level="info"
)
```

## 参考情報

### 講師向け情報

- 環境起動スクリプト: [`setup/instructor/start-all.sh`](../setup/instructor/start-all.sh)
- 詳細な配信方法: [`setup/instructor/deploy-docs-to-cloud.md`](../setup/instructor/deploy-docs-to-cloud.md)

### 受講者向け情報

- Part 1: [Vector Searchを体験しよう](part1.md)
- Part 2: [高度な検索機能](part2.md)
- Part 3: [実践的な応用](part3.md)