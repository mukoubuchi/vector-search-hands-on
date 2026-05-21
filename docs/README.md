# ドキュメントディレクトリ構造

このディレクトリには、MkDocsで生成されるドキュメントのソースファイルが含まれています。

## ディレクトリ構造

```
docs/
├── README.md                 # このファイル
├── index.md                  # ホームページ
├── preparation.md            # 事前準備
├── part1.md                  # Part 1: Vector Searchを体験
├── part2.md                  # Part 2: IBM Bobで機能を追加
├── part3.md                  # Part 3: 動作確認
├── summary.md                # まとめ
├── Dockerfile                # ドキュメントサーバー用Dockerfile
├── stylesheets/              # カスタムCSS（モジュール化済み）
│   ├── extra.css            # メインCSSファイル（各モジュールをインポート）
│   ├── typography.css       # タイポグラフィスタイル
│   ├── navigation.css       # ナビゲーションスタイル
│   ├── code.css             # コードブロックスタイル
│   └── components.css       # UIコンポーネントスタイル
├── javascripts/              # カスタムJavaScript（モジュール化済み）
│   ├── extra.js             # メインJSファイル（ドキュメント用）
│   ├── search.js            # 検索機能
│   ├── navigation.js        # ナビゲーション機能
│   ├── tasks.js             # タスクリスト機能
│   └── syntax-highlight.js  # シンタックスハイライト強化
└── overrides/                # テーマオーバーライド
    └── main.html            # カスタムHTMLテンプレート
```

## スタイルシートの構成

### extra.css
メインのCSSファイル。各モジュールをインポートします。

### typography.css
- 見出し（h1, h2, h3）のスタイル
- 段落、リスト、リンクのスタイル
- キーボードキー表示のスタイル
- 定義リストのスタイル

### navigation.css
- ヘッダーとタブのスタイル
- サイドバーとTOCのスタイル
- バックトゥトップボタン
- スクロールバーのスタイル

### code.css
- コードブロックのスタイル
- インラインコードのスタイル
- シンタックスハイライトの色設定
- 言語別のコードスタイル（Bash, Python, Properties等）

### components.css
- 検索ボックスのスタイル
- タスクリストのスタイル
- アドモニション（注意書き）のスタイル
- タブコンテンツのスタイル

## JavaScriptの構成

### search.js
検索ボックスの動作を制御します：
- 検索ボックス外をクリックした時に検索を閉じる機能

### navigation.js
ナビゲーション機能を制御します：
- バックトゥトップボタンの表示/非表示制御
- スクロール位置に応じた動作

### tasks.js
タスクリスト機能を提供します：
- チェックボックスの状態をlocalStorageに保存
- ページ再読み込み時に状態を復元

### syntax-highlight.js
コードブロックのシンタックスハイライトを強化します：
- Bashコマンドの最初の単語を強調表示
- Propertiesファイルの数値とコメントを適切にハイライト

## モジュール化の利点

1. **保守性の向上**: 各機能が独立したファイルに分離されているため、修正が容易
2. **可読性の向上**: ファイルサイズが小さくなり、コードが読みやすい
3. **再利用性**: 必要な機能だけを選択して使用可能
4. **デバッグの容易さ**: 問題のある機能を特定しやすい

## カスタマイズ方法

### スタイルの変更
特定のスタイルを変更したい場合は、該当するCSSモジュールを編集してください：

- タイポグラフィ → `typography.css`
- ナビゲーション → `navigation.css`
- コードブロック → `code.css`
- UIコンポーネント → `components.css`

### 機能の追加
新しいJavaScript機能を追加する場合：

1. `javascripts/`ディレクトリに新しいファイルを作成
2. `mkdocs.yml`の`extra_javascript`セクションに追加

例：
```yaml
extra_javascript:
  - javascripts/search.js
  - javascripts/navigation.js
  - javascripts/tasks.js
  - javascripts/syntax-highlight.js
  - javascripts/your-new-feature.js  # 新しいファイル
```

## 開発ガイドライン

### CSSの記述ルール
- CSS変数（`var(--md-*)`）を使用してMaterial Themeとの一貫性を保つ
- コメントで各セクションの目的を明記
- レスポンシブデザインを考慮（メディアクエリの使用）

### JavaScriptの記述ルール
- 各ファイルの先頭にJSDocコメントで機能を説明
- `DOMContentLoaded`イベントを使用して初期化
- 必要に応じて`setTimeout`でMaterial Themeの初期化を待つ

## ビルドとプレビュー

### ローカルでのプレビュー
```bash
# プロジェクトルートで実行
mkdocs serve
```

ブラウザで `http://localhost:8000` にアクセス

### 本番ビルド
```bash
# プロジェクトルートで実行
mkdocs build
```

ビルドされたファイルは `site/` ディレクトリに出力されます。

## トラブルシューティング

### スタイルが反映されない
1. ブラウザのキャッシュをクリア
2. `mkdocs serve`を再起動
3. CSSファイルのインポート順序を確認

### JavaScriptが動作しない
1. ブラウザのコンソールでエラーを確認
2. `mkdocs.yml`の`extra_javascript`セクションを確認
3. ファイルパスが正しいか確認

## 参考リンク

- [MkDocs公式ドキュメント](https://www.mkdocs.org/)
- [Material for MkDocs](https://squidfunk.github.io/mkdocs-material/)
- [Python Markdown拡張機能](https://python-markdown.github.io/extensions/)