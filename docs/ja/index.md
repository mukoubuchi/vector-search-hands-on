# Vector Search ハンズオンへようこそ

このハンズオンでは、**Building Blocks** と **IBM Bob** を組み合わせて、「意味で検索する」機能（Vector Search）を構築する AI 駆動開発を体験します。

!!! info "前提条件"
    
    IBM Bob が既にインストールされ、使用できる状況を前提としています。このハンズオンは **IBM Bob 2.2.0**（2026 年 9 月）で動作を確認しています。バージョンが異なると、モードの一覧、承認の表示、IBM Bob の提案内容が変わることがあります。

## このハンズオンで体験できること

### Building Blocks + IBM Bob の価値

このハンズオンでは、**Building Blocks** という事前構築済みの技術コンポーネントと、**IBM Bob** という AI 開発アシスタントを組み合わせることで、数日〜数週間かかる開発を **約 60 分** で完了できることを体験します。

**Building Blocks なしの場合:**

![Building Blocks なしの開発フロー](images/without-building-blocks-ja.svg)

Building Blocks なしの場合、以下のような作業が必要になります:

- ベクトルデータベースの選定・学習
- 埋め込みモデルの選定・統合
- API の設計・実装
- エラーハンドリング
- パフォーマンスチューニング

**Building Blocks + IBM Bob の場合（このハンズオン、所要時間: 約 60 分）:**

![Building Blocks + IBM Bob の開発フロー](images/with-building-blocks-ja.svg)

各工程の担当:

- **Building Blocks**:
    - 技術選定（Milvus、埋め込みモデル）
    - 環境構築支援（Vector Search Builder モード、API サンプル）
- **IBM Bob**:
    - 要件定義
    - コーディング
    - テスト
    - デバッグ

??? note "IBM Bob の対応範囲について"
    IBM Bob は、要件定義からデバッグまでのソフトウェア開発ライフサイクル全体を支援できます。このハンズオンでは技術選定と環境構築を Building Blocks と講師の Milvus 環境が担うため、IBM Bob は主にコーディング・テスト・デバッグを担当します。

## Building Blocks とは？

**Building Blocks** は、IBM の技術スタックを活用した **事前構築済みの技術コンポーネント** です。Building Blocks を活用することでソリューション開発を加速させることができます。

### Building Blocks の特徴

- **即座に使える**: 複雑な設定や学習なしに、すぐに使い始められる
- **ベストプラクティス**: IBM のエンジニアリングチームが設計した最適な実装パターン
- **領域特化**: Vector Search 向けのガイダンスと実装パターンを提供
- **カスタマイズ可能**: IBM Bob を使って、ビジネス要件に合わせて柔軟に拡張

### このハンズオンで使用する Building Block

**Vector Search Builder**（Milvus ベース）

**提供内容**: ベクトルデータベース（Milvus）の構築・管理機能

**含まれる機能**:

- Milvus データベースのセットアップ
- コレクション（データの入れ物）の作成
- Hugging Face Transformers によるローカル埋め込みモデルの統合
- サンプル商品データの投入ワークフロー
- ベクトル検索の最適化

**IBM Bob との連携**: Vector Search Builder モードを使うことで、IBM Bob が Vector Search に特化した支援を提供

!!! example "Vector Search Builder モードの価値"
    
    **Vector Search Builder モード使用なし**: Milvus のドキュメントを読み、Python SDK を学習し、埋め込みモデルを選定・統合（数日）

    **Vector Search Builder モード使用あり**: Vector Search Builder をインストールし、IBM Bob に指示（数分）

??? info "このハンズオンの独自の工夫"
    パスは [mukoubuchi/vector-search-hands-on](https://github.com/mukoubuchi/vector-search-hands-on) リポジトリを基準にしています。

    - **Milvus は講師が用意**: 講師が全員分の Milvus を動かす（`setup/instructor/docker-compose.yml`）ため、受講者は IBM Bob、受講者用 zip、接続情報だけで参加できます
    - **オンサイトとリモートに対応**: ドキュメントはローカルネットワーク（`http://講師 IP:8001`）、または GitHub Pages や ngrok で共有します
    - **API キー不要**: 埋め込みは Hugging Face Transformers がローカルで作ります
    - **段階的な構成**: Part 1 で Vector Search を体験し、Part 2 で IBM Bob と機能を追加し、Part 3 で動作確認と後始末をします

    | 提供元 | 提供内容 | 目的 |
    |:---|:---|:---|
    | **Building Blocks** | Vector Search Builder モード<br/>FastAPI サンプル<br/>Milvus セットアップガイド | 技術基盤の提供<br/>開発の加速 |
    | **このハンズオン** | 講師用環境（Docker Compose）<br/>受講者用スクリプト<br/>教育用ドキュメント | 教育設計<br/>学習体験の最適化 |

## IBM Bob とは？

**IBM Bob** は、AI がコーディングをサポートしてくれる開発ツールです。

### IBM Bob でできること

- **自然言語で指示**: やりたいことを言葉で伝えられる
- **コードを自動生成**: 高品質なコードを自動的に書いてくれる
- **コードレビュー**: コードの問題点を指摘してくれる
- **Building Blocks との連携**: カスタムモードで、技術に特化した支援を提供

### Building Blocks との相乗効果

Building Blocks が基盤をすぐに用意し、IBM Bob が自然言語の指示だけでカスタマイズするため、最短時間で本番レベルの品質を実現できます。

### 開発方法の比較

| 開発方法 | 所要時間 | 必要なスキル | コード品質 |
|:---|---:|:---|:---|
| **Building Blocks なし** | 数日〜数週間 | プログラミング、DB 設計、API 設計 | 開発者のスキルに依存 |
| **IBM Bob のみ** | 数時間〜数日 | 基本的な技術理解 | 高品質だが構築に時間 |
| **Building Blocks + IBM Bob** | 数分〜数時間 | 自然言語で指示できれば OK | 本番レベルの高品質 |

## Vector Search とは？

**Vector Search（ベクトル検索）** は、言葉の「意味」を理解して検索する技術です。

### 従来の検索との違い

**従来のキーワード検索**:

- 「赤いスニーカー」→「赤い」と「スニーカー」という**文字**が含まれる商品を探す
- 「赤色のランニングシューズ」は見つからない（文字が違うため）

**Vector Search（意味で検索）**:

- 「赤いスニーカー」→「赤い」「スニーカー」の**意味**を理解
- 「赤色のランニングシューズ」も見つかる（意味が似ているため）
- 「初心者向けカメラ」→「入門用デジタルカメラ」も見つかる

### 実際の活用例

- **EC サイト**: 「似た商品を探す」機能
- **社内検索**: 「この資料に似た文書を探す」
- **カスタマーサポート**: 「似た質問を探す」

## ハンズオンの流れ

**合計**: 約 60 分

| パート | 内容 | 所要時間 |
|:---|:---|---:|
| [事前準備](preparation.md) | Vector Search Builder のセットアップ | 10 分 |
| [Part 1](part1.md) | Vector Search を体験 | 15 分 |
| [Part 2](part2.md) | IBM Bob で機能を追加 | 25 分 |
| [Part 3](part3.md) | 動作確認と後始末 | 5 分 |
| [まとめ](summary.md) | 振り返り・質疑 | 5 分 |

## 必要なもの

- **パソコン**（Mac、Windows）とインターネット接続
- **IBM Bob**（既にインストール済み）
- **Web ブラウザ**（Chrome、Firefox、Safari、Edge など）

**講師から配布**:

- ハンズオン手順書の URL
- Vector Search Builder の受講者用パッケージ（`vector-search-builder-ja.zip`）
- 接続情報（Milvus 接続情報）

[次へ →](preparation.md){ .workshop-next }
