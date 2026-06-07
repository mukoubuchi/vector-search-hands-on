# まとめ

これで Vector Search ハンズオンは完了です。お疲れ様でした 🍺

## 学んだこと

### Building Blocks + IBM Bob の価値

- **開発時間の大幅短縮**: 数日〜数週間かかる開発を約 90 分で完了
- **高品質な実装**: ベストプラクティスに基づいたコード生成
- **自然言語での指示**: プログラミング知識がなくても機能追加が可能

### 実装した機能

1. **商品画像の表示**: 検索結果に画像を追加
2. **価格フィルター**: 価格帯で絞り込み
3. **レコメンド理由**: なぜその商品がおすすめなのかを表示

### Vector Search の概要

- 言葉の「意味」を理解して検索する
- 従来の文字検索と違い、言い方が違っても似た意味なら見つかる

??? example "IBM 製品における活用例"
    - **watsonx Discovery**: 大量の文書から関連情報を自動抽出し、ユーザーの質問に対して最適な回答を提示（商品画像の表示）
    - **watsonx Assistant**: 顧客からの問い合わせ内容を理解し、過去の類似事例から最適な回答を自動生成（価格フィルター）
    - **watsonx Orchestrate**: 業務プロセス全体を理解し、ユーザーの意図に応じて適切なワークフローを自動実行（レコメンド理由）

??? example "身近なサービスにおける活用例"
    - **Google 検索**: 入力した言葉と完全一致しなくても、意味が近いページや質問への回答候補を見つける（レコメンド理由）
    - **Amazon**: 商品名が分からなくても、説明や用途が近い商品を探したり、似た商品をおすすめしたりする（商品画像の表示、価格フィルター、レコメンド理由）
    - **YouTube**: 視聴履歴や動画内容の近さから、次に見たい動画や関連動画を提案する（商品画像の表示、レコメンド理由）
    - **Netflix**: 見た作品のジャンル、雰囲気、視聴傾向に近い作品をおすすめする（商品画像の表示、レコメンド理由）
    - **Spotify**: 好きな曲やプレイリストに近い音楽を見つけ、レコメンドや自動プレイリストに反映する（商品画像の表示、レコメンド理由）
    - **Instagram**: 写真、動画、ハッシュタグ、興味関心の近さから投稿や広告を並べ替える（商品画像の表示、レコメンド理由）
    - **Facebook**: 投稿内容やユーザーの関心に近いフィード、グループ、広告を表示する（商品画像の表示、レコメンド理由）
    - **TikTok**: 視聴・スキップ・いいねなどの行動から、好みに近い短尺動画を次々に推薦する（商品画像の表示、レコメンド理由）
    - **Google フォト / Apple 写真**: 「海」「犬」「夕焼け」などの言葉で、画像の意味に近い写真を探す（商品画像の表示）
    - **ChatGPT / AI チャット**: 質問に近い社内文書やナレッジを探して、回答の根拠として利用する（レコメンド理由）

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

## 顧客システムにおける価値

Vector Search を顧客の既存システムに組み込む場合、単に検索 API を作るだけでなく、データ連携、埋め込み生成、ベクトル DB、検索 API、画面表示、運用設計までをつなぐ必要があります。**Vector Search Builder + IBM Bob** を使うことで、技術選定と実装の土台を再利用しながら、顧客固有の要件に集中できます。

**Vector Search Builder なしで顧客システムに組み込む場合:**

![Vector Search Builder なしで顧客システムに組み込む場合](images/customer-system-without-building-blocks-ja.svg)

**Vector Search Builder + IBM Bob で顧客システムに組み込む場合:**

![Vector Search Builder + IBM Bob で顧客システムに組み込む場合](images/customer-system-with-building-blocks-ja.svg)

この違いにより、プロジェクトでは以下の価値を出しやすくなります。

- **立ち上がりが速い**: Vector Search の基本構成を短時間で用意できる
- **顧客要件に集中できる**: 業務データ、画面、検索条件、説明文などの差別化部分に時間を使える
- **改善を回しやすい**: IBM Bob に自然言語で依頼しながら、検索結果や UI を素早く調整できる

## 課題

??? challenge "発展課題: Agentic RAG における検索手法の比較"

    **テーマ**: Agentic RAG における Lexical Search と Vector Search の Harness Engineering による差異について調査してみましょう！

    **調査のポイント**
    
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
    
    **推奨アプローチ**
    
    - 実際のユースケースで両手法を比較実装
    - 検索精度、応答時間、コストを定量評価
    - Building Blocks の Agent Builder モードを活用
    - 評価結果をドキュメント化して共有
    
    この課題を通じて、RAG システムの設計における重要な意思決定ポイントを理解できます。

## 参考資料

- [Building Blocks ドキュメント](https://ibm-self-serve-assets.github.io/building-blocks-docs/)
- [Vector Search Builder ドキュメント](https://ibm-self-serve-assets.github.io/building-blocks-docs/data-core/retrieval/vector-search/?h=vector)
- [IBM Bob IDE ドキュメント](https://bob.ibm.com/docs/ide)
- [Hugging Face Transformers](https://huggingface.co/docs/transformers)
- [Sentence Transformers](https://www.sbert.net/)
