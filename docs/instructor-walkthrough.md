# Vector Search ハンズオン 実践手順書（講師用）

## 📌 このドキュメントについて

**対象者**: 講師・ファシリテーター・経験者

**目的**:
- ハンズオンの進行ガイドとして使用
- 各ステップの実施結果と所要時間を記録
- トラブルシューティングの参考資料

**特徴**:
- ✅ 実際の実施結果を記録（実行コマンドと出力例）
- ✅ 各ステップの所要時間を明記
- ✅ チェックリストで進捗管理
- ✅ 1ファイルで完結（印刷・共有が容易）

---

## 🔄 MkDocsドキュメントとの違い

| 項目 | MkDocsドキュメント | この実践手順書（講師用） |
|------|-------------------|----------------------|
| **対象者** | 初心者・受講者 | 講師・経験者 |
| **形式** | Webサイト（複数ページ） | 1つのMarkdownファイル |
| **内容** | 詳しい概念説明・背景知識 | 実践的な手順・実行結果 |
| **説明** | 「なぜ」「どうやって」を丁寧に | 「何を」「どうする」を簡潔に |
| **ナビゲーション** | サイドバー・検索機能あり | 目次のみ |
| **使用シーン** | 学習・理解・デモ | 進行管理・復習・再実施 |
| **所要時間** | 記載なし | 各ステップに明記 |
| **実行結果** | 期待される出力のみ | 実際の出力例を記録 |
| **チェックリスト** | なし | 各パートに用意 |

**推奨される使い方**:
- **受講者**: [`docs/participant/`](docs/participant/README.md)のMkDocsドキュメントを使用
- **講師**: この実践手順書を進行ガイドとして使用
- **復習**: この実践手順書で素早く再実施

---

## 📋 目次

1. [事前準備（講師側）](#1-事前準備講師側)
2. [受講者側の準備（講師がガイド）](#2-受講者側の準備講師がガイド)
3. [Part 1: 環境確認とデモ（講師がガイド）](#3-part-1-環境確認とデモ講師がガイド)
4. [Part 2: IBM Bobで機能追加（講師がガイド）](#4-part-2-ibm-bobで機能追加講師がガイド)
5. [Part 3: 動作確認とレビュー（講師がガイド）](#5-part-3-動作確認とレビュー講師がガイド)
6. [まとめと振り返り（講師がガイド）](#6-まとめと振り返り講師がガイド)
7. [トラブルシューティング（講師用リファレンス）](#7-トラブルシューティング講師用リファレンス)

---

## 1. 事前準備（講師側）

### 1.1 講師が準備するもの

✅ **必要な環境**:
- Docker Desktop（インストール済み）
- インターネット接続
- 受講者と同じネットワーク（または受講者からアクセス可能なネットワーク）

### 1.2 Milvus環境の起動

```bash
cd setup
./start-all.sh
```

**実行結果**:
```
Starting Milvus and MkDocs services...
Creating network "setup_default" with the default driver
Creating milvus-etcd ... done
Creating milvus-minio ... done
Creating milvus-standalone ... done
Creating vector-search-docs ... done

Services started successfully!

Milvus is running on:
  - Host: 0.0.0.0
  - Port: 19530

MkDocs documentation is available at:
  - http://localhost:8001
  - http://192.168.1.100:8001  (for participants)

Your IP address: 192.168.1.100
```

**実施結果**: ✅ Milvus起動完了

### 1.3 講師のIPアドレスの確認

**macOS/Linux**:
```bash
ifconfig | grep "inet " | grep -v 127.0.0.1
```

**Windows**:
```cmd
ipconfig | findstr IPv4
```

**実行結果例**:
```
inet 192.168.1.100 netmask 0xffffff00 broadcast 192.168.1.255
```

**講師のIPアドレス**: `192.168.1.100` ← この値を受講者に共有

**実施結果**: ✅ IPアドレス確認完了

### 1.4 受講者への共有情報の準備

受講者に以下の情報を共有します：

```
【ベクトル検索ハンズオン 接続情報】

■ Milvus接続情報
MILVUS_HOST=192.168.1.100
MILVUS_PORT=19530
MILVUS_USER=root
MILVUS_PASSWORD=Milvus

■ 埋め込みモデル設定
EMBEDDING_MODEL=paraphrase-multilingual-MiniLM-L12-v2
EMBEDDING_DIMENSION=384

■ コレクション設定
COLLECTION_NAME=knowledge_base

■ ドキュメントURL
http://192.168.1.100:8001
```

**実施結果**: ✅ 共有情報準備完了

### 1.5 接続テスト（講師側）

講師自身の環境で接続テストを実行：

```bash
cd setup
python test_embeddings_hf.py
```

**期待される出力**:
```
モデルをロード中: paraphrase-multilingual-MiniLM-L12-v2
（初回実行時はモデルのダウンロードに時間がかかります）
✓ モデルのロードに成功しました

埋め込みを生成中...
✓ 3件の埋め込みを生成しました
✓ 埋め込みベクトルの次元数: 384
✓ ベクトルの最初の5要素: [0.123, -0.456, 0.789, ...]
```

**実施結果**: ✅ 接続テスト成功

---

## 2. 受講者側の準備（講師がガイド）

### 2.1 プロジェクトフォルダの準備

```bash
# デスクトップに作業フォルダを作成
mkdir ~/Desktop/vector-search-handson
cd ~/Desktop/vector-search-handson
```

**実施結果**: ✅ フォルダ作成完了

### 2.2 Vector Search Builderモードのインストール（受講者が実施）

1. **zipファイルの配置**
   - `vector-search-builder.zip`をプロジェクトフォルダにコピー
   
2. **解凍**
   ```bash
   unzip vector-search-builder.zip
   ```
   
3. **確認**
   ```bash
   ls -la
   # .bob フォルダが存在することを確認
   ```

**実施結果**: ✅ `.bob`フォルダ確認完了

### 2.3 IBM BobでプロジェクトをOpen（受講者が実施）

1. IBM Bob IDEを起動
2. `File` → `Open Folder`
3. `vector-search-handson`フォルダを選択
4. リロード: `Cmd + Shift + P` → `Developer: Reload Window`

**実施結果**: ✅ Vector Search Builderモードが表示される

### 2.4 必要なパッケージのインストール（受講者が実施）

IBM Bob IDEのターミナルで実行：

```bash
cd setup
pip install -r requirements.txt
```

**期待される出力**:
```
Collecting pymilvus>=2.3.0
Collecting sentence-transformers>=2.2.0
Collecting python-dotenv>=1.0.0
...
Successfully installed pymilvus-2.3.4 sentence-transformers-2.2.2 python-dotenv-1.0.0
```

**実施結果**: ✅ パッケージインストール完了

### 2.5 接続情報の設定（受講者が実施）

受講者に以下の手順を案内：

1. **setupフォルダに移動**
   ```bash
   cd setup
   ```

2. **.envファイルの作成**
   ```bash
   cp .env.example .env
   ```

3. **.envファイルの編集**
   ```bash
   # IBM Bob IDEで setup/.env を開く
   ```
   
   **講師から共有された接続情報をコピー＆ペースト**:
   ```env
   MILVUS_HOST=192.168.1.100  # 講師のIPアドレス
   MILVUS_PORT=19530
   MILVUS_USER=root
   MILVUS_PASSWORD=Milvus
   
   EMBEDDING_MODEL=paraphrase-multilingual-MiniLM-L12-v2
   EMBEDDING_DIMENSION=384
   
   COLLECTION_NAME=knowledge_base
   ```

4. **IBM Bobをリロード**
   - `Cmd + Shift + P` → `Developer: Reload Window`

**実施結果**: ✅ 接続情報設定完了

### 2.6 接続テストの実行（受講者が実施）

```bash
cd setup
python test_connection_simple.py
```

**期待される出力**:
```
==================================================
Milvus & Hugging Face 接続テスト
==================================================

=== 環境変数確認 ===
✓ MILVUS_HOST: 192.168.1.100
✓ MILVUS_PORT: 19530
✓ EMBEDDING_MODEL: paraphrase-multilingual-MiniLM-L12-v2
✓ EMBEDDING_DIMENSION: 384

=== Milvus 接続テスト ===
接続先: 192.168.1.100:19530
✓ Milvusに接続成功
✓ 既存コレクション数: 0

=== Hugging Face Embeddings テスト ===
モデル: paraphrase-multilingual-MiniLM-L12-v2

モデルをロード中...
（初回実行時はモデルのダウンロードに時間がかかります）
✓ モデルのロードに成功しました

埋め込みを生成中...
✓ 3件の埋め込みを生成しました
✓ 埋め込みベクトルの次元数: 384
✓ ベクトルの最初の5要素: [0.123, -0.456, 0.789, -0.234, 0.567]

==================================================
テスト結果サマリー
==================================================
Milvus接続:           ✓ 成功
Hugging Face埋め込み: ✓ 成功

✓ すべての接続テストが成功しました！
```

**実施結果**: ✅ 接続テスト成功

**所要時間**: 約15分

---

## 3. Part 1: 環境確認とデモ（講師がガイド）

### 3.1 Vector Searchの理解（講師が説明）

**学んだこと**:
- Vector Searchは「意味」を理解して検索する
- 従来の検索は「文字」を探すだけ
- ベクトル = テキストを数値の配列に変換したもの

**具体例**:
- 「赤いスニーカー」→「赤色のランニングシューズ」も見つかる
- 「初心者向け」→「入門用」「ビギナー向け」も見つかる

### 3.2 デモアプリケーションの起動（受講者が実施）

**方法1: IBM Bobに依頼（推奨）**

IBM Bobのチャット画面で:
```
setupフォルダでデモアプリケーションを起動して
```

**方法2: 手動で起動**

```bash
cd setup
python app.py
```

**期待される出力**:
```
INFO:     Started server process
INFO:     Waiting for application startup.
INFO:     Application startup complete.
INFO:     Uvicorn running on http://localhost:8000
```

**実施結果**: ✅ アプリケーション起動成功

### 3.3 Swagger UIでの検索テスト（受講者が実施）

1. **ブラウザでSwagger UIを開く**
   ```
   http://localhost:8000/docs
   ```

2. **`/search`エンドポイントをテスト**
   - 「POST /search」をクリック
   - 「Try it out」をクリック
   - Request bodyに入力:
   ```json
   {
     "query": "赤いスニーカー"
   }
   ```
   - 「Execute」をクリック

3. **結果の確認**
   ```json
   {
     "results": [
       {
         "product_name": "赤いランニングシューズ",
         "similarity_score": 0.92,
         "price": 8900,
         "category": "スニーカー",
         "description": "軽量で通気性の良いランニングシューズ"
       }
     ]
   }
   ```

**実施結果**: ✅ 検索成功

### 3.4 色々な検索を試す（受講者が実施）

**テスト1: 初心者向けの商品**
```json
{
  "query": "初心者向けのカメラ"
}
```
→ 「入門用デジタルカメラ」「ビギナー向けカメラ」が見つかる

**テスト2: ビジネス向けの商品**
```json
{
  "query": "ビジネス向けのノートパソコン"
}
```
→ 「ビジネスノートPC」「オフィス用ノートパソコン」が見つかる

**気づき**:
- ✅ 言い方が違っても意味が似ていれば見つかる
- ✅ 類似度スコアで関連度が分かる
- ✅ 説明文も考慮されている

**所要時間**: 約15分

---

## 4. Part 2: IBM Bobで機能追加（講師がガイド）

### 4.1 Codeモードへの切り替え（受講者が実施）

1. 画面右下の「Mode」セレクターをクリック
2. 「💻 Code」を選択

**実施結果**: ✅ Codeモードに切り替え完了

### 4.2 機能1: 商品画像の表示（受講者が実施）

**IBM Bobへの指示**:
```
検索結果に商品画像を表示してください
```

**IBM Bobの応答**:
- 関連ファイルを自動検索
- コードを生成
- 変更内容を説明

**変更内容**:
- `app.py`にimage_urlフィールドを追加
- レスポンスに画像URLを含める

**承認と確認**:
1. 「Apply」ボタンをクリック
2. アプリケーションを再起動
   ```bash
   # ターミナルで Ctrl + C
   python app.py
   ```
3. Swagger UIで検索を実行
4. `image_url`フィールドが追加されていることを確認

**実施結果**: ✅ 商品画像表示機能追加成功

**所要時間**: 約7分

### 4.3 機能2: 価格フィルター（受講者が実施）

**IBM Bobへの指示**:
```
価格帯でフィルターできる機能を追加してください。
最小価格と最大価格を指定できるようにしてください。
```

**IBM Bobの応答**:
- filtersパラメータを追加
- price_rangeでmin/maxを指定可能に

**テスト**:
```json
{
  "query": "スニーカー",
  "filters": {
    "price_range": {
      "min": 5000,
      "max": 10000
    }
  }
}
```

**確認ポイント**:
- ✅ 指定した価格範囲の商品のみ表示される
- ✅ セマンティック検索も機能している

**実施結果**: ✅ 価格フィルター機能追加成功

**所要時間**: 約7分

### 4.4 機能3: レコメンド理由の表示（受講者が実施）

**IBM Bobへの指示**:
```
検索結果に、なぜその商品がレコメンドされたのか、
理由を表示してください。
検索クエリと商品の類似点を説明してください。
```

**IBM Bobの応答**:
- reasonフィールドを追加
- similar_featuresで類似点をリスト表示

**テスト**:
```json
{
  "query": "初心者向けのカメラ"
}
```

**期待される結果**:
```json
{
  "product_name": "エントリーモデル デジタルカメラ",
  "similarity_score": 0.88,
  "reason": "検索クエリ「初心者向けのカメラ」と以下の点で類似しています：",
  "similar_features": [
    "対象: 初心者・入門者向け",
    "カテゴリ: デジタルカメラ",
    "特徴: 簡単操作、オートモード充実"
  ]
}
```

**実施結果**: ✅ レコメンド理由表示機能追加成功

**所要時間**: 約6分

### 4.5 IBM Bob活用のコツ（講師が説明）

**学んだこと**:
- ✅ 具体的に指示する
- ✅ 段階的に進める（一度に複数の機能を依頼しない）
- ✅ 分からないことは質問する
- ✅ エラーが出たら報告する

**所要時間**: 約20分（合計）

---

## 5. Part 3: 動作確認とレビュー（講師がガイド）

### 5.1 追加機能の総合テスト（受講者が実施）

**テスト1: 商品画像の表示**
```json
{
  "query": "赤いスニーカー"
}
```
✅ `image_url`フィールドが表示される

**テスト2: 価格フィルター**
```json
{
  "query": "スニーカー",
  "filters": {
    "price_range": {
      "min": 5000,
      "max": 10000
    }
  }
}
```
✅ 指定範囲の商品のみ表示される

**テスト3: レコメンド理由**
```json
{
  "query": "初心者向けのカメラ"
}
```
✅ `reason`と`similar_features`が表示される

**実施結果**: ✅ すべての機能が正常に動作

### 5.2 IBM Bobのコードレビュー（受講者が実施）

1. **`app.py`を開く**
   - 左側のファイルツリーから選択

2. **`/review`コマンドを実行**
   ```
   /review
   ```

3. **レビュー結果の確認**

**良い点**:
- ✓ RESTful API設計
- ✓ エラーハンドリングが適切
- ✓ コメントが充実
- ✓ 型ヒントの使用

**改善提案**:
- ⚠️ パフォーマンス: ベクトル検索結果のキャッシュを検討
- ⚠️ セキュリティ: 入力値のバリデーション強化
- ⚠️ 保守性: ログ出力の追加を推奨

**実施結果**: ✅ コードレビュー完了

**所要時間**: 約10分

---

## 6. まとめと振り返り（講師がガイド）

### 6.1 学んだこと（講師が説明）

**Vector Searchの理解**:
- ✅ 意味を理解して検索する技術
- ✅ 従来の文字検索より賢い
- ✅ 言い方が違っても見つかる

**IBM Bobの使い方**:
- ✅ 日本語で指示を出すだけでコード生成
- ✅ プログラミング経験不要
- ✅ `/review`コマンドでコードレビュー

**実装した機能**:
- ✅ 商品画像の表示
- ✅ 価格フィルター
- ✅ レコメンド理由の表示

### 6.2 業務での活用方法（講師が説明）

**営業・セールス**:
- 顧客へのデモができる
- ユースケースを提案できる
- 技術的な質問に対応できる

**エンジニア**:
- プロトタイプを素早く作成
- 開発効率が向上
- ベストプラクティスを学べる

### 6.3 次のステップ（講師が説明）

**さらに学びたい方へ**:
- Building Blocksの他の機能（Text2SQL、Agent Builder）
- IBM Bobの高度な機能（Orchestratorモード、カスタムモード）
- 実践的なプロジェクト（社内ナレッジベース、商品レコメンデーション）

**所要時間**: 約5分

---

## 7. トラブルシューティング（講師用リファレンス）

### 7.1 接続テストが失敗する

**症状**: `Connection refused`エラー

**対処法**:
1. `.env`ファイルの内容を確認
2. Milvusサーバーが起動しているか講師に確認
3. ファイアウォール設定を確認

### 7.2 Swagger UIが開けない

**症状**: `http://localhost:8000/docs`にアクセスできない

**対処法**:
1. アプリケーションが起動しているか確認
2. ターミナルでエラーメッセージを確認
3. ポート8000が他のプロセスで使用されていないか確認
   ```bash
   lsof -i :8000
   ```

### 7.3 IBM Bobが応答しない

**症状**: チャットに入力しても反応がない

**対処法**:
1. インターネット接続を確認
2. IBM Bobを再起動
3. Codeモードになっているか確認

### 7.4 検索結果が0件

**症状**: 検索しても結果が返ってこない

**対処法**:
1. サンプルデータが投入されているか確認
2. 検索クエリを変えてみる
3. ターミナルのエラーログを確認

---

## 📊 ハンズオン全体の所要時間

| パート | 内容 | 所要時間 |
|--------|------|----------|
| 事前準備 | 環境セットアップ | 15分 |
| Part 1 | 環境確認とデモ | 15分 |
| Part 2 | IBM Bobで機能追加 | 20分 |
| Part 3 | 動作確認とレビュー | 10分 |
| まとめ | 振り返り | 5分 |
| **合計** | | **約65分** |

---

## 🎯 講師用チェックリスト

### 講師側の事前準備
- [ ] Docker Desktopをインストールした
- [ ] Milvus環境を起動した（`./start-all.sh`）
- [ ] 講師のIPアドレスを確認した
- [ ] 受講者への共有情報を準備した
- [ ] 講師側で接続テストを実施した（`test_embeddings_hf.py`）

### 受講者側の準備（講師がガイド）
- [ ] IBM Bob IDEをインストールした
- [ ] プロジェクトフォルダを作成した
- [ ] Vector Search Builderをインストールした
- [ ] `.env`ファイルに接続情報を設定した
- [ ] 接続テストが成功した

### Part 1
- [ ] Vector Searchの仕組みを理解した
- [ ] デモアプリケーションを起動できた
- [ ] Swagger UIで検索を実行できた
- [ ] 色々な検索を試した

### Part 2
- [ ] Codeモードに切り替えた
- [ ] 商品画像表示機能を追加した
- [ ] 価格フィルター機能を追加した
- [ ] レコメンド理由表示機能を追加した

### Part 3
- [ ] すべての機能をテストした
- [ ] `/review`コマンドを実行した
- [ ] レビュー結果を確認した

### まとめ
- [ ] 学んだことを整理した
- [ ] 業務での活用方法を考えた
- [ ] 次のステップを確認した

---

## 💡 重要なポイント

### Vector Searchの価値
- 意味を理解して検索できる
- ユーザーフレンドリー
- 検索精度が向上

### IBM Bobの価値
- 日本語で指示を出すだけ
- 開発時間が大幅に短縮
- 高品質なコードを生成

### 実践での活用
- 顧客へのデモに使える
- プロトタイプを素早く作成
- 技術検証に活用

---

## 📚 参考資料

- [Building Blocks ドキュメント](https://ibm-self-serve-assets.github.io/building-blocks-docs/)
- [IBM Bob ドキュメント](https://bob.ibm.com/docs)
- [Milvus ドキュメント](https://milvus.io/docs)
- [Hugging Face Transformers ドキュメント](https://huggingface.co/docs/transformers)
- [Sentence Transformers ドキュメント](https://www.sbert.net/)

---

**作成日**: 2026-05-17
**作成者**: 講師用ガイド（Hugging Face Transformers版）
**バージョン**: 2.0 (Hugging Face Transformers対応)

---

## 📝 講師用補足情報

### Milvusのデフォルト認証情報

`setup/docker-compose.yml`で定義されているデフォルト値：

```yaml
MILVUS_USER: root
MILVUS_PASSWORD: Milvus
```

これらの値は受講者に共有する接続情報に含まれます。

### IPアドレスの確認方法

**macOS/Linux**:
```bash
ifconfig | grep "inet " | grep -v 127.0.0.1
# または
ip addr show | grep "inet " | grep -v 127.0.0.1
```

**Windows**:
```cmd
ipconfig | findstr IPv4
```

**start-all.shの出力から**:
```bash
cd setup
./start-all.sh
# 最後に表示される "Your IP address: 192.168.1.100" を確認
```

### 埋め込みモデルについて

**使用モデル**: `paraphrase-multilingual-MiniLM-L12-v2`

**特徴**:
- 多言語対応（日本語含む）
- 384次元のベクトル
- 軽量で高速
- 無料で使用可能（Hugging Faceから自動ダウンロード）

**初回実行時の注意**:
- モデルのダウンロードに時間がかかる（約200MB）
- インターネット接続が必要
- ダウンロード後はローカルキャッシュから読み込まれる

### 受講者への事前連絡事項

ハンズオン開始前に受講者に以下を連絡：

1. **必要なソフトウェア**
   - IBM Bob IDE（最新版）
   - Webブラウザ（Chrome推奨）

2. **ネットワーク要件**
   - 講師と同じネットワークに接続
   - インターネット接続（初回のみモデルダウンロード）

3. **配布物**
   - `vector-search-builder.zip`
   - 接続情報（当日配布）

4. **所要時間**
   - 約65分（休憩含まず）
