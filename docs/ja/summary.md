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

## 参考資料

- [Building Blocks ドキュメント](https://ibm-self-serve-assets.github.io/building-blocks-docs/)
- [Building Blocks の Vector Search ドキュメント](https://ibm-self-serve-assets.github.io/building-blocks-docs/ai-core/data/vector-search/)
- [IBM Bob IDE ドキュメント](https://bob.ibm.com/docs/ide)
- [Hugging Face Transformers](https://huggingface.co/docs/transformers)
- [Sentence Transformers](https://www.sbert.net/)

[次へ →](feedback.md){ .workshop-next }
