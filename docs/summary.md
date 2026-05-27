# まとめ

おめでとうございます！Vector Search ハンズオンを完了しました！

## 学んだこと

### Vector Search

- 言葉の「意味」を理解して検索する技術
- 従来の文字検索より賢く、言い方が違っても似た意味なら見つかる
- EC サイト、社内ドキュメント、FAQ など幅広く活用可能

### IBM Bob

- 自然言語で指示を出すだけでコードを生成
- `/review` コマンドでコードレビュー
- 数分で高品質なコードを実装

### 実装した機能

1. **商品画像の表示**: 検索結果に画像を追加
2. **価格フィルター**: 価格帯で絞り込み
3. **レコメンド理由**: なぜその商品がおすすめなのかを表示

## 業務での活用

### 営業・セールス

**デモ**:

- 実際に動く Vector Search アプリを見せられる
- 従来の検索との違いを実演
- 類似度スコアとレコメンド理由の価値を説明

**提案ユースケース**:

- EC サイト: 商品レコメンデーション、検索精度向上
- 社内システム: ドキュメント検索、ナレッジベース
- カスタマーサポート: FAQ 検索、対応時間短縮

### エンジニア

**プロトタイプ作成**:

- IBM Bob で素早く実装
- PoC、デモアプリ、技術検証に活用

**開発効率化**:

- コーディング時間の短縮
- ベストプラクティスの自動適用
- コードレビューの自動化

## 次のステップ

### Building Blocks の他の機能

Building Blocks には Vector Search 以外にも、専用の Bob Mode を持つものが多数あります：

- **Agent Builder**: 自律型 AI エージェント、音声対応エージェントの構築
- **Multi-Agent Orchestration**: 複数エージェントの協調制御
- **Agent Ops**: AI エージェントの運用管理とパフォーマンス監視
- **Model Evaluation**: Gen AI/予測 ML モデルの評価
- **Text2SQL**: 自然言語から SQL クエリを生成
- **Data Pipeline AI-Generated**: データパイプラインの自動生成
- **Zero-Copy Lakehouse**: データコピー不要のレイクハウス構築
- **IaaS**: Terraform/CloudFormation テンプレート生成
- **Automated Resilience and Compliance**: 自動レジリエンスとコンプライアンス
- **Automated Resource Management**: リソース自動管理とコスト最適化
- **Secrets Management**: シークレットと非人間アイデンティティの管理

### IBM Bob の高度な機能

- **Orchestrator モード**: 複雑なプロジェクトの管理
- **カスタムモード**: 独自のワークフロー作成

### プロジェクトアイデア

- 社内ナレッジベース
- 商品レコメンデーション
- カスタマーサポート

## 本番環境への展開

### 現在の構成（学習用）

- **Hugging Face + Milvus**: 完全無料、オフライン対応、学習に最適

### IBM 製品への移行

- **watsonx.ai**: エンタープライズグレード、高度なモデル、商用サポート
- **watsonx.data**: 大規模データ統合、ガバナンス機能、ペタバイト対応

### 選択ガイド

| 規模 | 推奨構成 |
|------|---------|
| 学習・PoC | Hugging Face + Milvus |
| 小規模本番 | Hugging Face + Milvus |
| 中規模本番 | watsonx.ai + Milvus |
| 大規模本番 | watsonx.ai + watsonx.data |

## 課題

??? challenge "発展課題: Agentic RAG における検索手法の比較"

    **テーマ**: Agentic RAG における Lexical Search と Vector Search の Harness Engineering による差異について調査してみましょう！

    ### 調査のポイント
    
    1. **Lexical Search（語彙検索）**
        - キーワードマッチング、BM25 などの従来型検索
        - 完全一致や部分一致による検索精度
        - Agentic RAG での活用シーン
    
    2. **Vector Search（ベクトル検索）**
        - 意味的類似性に基づく検索
        - 埋め込みモデルによる表現学習
        - Agentic RAG での活用シーン
    
    3. **Harness Engineering（ハーネスエンジニアリング）**
        - 両手法の組み合わせ方
        - ハイブリッド検索の実装パターン
        - スコアリングと再ランキング戦略
    
    4. **Agentic RAG における差異**
        - エージェントの意思決定への影響
        - 検索精度と応答品質の関係
        - コストとパフォーマンスのトレードオフ
    
    ### 推奨アプローチ
    
    - 実際のユースケースで両手法を比較実装
    - 検索精度、応答時間、コストを定量評価
    - Building Blocks の Agent Builder モードを活用
    - 評価結果をドキュメント化して共有
    
    この課題を通じて、RAG システムの設計における重要な意思決定ポイントを理解できます。

## 参考資料

- [Building Blocks ドキュメント](https://ibm-self-serve-assets.github.io/building-blocks-docs/)
- [IBM Bob ドキュメント](https://bob.ibm.com/docs)
- [Hugging Face Transformers](https://huggingface.co/docs/transformers)
- [Sentence Transformers](https://www.sbert.net/)
