# 事前準備

ハンズオンをスムーズに進めるために、以下の準備を完了してください。

## 📋 参加者への事前準備依頼

### 1. IBM Bob のセットアップ

#### IBM Bob アカウントの作成

- [30日間無料トライアル](https://bob.ibm.com/trial)から登録
- 登録ガイドは[こちら](https://qiita.com/Asuka_Saito/items/c0c4b83a485351bd3412)を参照

#### IBM Bob IDE のインストール

- [ダウンロードページ](https://bob.ibm.com/download)からインストーラーを取得
- お使いの OS に合わせてインストール

### 2. Vector Search Bob Mode のインストール

1. ハンズオン用プロジェクトフォルダを作成（例: `vector-search-handson/`）
2. 配布された `vector-search-builder.zip` をプロジェクトフォルダに配置
3. zip ファイルを解凍（右クリック → 解凍 または `unzip vector-search-builder.zip`）
4. `.bob/` フォルダがプロジェクトルートに作成されることを確認
5. IBM Bob でプロジェクトフォルダを開く（File → Open Folder）
6. **Cmd + Shift + P** → 「Reload Window」を実行
7. 右下の「Mode」セレクターに「Vector Search Builder」が表示されることを確認

### 3. IBM TechZone 環境へのアクセス

#### 環境情報

- **環境名**: 「wxO with Milvus, watsonx.ai, Code Engine (SaaS) - IBM ID」
- **含まれるサービス**:
  - watsonx.data（**Milvus**）- ベクトルデータベース
  - watsonx.ai Studio & Runtime - 埋め込み生成
  - Cloud Object Storage (COS) - ドキュメント保存
  - Code Engine - アプリケーションデプロイ

#### アクセス方法

- Workshop 機能を使用し、講師が一括で環境を予約
- 各受講者に個別のアクセス情報を配布（個別の環境予約は不要）

## 🛠️ 講師側の事前準備（ハンズオン前日まで）

### 1️⃣ ベクトルデータベースのセットアップ（30 分）

- watsonx.data（**Milvus**）の環境構築
- 接続情報の準備

### 2️⃣ サンプルデータの投入とインデックス作成（2-3 時間）

- 商品データ（画像、説明、カテゴリ、価格）の準備
- watsonx.ai でベクトル埋め込みの生成
- **Milvus** へのインデックス作成と最適化

### 3️⃣ ベースアプリケーションの準備（1-2 時間）

- 基本的な検索 UI のテンプレート
- FastAPI による REST API の実装
- Swagger UI の設定（API ドキュメント自動生成）
- 環境変数の設定ファイル

#### Swagger UI について

- **概要**: REST API のドキュメントを自動生成し、インタラクティブに操作できる Web インターフェース
- **機能**:
  - API エンドポイント、パラメータ、レスポンス形式を自動表示
  - ブラウザから直接 API を実行可能（「Try it out」ボタン）
  - レスポンスをリアルタイムで確認
- **アクセス**: `http://localhost:8000/docs`
- **メリット**:
  - コードを書かずに API の動作を確認
  - ドキュメントが常に最新（コードから自動生成）
  - 学習コスト削減と開発効率化

**合計準備時間**: 約 4-6 時間

!!! note
    これらの準備により、ハンズオン当日は参加者が 1 時間で完結できます

## 🔄 代替案: TechZone 環境が利用できない場合

TechZone 環境の予約に問題が発生した場合、以下の代替案を検討できます。

!!! warning "TechZone 環境の制約"
    現在、TechZone 環境「wxO with Milvus, watsonx.ai, Code Engine (SaaS) - IBM ID」は以下のリージョンでのみ利用可能です：
    
    - `us-south`（米国南部）- **推奨**
    - `eu-de`（ドイツ）
    
    日本リージョン（`jp-tok`）は現在利用できません。`us-south` を選択してください。

### 代替案 1: ローカル環境（Docker Desktop）

**構成**:

- **Milvus**: Docker Compose でローカルに構築
- **watsonx.ai**: IBM Cloud で各自 API キーを取得

**受講者の事前準備**:

1. **Docker Desktop のインストール**
   - [Docker Desktop for Mac](https://www.docker.com/products/docker-desktop)
   - [Docker Desktop for Windows](https://www.docker.com/products/docker-desktop)
   - メモリ 8GB 以上推奨

2. **watsonx.ai API キーの取得**
   - [IBM Cloud](https://cloud.ibm.com/) にログイン
   - watsonx.ai サービスを作成
   - API Key を取得

3. **配布パッケージの展開**
   ```bash
   # vector-search-handson.zip を解凍
   cd vector-search-handson
   
   # Milvus を起動
   docker-compose up -d
   
   # 接続確認
   curl http://localhost:9091/healthz
   ```

**メリット**:

- ✅ TechZone 環境の予約不要
- ✅ 各自のペースで進められる
- ✅ ハンズオン後も環境を保持できる

**デメリット**:

- ⚠️ Docker Desktop のインストールが必要
- ⚠️ watsonx.ai API キーの取得が必要
- ⚠️ 初回起動時に Docker image のダウンロード（数分）

### 代替案 2: 共有 Milvus 環境

**構成**:

- **Milvus**: 講師の PC で Docker Compose を起動
- **watsonx.ai**: 講師の API キーを共有

**受講者の事前準備**:

1. **IBM Bob IDE のみインストール**
2. **配布パッケージの展開**
3. **接続先を講師の Milvus に設定**

**メリット**:

- ✅ 受講者は Docker 不要
- ✅ セットアップが最も簡単
- ✅ 全員が同じ環境を使用

**デメリット**:

- ⚠️ 講師の PC に負荷が集中
- ⚠️ ネットワーク接続が必要
- ⚠️ 同時アクセスによる競合の可能性

### 代替案 3: 事前ベクトル化データ

**構成**:

- サンプルデータを事前にベクトル化して配布
- 検索のみ実行（新規データの追加なし）

**メリット**:

- ✅ watsonx.ai API キー不要
- ✅ 最も簡単な方法

**デメリット**:

- ⚠️ ベクトル化のプロセスを体験できない
- ⚠️ 学習内容が限定的

### 推奨する代替案

**受講者数に応じて選択**:

- **5 人以下**: 代替案 2（共有 Milvus 環境）- [詳細ガイド](alternative-setup-pattern-b.md)
- **6〜10 人**: 代替案 1（ローカル環境）
- **10 人以上**: TechZone 環境（推奨）

!!! tip "代替案 2 の詳細"
    講師が共有環境を提供する方法の詳細な手順は、[代替案 B: 講師が共有環境を提供](alternative-setup-pattern-b.md)を参照してください。
    
    - Docker Compose ファイル
    - 受講者向け設定ファイル
    - トラブルシューティング
    
    すべて準備済みです。

!!! warning "重要"
    代替案はあくまで緊急時の対応です。TechZone 環境が最もスマートで、受講者の準備が最小限で済みます。

## ✅ 準備完了チェックリスト

準備が完了したら、以下を確認してください：

- [ ] IBM Bob アカウントが作成済み
- [ ] IBM Bob IDE がインストール済み
- [ ] Vector Search Builder モードが表示される
- [ ] TechZone 環境のアクセス情報を受領済み
- [ ] Web ブラウザが利用可能

準備が完了したら、[Part 1: 環境確認とデモ](part1.md)に進みましょう！
