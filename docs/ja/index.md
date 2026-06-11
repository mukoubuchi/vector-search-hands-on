# Vector Search ハンズオンへようこそ

このハンズオンでは、**Building Blocks** と **IBM Bob** を組み合わせて、「意味で検索する」機能（Vector Search）を構築する AI 駆動開発を体験します。

!!! info "前提条件"
    
    IBM Bob が既にインストールされ、使用できる状況を前提としています。このハンズオンでは **IBM Bob 1.0.3** を使用します。

## このハンズオンで体験できること

### Building Blocks + IBM Bob の価値

このハンズオンでは、**Building Blocks** という事前構築済みの技術コンポーネントと、**IBM Bob** という AI 開発アシスタントを組み合わせることで、数日〜数週間かかる開発を **約 90 分** で完了できることを体験します。

**Building Blocks なしの場合:**

![Building Blocks なしの開発フロー](images/without-building-blocks-ja.svg)

Building Blocks なしの場合、以下のような作業が必要になります:

- ベクトルデータベースの選定・学習
- 埋め込みモデルの選定・統合
- APIの設計・実装
- エラーハンドリング
- パフォーマンスチューニング

**Building Blocks + IBM Bob の場合（このハンズオン、所要時間: 約 90 分）:**

![Building Blocks + IBM Bob の開発フロー](images/with-building-blocks-ja.svg)

各工程の担当:

- **Building Blocks**:
    - 技術選定（Milvus、埋め込みモデル）
    - 環境構築支援（Bob モード、API サンプル）
- **IBM Bob**:
    - 要件定義
    - コーディング
    - テスト
    - デバッグ

??? note "IBM Bob の対応範囲について"
    IBM Bob は AI SDLC（Software Development Lifecycle）パートナーとして、要件定義からデバッグまでのソフトウェア開発ライフサイクル全体をサポートできます。このハンズオンでは、Building Blocks が技術選定（Milvus、埋め込みモデル）と環境構築の支援（Milvus セットアップ、Bob モード）を提供し、講師が Docker Compose で Milvus 環境を事前準備するため、IBM Bob は主にコーディング・テスト・デバッグに焦点を当てていますが、Plan モードを使用すれば要件定義や設計段階でも活用できます。

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
    このセクションで示すファイル名・ディレクトリ名は、以下の GitHub リポジトリを基準にしたパスです。

    - **リポジトリ**: [mukoubuchi/vector-search-hands-on](https://github.com/mukoubuchi/vector-search-hands-on)

    ### Building Blocks が提供するもの
    
    Building Blocks は以下の技術コンポーネントを提供します:
    
    #### 1. Vector Search Builder モード

    - **受講者用パッケージ**: `vector-search-builder-ja.zip`
    - **内容**:
        - IBM Bob の Custom モード設定
        - Vector Search Builder 用ルールファイル 3 個
        - Vector Search に特化した AI アシスタント機能
        - Milvus 操作のベストプラクティス
        - 受講者用スクリプトと接続設定テンプレート
    - **含めないもの**:
        - 講師用ファイル
        - ドキュメント
        - ローカルの `.env` や生成キャッシュ
    ### このハンズオンで追加したもの
    
    Building Blocks の基盤に加えて、教育目的で以下を追加しています:
    
    - **`setup/instructor/`**: 講師用 Milvus 環境（Docker Compose）
    - **`setup/participant/`**: 受講者用接続テストスクリプト
    - **`docs/`**: ハンズオン用ドキュメント（MkDocs）
    
    #### 1. 講師・受講者分離アーキテクチャ
    
    Building Blocks 単体:
    
    - 各自が Milvus 環境を構築（Docker/Podman/Colima）
    - 個別に埋め込みモデルをダウンロード（約 460 MB）
    - 環境構築に 30 分程度必要
    
    このハンズオンの工夫:

    - **講師**: Milvus 環境を一元管理（`setup/instructor/docker-compose.yml`）
    - **受講者**: IBM Bob、`.bob/custom_modes.yaml`、`.bob/rules-vector-search-builder/`、受講者用スクリプト、接続情報のみで参加
    
    #### 2. ハイブリッド配信対応
    
    Building Blocks 単体:
    
    - ローカル環境での実行を想定
    
    このハンズオンの工夫:

    - **オンサイト**: ローカルネットワーク共有（`http://講師 IP:8001`）
    - **リモート**: GitHub Pages または ngrok によるドキュメント配信
    
    #### 3. API キー不要の設計
    
    Building Blocks 単体:
    
- クラウド型の埋め込みモデルでは API キーが必要になる場合がある
- 受講者が認証情報を個別に設定
    
    このハンズオンの工夫:

    - **Hugging Face Transformers** を使用（API キー不要）
    - **ローカル実行**: インターネット接続のみで動作
    
    #### 4. 段階的な学習パス
    
    Building Blocks 単体:
    
    - 技術的な実装に焦点
    
    このハンズオンの工夫:

    - **Part 1**: Vector Search の体験（理解）
    - **Part 2**: IBM Bob での機能追加（実践）
    - **Part 3**: コードレビューと改善（応用）
    
    ### 役割分担のまとめ
    
    | 提供元 | 提供内容 | 目的 |
    |:---|:---|:---|
    | **Building Blocks** | Vector Search Builder モード<br/>FastAPI サンプル<br/>Milvus セットアップガイド | 技術基盤の提供<br/>開発の加速 |
    | **このハンズオン** | 講師用環境（Docker Compose）<br/>受講者用スクリプト<br/>教育用ドキュメント | 教育設計<br/>学習体験の最適化 |
    
    !!! success "このハンズオンのメリット"
        **Building Blocks（技術基盤）** + **ハンズオン独自の工夫（教育設計）** = **短時間で高い学習効果**
        
        - **セットアップ時間の短縮**: 30 分 → 5 分（講師が環境を一元管理）
        - **API キー不要**: Hugging Face 使用で受講者の準備負担を削減
        - **柔軟な開催形式**: オンサイト/リモート/ハイブリッド開催に対応
        - **段階的な学習**: 初心者でも理解 → 実践 → 応用と進められる

## IBM Bob とは？

**IBM Bob** は、AI がコーディングをサポートしてくれる開発ツールです。

### IBM Bob でできること

- **自然言語で指示**: やりたいことを言葉で伝えられる
- **コードを自動生成**: 高品質なコードを自動的に書いてくれる
- **コードレビュー**: コードの問題点を指摘してくれる
- **Building Blocks との連携**: Custom モードで、技術に特化した支援を提供

### Building Blocks との相乗効果

**Building Blocks 単体**:

- 基盤となる機能は提供されるが、カスタマイズには技術知識が必要

**IBM Bob 単体**:

- コード生成は可能だが、ゼロから構築するため時間がかかる

**Building Blocks + IBM Bob**:

- Building Blocks で基盤を即座に構築
- IBM Bob で自然言語指示だけでカスタマイズ
- **結果**: 最短時間で本番レベルの品質を実現

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

**合計**: 約 90 分

| パート | 内容 | 所要時間 |
|:---|:---|---:|
| [事前準備](preparation.md) | Vector Search Builder のセットアップ | 15 分 |
| [Part 1](part1.md) | Vector Search を体験 | 20 分 |
| [Part 2](part2.md) | IBM Bob で機能を追加 | 30 分 |
| [Part 3](part3.md) | 動作確認 | 15 分 |
| [まとめ](summary.md) | 振り返り・質疑 | 10 分 |

??? info "このハンズオンのドキュメント設計について"
    
    ### 前半と後半で手動方法の記載が異なる理由
    
    このハンズオンでは、**前半（準備・Part 1）では IBM Bob に依頼する方法と手動で実行する方法を併記**していますが、**後半（Part 2-3）では IBM Bob に依頼する方法のみ**を記載しています。これには以下の理由があります：
    
    **1. 手動作業の複雑さと長大さ**
    
    - **前半の作業**: 単純なコマンド実行（`pip install -r requirements.txt`、`python test_connection.py`）で、手動でも1行で完結
    - **後半の作業**: `app.py`、`schema.py`、データ投入スクリプト、サンプル商品データなど複数ファイルの編集、データモデル・レスポンス構造・エラーハンドリングの変更など、数十行〜数百行のコード変更が必要。手動で記載すると非常に長く複雑になり、ドキュメントが膨大になる
    
    **2. 教育的な意図**
    
    - **前半**: 「IBM Bob でもできるし、手動でもできる」という**選択肢を示す**
    - **後半**: 「手動では困難なことが IBM Bob なら簡単」という**価値を体感させる**
    
    ??? example "Building Blocks + IBM Bob の価値を体感"
        特に、[**`/search` API の JSON レスポンスに `image_url` フィールドを追加する短い指示**](part2.md#feature-1-product-image-display)で複雑なコード変更が完了する体験は、**Building Blocks + IBM Bob の価値を最も効果的に伝える**設計になっています。
        
        **なぜこの指示が最も効果的なのか**:
        
        **Building Blocks の効果**:
        
        - **Vector Search の知識**: IBM Bob が Vector Search Builder モードにより、Milvus、埋め込みモデル、ベクトル検索のベストプラクティスを理解している
        - **既存の基盤**: サンプルデータ、API構造、共通スキーマ定義、データモデルが既に整備されており、IBM Bob はそれを活用して機能追加できる
        - **技術選定不要**: Milvus、埋め込みモデル、API設計などの技術選定が完了しており、IBM Bob は実装に集中できる
        
        **IBM Bob の効果**:
        
        - **自然言語での指示**: たった 1 行、日本語の自然な表現で、技術的な詳細を一切含まない
        - **自動コード生成**: 複数ファイルの編集、スキーマ・データモデルの変更、レスポンス構造の変更を自動実行
        - **即座の成果**: 指示後すぐに動作確認でき、「本当に動いた」という実感を得られる
        
        **IBM Bob と Building Blocks の相乗効果**:
        
        - **Part 2 の最初の体験**: 受講者が初めて「自分で機能を追加する」瞬間であり、印象に残りやすい
        - **他の指示との対比**: 価格フィルターやレコメンド理由も同様に簡単だが、この最初の体験が最も衝撃的
        - **複雑さとのギャップ**: Building Blocks なしでは数日かかる作業が、IBM Bob の 1 行の指示で完了する
    
    **3. Building Blocks の価値訴求**
    
    - 「数日〜数週間 → 約 90 分」という時間短縮効果を実感させる
    - 後半で手動方法を省略することで、この効果を強調
    
    **4. 時間制約への配慮**
    
    - 全体で約 90 分の設計
    - 手動方法を詳細に説明すると、読むだけで時間切れ
    - IBM Bob 依頼に絞ることで、**実際に手を動かす時間を確保**
    
    **5. エラーハンドリングの複雑さ**
    
    手動でコード変更する場合、構文エラー、インデントエラー、型エラー、ロジックエラーなどのトラブルシューティングが必要。これらを全て記載すると、ドキュメントが数倍の長さになる
    
    **6. 段階的な学習設計**
    
    - **前半**: 簡単な作業で IBM Bob の使い方に慣れる
    - **後半**: 複雑な作業で IBM Bob の真価を体験する
    
    この設計により、受講者は自然に IBM Bob の価値を理解し、実践的なスキルを習得できます。

## 必要なもの

- **パソコン**（Mac、Windows）とインターネット接続
- **IBM Bob**（既にインストール済み）
- **Web ブラウザ**（Chrome、Firefox、Safari、Edge など）

**講師から配布**:

- ハンズオン手順書の URL
- Vector Search Builder の受講者用パッケージ（`vector-search-builder-ja.zip`）
- 接続情報（Milvus 接続情報）

## 次のステップ

それでは、[事前準備](preparation.md) のページに進みましょう！
