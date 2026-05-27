# 詳細情報

このページでは、ハンズオンで使用する技術や必要な環境について詳しく説明します。

## 必要なもの

### 必須

- **パソコン**（Mac、Windows）
    - インターネット接続: 必須

- **IBM Bob**
    - 既にインストールされ、使用できる状態

- **Web ブラウザ**
    - Chrome、Firefox、Safari、Edge など

### 講師から配布されるもの

- **ハンズオン手順書の URL**（本ドキュメント）
- **Vector Search Builder**（zip ファイル）
- **接続情報**（Milvus 接続情報）

## 期待される成果

このハンズオンを完了すると、以下ができるようになります：

### 理解できること

- Vector Search とは何か
- 従来の検索との違い
- IBM Bob の基本的な使い方

### できるようになること

- Vector Search のデモができる
- IBM Bob で簡単な機能追加ができる
- 顧客に Vector Search の価値を説明できる

## 使用する技術スタック

このハンズオンでは、以下の技術を使用します：

### **IBM Building Blocks: Vector Search Builder**

- **役割**: Vector Search 機能の統合基盤
- **提供内容**:
    - Milvus データベースの構築・管理
    - 埋め込みモデルの統合（watsonx、HuggingFace、ローカル）
    - データ取り込みパイプライン
    - 検索最適化機能
- **特徴**: すぐに使える、ベストプラクティス実装済み

### **Milvus（ミルバス）**

- **役割**: ベクトルデータベース
- **機能**: ベクトルデータを保存・検索
- **特徴**: 高速・大規模データに対応
- **提供形態**: Building Blocks でセットアップ済み、最適化済み

### **埋め込みモデル（Hugging Face Transformers）**

- **役割**: テキストを数値に変換する AI
- **機能**: テキストの「意味」をベクトル（数値の配列）に変換
- **特徴**: 自然言語対応・高精度、API キー不要
- **このハンズオンでの選択**: Building Blocks は複数の埋め込みモデル（watsonx、HuggingFace、ローカル）に対応しており、このハンズオンでは Hugging Face を選択

### **IBM Bob + Vector Search Builder Mode**

- **役割**: AI 開発アシスタント
- **機能**:
    - Vector Search に特化したコード生成
    - Building Blocks の機能を活用したカスタマイズ
    - コードレビュー・サポート
- **特徴**: 自然言語で指示できる、Vector Search の専門知識を持つ

!!! tip "Building Blocks の価値"
    **IBM Building Blocks: Vector Search Builder** は、これらの技術を統合した事前構築済みのソリューションです：
    
    - 複雑な設定が不要（すぐに使える）
    - 相互連携が保証されている（動作確認済み）
    - IBM Bob が全体を理解してサポート（専用モード）

## 次のステップ

準備ができたら、[事前準備](preparation.md) のページに進みましょう！