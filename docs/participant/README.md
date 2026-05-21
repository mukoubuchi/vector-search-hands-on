# Vector Search ハンズオン - 受講者向けガイド

このディレクトリには、Vector Search ハンズオンの受講者向けドキュメントが含まれています。

## 📚 概要

IBM Bob × Milvus × Hugging Face Transformers を使ったベクトル検索（セマンティック検索）の実践的なハンズオンです。

## 🚀 ドキュメントの閲覧方法

### オンライン版を閲覧（推奨）⭐

**インストール不要！ブラウザだけでOK！**

講師から共有されたCode Engine URLにアクセスするだけで、すぐにドキュメントを閲覧できます。

**URL例**:
```
https://mkdocs-docs.xxxxx.us-south.codeengine.appdomain.cloud
```

> **注意**: **xxxxx**の部分は環境により異なります（あくまで例）。必ず講師から共有された最新のURLを使用してください。

**メリット:**
- ✅ インストール不要
- ✅ どこからでもアクセス可能（WiFi/ネットワーク不問）
- ✅ ナビゲーション・検索機能が使える
- ✅ 常に最新版
- ✅ ブックマーク推奨

### ローカルで閲覧（開発・確認用）

**Code Engineが利用できない場合のみ使用してください。**

#### 簡易サーバーで閲覧（Pythonのみ必要）

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

#### MkDocsをインストールして閲覧

Pythonの簡易サーバーが使えない場合は、MkDocsをインストールして閲覧できます。

**インストール:**
```bash
pip install mkdocs-material
```

**起動:**
```bash
cd docs/participant
mkdocs serve
```

ブラウザで http://localhost:8000 にアクセスしてドキュメントを閲覧できます。

## 📁 ファイル構成

```
docs/participant/
├── README.md               # このファイル
├── mkdocs.yml              # MkDocs設定ファイル
├── serve-docs.sh           # 簡易サーバー起動（macOS/Linux）★推奨
├── serve-docs.bat          # 簡易サーバー起動（Windows）★推奨
├── start-docs.sh           # MkDocsサーバー起動（開発者向け）
├── start-docs.bat          # MkDocsサーバー起動（開発者向け）
├── site/                   # MkDocsビルド結果（自動生成、Git管理外）
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
- [Hugging Face Transformers ドキュメント](https://huggingface.co/docs/transformers)
- [Sentence Transformers ドキュメント](https://www.sbert.net/)
