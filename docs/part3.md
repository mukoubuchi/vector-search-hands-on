# Part 3: 動作確認とレビュー

このパートでは、Part 2 で追加した 3 つの機能が正しく動作するか確認し、IBM Bob のコードレビュー機能を使います。

## このパートのゴール

- 追加した機能をテストする
- IBM Bob のコードレビュー機能を使う
- コードの品質を確認する

## ステップ 1: 追加した機能をテストする

!!! example "実践: 追加した機能をテストしよう"
    Part 2 で追加した 3 つの機能をテストします。

### テスト 1: 商品画像の表示

#### 手順

1. Swagger UI を開く（**`http://localhost:8002/docs`**）
2. **`/search`** エンドポイントを開く
3. 「Try it out」をクリック
4. 以下を入力:

   ```json
   {
     "query": "赤いスニーカー"
   }
   ```

5. 「Execute」をクリック
6. 結果を確認:

   ```json
   {
     "results": [
       {
         "product_name": "赤いランニングシューズ",
         "image_url": "https://example.com/images/red-shoes.jpg",
         "similarity_score": 0.92,
         "price": 8900
       }
     ]
   }
   ```

#### 確認ポイント

- **`image_url`** フィールドが存在する
- URL が正しい形式（**`https://`** で始まる）
- すべての検索結果に画像 URL が含まれる

### テスト 2: 価格フィルター

#### 手順

1. Swagger UI で **`/search`** を開く
2. 「Try it out」をクリック
3. 以下を入力:

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

4. 「Execute」をクリック
5. 結果を確認: すべての商品の価格が 5000〜10000 円の範囲内

#### 確認ポイント

- 指定した価格範囲の商品のみ表示される
- 範囲外の商品は表示されない

#### 色々な価格帯を試す

```json
// 高価格帯
{
  "query": "カメラ",
  "filters": {
    "price_range": {
      "min": 50000,
      "max": 100000
    }
  }
}

// 低価格帯
{
  "query": "カメラ",
  "filters": {
    "price_range": {
      "min": 0,
      "max": 20000
    }
  }
}
```

### テスト 3: レコメンド理由の表示

#### 手順

1. Swagger UI で **`/search`** を開く
2. 「Try it out」をクリック
3. 以下を入力:

   ```json
   {
     "query": "初心者向けのカメラ"
   }
   ```

4. 「Execute」をクリック
5. 結果を確認:

   ```json
   {
     "results": [
       {
         "product_name": "入門用デジタルカメラ",
         "similarity_score": 0.95,
         "recommendation_reason": "検索内容と非常に高い類似性があります（95%）"
       }
     ]
   }
   ```

#### 確認ポイント

- **`recommendation_reason`** フィールドが存在する
- 理由が分かりやすい日本語で表示される
- 類似度スコアに基づいた説明になっている

### テスト完了チェック

- [ ] 商品画像が表示される
- [ ] 価格フィルターが動作する
- [ ] レコメンド理由が表示される
- [ ] すべての機能が正しく動作する

## ステップ 2: IBM Bob のコードレビュー機能を使う

!!! example "実践: コードレビューを依頼しよう"
    IBM Bob にコードの品質をチェックしてもらいます。

### コードレビューとは？

**コードレビュー** = コードの品質を確認すること

**目的**:

- バグを見つける
- 改善点を発見する
- ベストプラクティスを学ぶ

### ステップ 1: レビューを依頼

チャット入力欄に以下を入力して Enter:

```text
/review app.py
```

!!! tip "コマンドの使い方"
    `/review` コマンドを使用すると、IBM Bob がコードレビューを実行します。

### ステップ 2: IBM Bob のレビュー結果を確認

IBM Bob が以下のような分析をします:

```
コードレビュー結果:

良い点:
✓ コードが読みやすい
✓ 適切なエラーハンドリング
✓ 関数が適切に分割されている

改善点:
⚠ ログ出力を追加すると良い
⚠ テストコードがあると良い
⚠ ドキュメントコメントを追加すると良い

セキュリティ:
✓ 特に問題なし

パフォーマンス:
✓ 効率的な実装
```

### ステップ 4: 改善点を確認

IBM Bob が指摘した改善点を確認します。

**よくある改善点**:

- ログ出力の追加
- エラーハンドリングの強化
- ドキュメントコメントの追加
- テストコードの作成

### ステップ 5: 改善を依頼（オプション）

改善したい点があれば、IBM Bob に依頼します:

```text
ログ出力を追加して
```

## Part 3 完了チェック

- [ ] Part 2 で追加した 3 つの機能をすべてテストした
- [ ] `/review` コマンドを使って、IBM Bob にコードレビューを依頼した
- [ ] レビュー結果を確認し、改善点を把握した。

## FAQ

??? question "Q1: テストが失敗する"

    対処法:
    
    1. アプリケーションが起動しているか確認
    2. 変更が保存されているか確認
    3. アプリケーションを再起動
    
        **方法 1: IBM Bob に依頼（推奨）**
        
        IBM Bob に「デモアプリケーションを再起動して」と依頼
        
        **方法 2: 手動で再起動**
        
        1. ターミナルで ++ctrl+c++ （停止）
        2. **`python app.py`** を実行（[:material-play-circle: 起動方法](../part1/#app-restart)）

??? question "Q2: レビュー結果が表示されない"

    対処法:
    
    1. `/review` コマンドを正しく入力したか確認
    2. ファイル名が正しいか確認
    3. IBM Bob を再起動

## ステップ 3: 環境のクリーンアップ

!!! example "実践: インストールしたパッケージをクリーンアップしよう"
    ハンズオンで使用した Python パッケージをアンインストールして、環境をクリーンアップします。

### クリーンアップの目的

このハンズオンでは、`pip` を使用して複数のパッケージをインストールしました。ハンズオン終了後、これらのパッケージが不要な場合は、環境をクリーンに保つためにアンインストールすることをお勧めします。

### IBM Bob にクリーンアップを依頼

IBM Bob のチャット入力欄に以下を入力:

```text
setup/participant/requirements.txt に記載されているパッケージをすべてアンインストールして
```

IBM Bob が以下のコマンドを実行します:

=== ":fontawesome-brands-apple: Mac"
    ```bash
    pip3 uninstall -y -r setup/participant/requirements.txt
    ```

=== ":fontawesome-brands-windows: Windows"
    ```bash
    pip uninstall -y -r setup/participant/requirements.txt
    ```

!!! info "アンインストールされるパッケージ"
    以下のパッケージがアンインストールされます:
    
    - pymilvus
    - sentence-transformers
    - torch
    - python-dotenv
    - pandas
    - scikit-learn
    - langchain
    - langchain-community
    - tqdm
    - その他の依存パッケージ

??? tip "手動でアンインストールする場合"
    IBM Bob を使わずに手動でアンインストールする場合は、ターミナルで以下を実行:
    
    === ":fontawesome-brands-apple: Mac"
        ```bash
        cd ~/Desktop/vector-search-builder
        pip3 uninstall -y -r setup/participant/requirements.txt
        ```
    
    === ":fontawesome-brands-windows: Windows"
        ```bash
        cd %USERPROFILE%\Desktop\vector-search-builder
        pip uninstall -y -r setup\participant\requirements.txt
        ```

??? question "Q: パッケージを残しておきたい場合は？"
    
    このハンズオンで学んだ技術を今後も使用する予定がある場合は、パッケージをアンインストールする必要はありません。そのまま残しておいて、次回のプロジェクトで再利用できます。

### クリーンアップ完了チェック

- [ ] IBM Bob にパッケージのアンインストールを依頼した
- [ ] アンインストールが正常に完了した
- [ ] 環境がクリーンになった

## 次のステップ

Part 3 が完了したら、[まとめ](summary.md)に進みましょう！
まとめでは、このハンズオンで学んだことを振り返り、業務での活用方法を確認します。
