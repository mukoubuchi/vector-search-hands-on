# 1️⃣ Part 1: 環境確認とデモ

**所要時間**: 15 分

このパートでは、開発環境の確認と Vector Search の動作デモを行います。

## 1. Building Blocks の概要復習

### Session 1 の振り返り（5 分）

- Building Blocks とは何か
- Vector Search の位置づけと活用シーン
- 参照: [Building Blocks ドキュメント](https://ibm-self-serve-assets.github.io/building-blocks-docs/)

### Vector Search の選定理由

Building Blocks には IBM Bob を使った 60 分以内に完了できる Bob Mode として、以下の 3 つが提供されています：

1. **Text2SQL** — 自然言語から SQL クエリを生成
2. **Agent Builder** — マルチエージェントシステムの構築
3. **Vector Search** — セマンティック検索とレコメンデーション

この中から **Vector Search** を選定した理由：

- **所要時間が最短**: 3 つの中で最も短時間（約 60 分）で完了可能
- **SQL 知識不要**: データベースや SQL の知識がなくても直感的に理解できる
- **Sales 向けの親しみやすさ**: 「意味で検索する」という概念が日常的で理解しやすい
- **即座に動作確認可能**: TechZone 環境で完全に動作する実装が提供されている
- **実用的なユースケース**: 商品レコメンデーション、ドキュメント検索など、Sales が顧客に説明しやすい

## 2. 開発環境の確認

以下の環境が正しく動作することを確認します：

### IBM Bob の起動確認

- IBM Bob IDE が起動すること
- Vector Search Builder モードが選択できること

### TechZone 環境へのアクセス確認

- watsonx.data（**Milvus**）環境にアクセスできること
- 接続情報が正しく設定されていること

### watsonx.ai の API キー確認

- API キーが正しく設定されていること
- 埋め込みモデルにアクセスできること

### サンプルデータの確認

- 事前準備済みのサンプルデータが利用可能であること

### Swagger UI で API の動作確認

`http://localhost:8000/docs` にアクセスして、以下を確認します：

- `/health` エンドポイントでサービスの稼働確認
- `/search` エンドポイントの確認

## 3. Vector Search の動作デモ

### Swagger UI を使った実演

1. Swagger UI（`http://localhost:8000/docs`）を開く
2. `/search` エンドポイントを選択
3. 「Try it out」ボタンをクリック
4. 検索クエリを入力（例: 「赤いスニーカー」）
5. 「Execute」ボタンをクリック

### セマンティック検索の仕組み

Vector Search は以下のフローで動作します：

```text
1. ドキュメント取得
   IBM Cloud Object Storage (COS) から PDF/Word などを取得
   ↓
2. ドキュメント解析
   Docling でドキュメントをパース（構造化テキストに変換）
   ↓
3. ベクトル埋め込み生成
   watsonx.ai でテキストをベクトル（数値配列）に変換
   ↓
4. ベクトルデータベースに保存
   Milvus にベクトルとメタデータを保存
   ↓
5. セマンティック検索
   ユーザーのクエリをベクトル化し、類似ベクトルを検索
```

### レコメンデーション結果の確認

- JSON レスポンスの構造を確認
- 類似度スコアの意味を理解
- 検索結果の精度を確認

## 主要技術の説明

### Docling

- IBM が開発したドキュメント解析・パースツール
- PDF、Word、画像などの非構造化データを構造化テキストに変換
- レイアウト認識（見出し、段落、表、画像など）とメタデータ抽出
- RAG（Retrieval-Augmented Generation）システムの構築に不可欠

### Milvus

- **概要**: 数十億規模のベクトル検索に最適化された高性能ベクトルデータベース
- **特徴**:
  - オープンソースのベクトルデータベース（Apache 2.0 ライセンス）
  - 大規模データセット（数十億ベクトル）に対応
  - ミリ秒単位の高速検索
  - 複数のインデックスアルゴリズム（HNSW、IVF_FLAT など）をサポート
- **用途**:
  - セマンティック検索（意味ベースの検索）
  - レコメンデーションシステム
  - RAG（Retrieval-Augmented Generation）
  - 画像・音声・動画の類似検索
- **IBM watsonx との統合**:
  - watsonx.ai で生成した埋め込みベクトルを保存
  - watsonx.data と連携したハイブリッド検索
  - IBM Cloud Object Storage (COS) からのデータ取り込み

## ✅ Part 1 完了チェック

- [ ] Building Blocks の概要を理解した
- [ ] 開発環境が正しく動作することを確認した
- [ ] Swagger UI で API の動作を確認した
- [ ] Vector Search の仕組みを理解した
- [ ] レコメンデーション結果を確認した

準備ができたら、[Part 2: IBM Bobでカスタマイズ](part2.md)に進みましょう！
