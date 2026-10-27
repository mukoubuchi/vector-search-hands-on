# ドキュメントディレクトリ構成

このディレクトリには、MkDocs で生成するドキュメントのソースファイルが含まれています。

## ディレクトリ構成

```
docs/
├── readme.md                 # 英語版の構成ガイド
├── index.md                  # ホームページ
├── preparation.md            # 準備
├── part1.md                  # Part 1: ベクトル検索を体験する
├── part2.md                  # Part 2: IBM Bob で機能を追加する
├── part3.md                  # Part 3: 動作確認と後始末
├── summary.md                # まとめ
├── feedback.md               # 参加者フィードバックフォーム
├── translation-sync.md       # 内部向け翻訳同期ガイド
├── ja/                       # 日本語翻訳
│   ├── readme.md             # このファイル
│   ├── index.md              # ホームページ
│   ├── preparation.md        # 準備
│   ├── part1.md              # Part 1: ベクトル検索を体験する
│   ├── part2.md              # Part 2: IBM Bob で機能を追加する
│   ├── part3.md              # Part 3: 動作確認と後始末
│   ├── summary.md            # まとめ
│   ├── feedback.md           # 参加者フィードバックフォーム
│   └── translation-sync.md   # 内部向け翻訳同期ガイド
├── images/                   # 図解、SVG 画像、スクリーンショット
├── assets/                   # 同梱の IBM Plex フォント
├── demo/                     # 検索画面のブラウザ版デモ
├── stylesheets/              # カスタム CSS（モジュール化）
│   ├── extra.css             # メイン CSS ファイル（各モジュールをインポート）
│   ├── typography.css        # タイポグラフィスタイル
│   ├── navigation.css        # ナビゲーションスタイル
│   ├── code.css              # コードブロックスタイル
│   ├── components.css        # UI コンポーネントスタイル
│   ├── feedback.css          # フィードバックフォームスタイル
│   ├── language-switcher.css # 言語切り替えスタイル
│   ├── palette.css           # 配色
│   ├── fonts.css             # 同梱の IBM Plex の書体の定義
│   └── vector-search.css     # このサイトだけのスタイル
└── javascripts/              # カスタム JavaScript（モジュール化）
    ├── site-config.js        # このサイトのページパスと言語
    ├── search.js             # 検索機能
    ├── navigation.js         # ナビゲーション機能
    ├── selector-indicator.js # タブの選択の下線
    ├── toc-indicator.js      # 目次の現在セクション表示
    ├── steps.js              # 番号付きのステップのレール
    ├── tasks.js              # タスクリスト機能
    ├── feedback.js           # フィードバックのコピー支援
    ├── syntax-highlight.js   # シンタックスハイライト強化
    └── language-switcher.js  # GitHub Pages の言語リンク補正
```

## 共通のファイル

`lib/shared_ui.py` に挙げた CSS と JavaScript のファイルは、ハンズオンのサイト `building-blocks-explorer-hands-on`、`text2sql-hands-on`、`vault-secret-migrator-hands-on` とこのサイトで同じものです。基準の写しは `building-blocks-explorer-hands-on` にあります。`lib/shared-ui.sha256` にそれぞれの SHA-256 を記録し、ここの写しが違うと CI が失敗します。変えるときは、先に基準のほうを変え、`lib/shared_ui.py` でここへ写します（使い方はファイルの冒頭の説明にあります）。

このサイトだけのファイルは 2 つです。共通のスクリプトが読む `window.HandsOn.site` を定める `javascripts/site-config.js` と、`mkdocs.yml` で `extra.css` の後に読み込む `stylesheets/vector-search.css` です。

## スタイルシート構成

### extra.css

メイン CSS ファイル。各モジュールをインポートします。

### typography.css

- 見出しスタイル（h1、h2、h3）
- 段落・リスト・リンクスタイル
- キーボードキー表示スタイル
- 定義リストスタイル

### navigation.css

- ヘッダーとタブのスタイル
- サイドバーと目次のスタイル
- トップへ戻るボタン
- スクロールバースタイル

### code.css

- コードブロックスタイル
- インラインコードスタイル
- シンタックスハイライトの色設定
- 言語別コードスタイル（Bash、Properties など）

### components.css

- 検索ボックススタイル
- タスクリストスタイル
- アドモニションスタイル
- タブコンテンツスタイル

### feedback.css

- フィードバックフォームとコピー用パネルのスタイル（`vector-search.css` が読み込む）

### language-switcher.css

- 言語セレクターの表示調整

### vector-search.css

このサイトだけのスタイルです。`mkdocs.yml` で `extra.css` の後に読み込みます。

- Part 1 の流れ図
- SVG の図の影
- Python のコードブロックと、console のブロックの期待される出力
- フィードバックフォーム（`feedback.css` を読み込む）

## JavaScript 構成

### site-config.js

このサイトのトップレベルページのパスと言語を `window.HandsOn.site` に定義します。共通のスクリプトはこれを読みます。ほかのハンズオンのサイトと中身が違う JavaScript は、このファイルだけです。

### search.js

検索ボックスの動作を制御します：

- 検索ボックス外をクリックすると検索を閉じる
- 検索結果を現在の言語とトップレベルページに絞り込む

### navigation.js

ナビゲーション機能を制御します：

- トップへ戻るボタンの表示/非表示
- スクロール位置に基づく動作

### toc-indicator.js

スクロールに合わせて、画面に表示中のセクションを目次のレール上にセグメントで強調表示します。位置は実際の要素座標から算出します。

### tasks.js

タスクリスト機能を提供します：

- チェックボックスの状態を localStorage に保存
- ページリロード時に状態を復元

### feedback.js

Slack に貼り付けやすいフィードバック文面を作成し、クリップボードへコピーします。

### syntax-highlight.js

コードブロックのシンタックスハイライトを強化します：

- Bash コマンドの最初の単語をハイライト
- Properties ファイルの数値とコメントを適切にハイライト

### language-switcher.js

GitHub Pages のプロジェクトパス配下で公開したときの言語切り替えリンクを補正します。

## モジュール化のメリット

1. **保守性の向上**: 各機能が独立したファイルに分離されており、修正が容易
2. **可読性の向上**: ファイルサイズが小さくなり、コードが読みやすい
3. **再利用性**: 必要な機能のみ選択して使用可能
4. **デバッグの容易さ**: 問題のある機能を特定しやすい

## カスタマイズ

### スタイルの変更

特定のスタイルを変更するには、対応する CSS モジュールを編集します：

- タイポグラフィ → `typography.css`
- ナビゲーション → `navigation.css`
- コードブロック → `code.css`
- UI コンポーネント → `components.css`

これらのモジュールは、ほかのハンズオンのサイトと共通です（「共通のファイル」を参照）。このサイトだけのスタイルは `vector-search.css` に書きます。

### 機能の追加

新しい JavaScript 機能を追加するには：

1. `javascripts/` ディレクトリに新しいファイルを作成する
2. `mkdocs.yml` の `extra_javascript` セクションに追加する

例：

```yaml
extra_javascript:
  - javascripts/site-config.js
  - javascripts/search.js
  - javascripts/navigation.js
  - javascripts/tasks.js
  - javascripts/feedback.js
  - javascripts/syntax-highlight.js
  - javascripts/language-switcher.js
  - javascripts/your-new-feature.js  # 新しいファイル
```

トップレベルページや言語を追加・削除する場合は、`javascripts/site-config.js` を更新します。検索フィルターと言語切り替えは、このサイトの設定を参照します。

## 開発ガイドライン

### CSS ガイドライン

- CSS 変数（`var(--md-*)`）を使用して Material Theme との一貫性を維持する
- コメントで各セクションの目的を記述する
- レスポンシブデザインを考慮する（メディアクエリを使用）

### JavaScript ガイドライン

- 各ファイルの先頭に JSDoc コメントで機能を説明する
- 初期化には `DOMContentLoaded` イベントを使用する
- Material Theme の初期化を待つために必要に応じて `setTimeout` を使用する

## ビルドとプレビュー

### ローカルプレビュー

```bash
# プロジェクトルートから実行
mkdocs serve
```

ブラウザで `http://localhost:8000` にアクセスします。

### 本番ビルド

```bash
# プロジェクトルートから実行
mkdocs build
```

ビルドされたファイルは `site/` ディレクトリに出力されます。

## トラブルシューティング

### スタイルが適用されない

1. ブラウザキャッシュをクリアする
2. `mkdocs serve` を再起動する
3. CSS ファイルのインポート順序を確認する

### JavaScript が動作しない

1. ブラウザコンソールでエラーを確認する
2. `mkdocs.yml` の `extra_javascript` セクションを確認する
3. ファイルパスが正しいか確認する

## 参考リンク

- [MkDocs 公式ドキュメント](https://www.mkdocs.org/)
- [Material for MkDocs](https://squidfunk.github.io/mkdocs-material/)
- [Python Markdown Extensions](https://python-markdown.github.io/extensions/)
