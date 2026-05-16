# Vector Search ハンズオン - 受講者向けガイド

このディレクトリには、Vector Search ハンズオンの受講者向けドキュメントが含まれています。

## 📚 概要

IBM Bob × Milvus × watsonx.ai を使ったベクトル検索（セマンティック検索）の実践的なハンズオンです。

## 🚀 ドキュメントの閲覧方法（準備不要！）

### 推奨: 簡易サーバーで閲覧（Pythonのみ必要）

**Pythonがインストールされていれば、追加のインストールなしで閲覧できます。**

#### 開き方

**macOS / Linux:**
```bash
cd docs/participant
./serve-docs.sh
```

**Windows:**
```cmd
cd docs\participant
serve-docs.bat
```

ブラウザで http://localhost:8000 にアクセスしてドキュメントを閲覧できます。

**メリット:**
- ✅ ナビゲーションが正しく動作
- ✅ 検索機能が使える
- ✅ Pythonのみで動作（追加インストール不要）

### 代替: ファイルとして直接開く

Pythonがない場合は、HTMLファイルを直接開くこともできます（一部機能が制限されます）。

**macOS / Linux:**
```bash
cd docs/participant
./open-docs.sh
```

**Windows:**
```cmd
cd docs\participant
open-docs.bat
```

**または手動で:**
`docs/participant/site/index.html` をブラウザで開く

**注意:** ファイルとして開いた場合、ナビゲーションリンクが正しく動作しない場合があります。

## 📁 ファイル構成

```
docs/participant/
├── README.md               # このファイル
├── mkdocs.yml              # MkDocs設定ファイル
├── serve-docs.sh           # 簡易サーバー起動（macOS/Linux）★推奨
├── serve-docs.bat          # 簡易サーバー起動（Windows）★推奨
├── open-docs.sh            # HTML直接開く（macOS/Linux）
├── open-docs.bat           # HTML直接開く（Windows）
├── start-docs.sh           # MkDocsサーバー起動（開発者向け）
├── start-docs.bat          # MkDocsサーバー起動（開発者向け）
├── site/                   # 生成済みHTMLファイル（受講者用）
│   └── index.html          # ドキュメントのトップページ
└── docs/                   # Markdownソースファイル
    ├── index.md            # ハンズオン概要
    ├── preparation.md      # 事前準備
    ├── part1.md            # Part 1: 基本的なベクトル検索
    ├── part2.md            # Part 2: 高度な検索機能
    ├── part3.md            # Part 3: 実践的な応用
    └── summary.md          # まとめ
```

## 🎯 ハンズオンの流れ

1. **事前準備** ([docs/preparation.md](docs/preparation.md))
   - IBM Bob IDEのインストール
   - 接続情報の設定
   - 環境の確認

2. **Part 1: 基本的なベクトル検索** ([docs/part1.md](docs/part1.md))
   - Milvusへの接続
   - ベクトルコレクションの作成
   - 基本的な検索

3. **Part 2: 高度な検索機能** ([docs/part2.md](docs/part2.md))
   - フィルタリング検索
   - ハイブリッド検索
   - パフォーマンス最適化

4. **Part 3: 実践的な応用** ([docs/part3.md](docs/part3.md))
   - RAGシステムの構築
   - 実際のユースケース
   - ベストプラクティス

5. **まとめ** ([docs/summary.md](docs/summary.md))
   - 学んだ内容の振り返り
   - 次のステップ

## 💡 ヒント

- **推奨**: `serve-docs.sh` または `serve-docs.bat` を使用（ナビゲーションが正しく動作）
- **Pythonのみ必要**: 追加のパッケージインストール不要
- **オフライン閲覧可能**: インターネット接続不要
- **検索機能**: ドキュメントサイト内で全文検索が使えます
- **ダークモード**: 右上のアイコンで切り替えられます
- **コードコピー**: コードブロックの右上にコピーボタンがあります

## 🔗 関連リンク

- [講師向けドキュメント](../instructor/README.md)
- [セットアップファイル](../../setup/README.md)
- [プロジェクトルート](../../README.md)

## 📖 参考資料

- [IBM Bob ドキュメント](https://ibm.github.io/ibm-bob/)
- [Milvus ドキュメント](https://milvus.io/docs)
- [watsonx.ai ドキュメント](https://www.ibm.com/docs/en/watsonx-as-a-service)
