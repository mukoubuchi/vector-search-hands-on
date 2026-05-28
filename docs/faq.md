# よくある質問（FAQ）

## インストール・環境構築

### Q1. 仮想環境を使わずにインストールしてしまいました

**A1.** グローバル環境にインストールした場合、以下の手順でクリーンアップできます：

```bash
# インストールしたパッケージをアンインストール
pip uninstall -y pymilvus sentence-transformers transformers torch fastapi uvicorn pandas langchain

# または、requirements.txtから一括アンインストール
pip uninstall -r requirements.txt -y
```

その後、必ず仮想環境を作成してから再インストールしてください：

=== ":fontawesome-brands-apple: Mac"
    ```bash
    cd ~/Desktop/vector-search-builder/setup/participant
    python3 -m venv venv
    source venv/bin/activate
    pip install -r requirements.txt
    ```

=== ":fontawesome-brands-windows: Windows"
    ```bash
    cd %USERPROFILE%\Desktop\vector-search-builder\setup\participant
    python -m venv venv
    venv\Scripts\activate
    pip install -r requirements.txt
    ```

!!! danger "重要"
    仮想環境を使わないと、他のPythonプロジェクトに影響を与える可能性があります。必ず仮想環境を使用してください。

### Q2. パッケージのインストールでエラーが発生します

**A1.** 以下の順序で対処してください：

1. **パッケージの再インストール**
   ```bash
   cd setup/participant
   pip uninstall -y pymilvus numpy sentence-transformers transformers huggingface-hub
   pip cache purge
   pip install -r requirements.txt
   ```

2. **それでも解決しない場合**
   ```bash
   # 仮想環境を作り直す
   deactivate
   rm -rf venv
   python3 -m venv venv
   source venv/bin/activate
   pip install -r requirements.txt
   ```

### Q3. `sentence-transformers`と`huggingface_hub`の互換性エラーが出ます

**A3.** requirements.txtで指定されているバージョンを使用してください：

```bash
# 正しいバージョンの組み合わせ
sentence-transformers==3.0.1
transformers==4.41.2
huggingface-hub==0.23.4
tokenizers==0.19.1
```

これらのバージョンは互換性がテスト済みです。個別にアップグレードすると互換性の問題が発生する可能性があります。

**エラー例と対処法：**

```
ImportError: cannot import name 'HfFolder' from 'huggingface_hub'
```

このエラーが出た場合は、上記のバージョンに固定してください。

### Q4. Milvusに接続できません

**A4.** 以下を確認してください：

1. **接続情報の確認**
   - `.env`ファイルの`MILVUS_HOST`、`MILVUS_PORT`が正しいか
   - 講師から提供された接続情報と一致しているか

2. **接続テスト**
   ```bash
   python test_connection.py
   ```

3. **ネットワークの確認**
   - ファイアウォールやプロキシの設定
   - VPN接続が必要な場合は接続されているか

## Vector Search

### Q5. 検索結果が期待と異なります

**A5.** 以下を確認してください：

1. **埋め込みモデルの確認**
   - 日本語データには日本語対応モデルを使用
   - 英語データには英語モデルを使用

2. **検索パラメータの調整**
   ```python
   # top_kを増やして、より多くの結果を取得
   results = collection.search(
       data=[query_vector],
       anns_field="embedding",
       param={"metric_type": "COSINE", "params": {"ef": 100}},
       limit=10,  # top_kを増やす
       output_fields=["text", "source"]
   )
   ```

3. **データの確認**
   - サンプルデータが正しく投入されているか
   - コレクションにデータが存在するか

### Q6. 検索が遅いです

**A6.** 以下の最適化を試してください：

1. **インデックスパラメータの調整**
   ```python
   index_params = {
       "metric_type": "COSINE",
       "index_type": "HNSW",
       "params": {
           "M": 16,  # 小さくすると速くなるが精度が下がる
           "efConstruction": 256
       }
   }
   ```

2. **検索パラメータの調整**
   ```python
   search_params = {
       "metric_type": "COSINE",
       "params": {"ef": 50}  # 小さくすると速くなるが精度が下がる
   }
   ```

## アプリケーション

### Q7. FastAPIアプリケーションが起動しません

**A7.** 以下を確認してください：

1. **ポートの確認**
   ```bash
   # ポート8000が使用中か確認
   lsof -i :8000
   
   # 使用中の場合は別のポートで起動
   uvicorn app:app --host 0.0.0.0 --port 8001
   ```

2. **依存パッケージの確認**
   ```bash
   pip list | grep -E "fastapi|uvicorn|pydantic"
   ```

3. **エラーログの確認**
   - ターミナルに表示されるエラーメッセージを確認
   - `.env`ファイルの設定を確認

### Q8. `/docs`でSwagger UIが表示されません

**A8.** 以下を確認してください：

1. **URLの確認**
   - `http://localhost:8000/docs`にアクセス
   - `http://127.0.0.1:8000/docs`も試す

2. **アプリケーションの起動確認**
   ```bash
   curl http://localhost:8000/health
   ```

## データ投入

### Q9. サンプルデータの投入に失敗します

**A9.** 以下を確認してください：

1. **Milvus接続の確認**
   ```bash
   python test_connection.py
   ```

2. **コレクションの確認**
   - 既存のコレクションが存在する場合は削除
   ```python
   from pymilvus import utility, connections
   connections.connect(...)
   utility.drop_collection("products")
   ```

3. **スクリプトの再実行**
   ```bash
   python insert_sample_data.py
   ```

### Q10. 埋め込みベクトルの生成に時間がかかります

**A10.** 初回実行時は以下の理由で時間がかかります：

1. **モデルのダウンロード**
   - Hugging Faceからモデルをダウンロード
   - 数百MB〜数GBのサイズ
   - 2回目以降はキャッシュが使用される

2. **対処方法**
   - 初回は時間がかかることを想定
   - ネットワーク環境の良い場所で実行
   - モデルのダウンロード進捗を確認

## その他

### Q11. IBM Bobに質問しても回答が得られません

**A11.** 以下を確認してください：

1. **質問の明確化**
   - 具体的なエラーメッセージを含める
   - 実行したコマンドを記載
   - 期待する動作を説明

2. **コンテキストの提供**
   - どのステップで問題が発生したか
   - 環境情報（OS、Pythonバージョンなど）

### Q12. ハンズオン資料はどこで見られますか？

**A12.** 以下のURLでアクセスできます：

- ローカル環境: `http://localhost:8080`
- 講師が提供するURL（クラウド環境の場合）

### Q13. 仮想環境を削除してやり直したいです

**A13.** 以下の手順で実行してください：

```bash
# 仮想環境を無効化
deactivate

# 仮想環境を削除
rm -rf venv

# 新しい仮想環境を作成
python3 -m venv venv

# 仮想環境を有効化
source venv/bin/activate

# パッケージをインストール
pip install -r requirements.txt
```

## トラブルシューティングのヒント

### パッケージの互換性問題を防ぐには

1. **requirements.txtを使用する**
   - 個別に`pip install`しない
   - `pip install -r requirements.txt`を使用

2. **バージョンを固定する**
   - `==`でバージョンを指定
   - 範囲指定（`>=`, `<`）は最小限に

3. **仮想環境を使用する**
   - システムのPythonと分離
   - プロジェクトごとに独立した環境

### エラーメッセージの読み方

1. **ImportError**
   - パッケージがインストールされていない
   - バージョンが古い/新しい

2. **ConnectionError**
   - ネットワークの問題
   - 接続情報の誤り

3. **AttributeError**
   - APIの変更
   - バージョンの不一致

## さらにサポートが必要な場合

- 講師に質問する
- IBM Bobに詳細なエラーログを提供して相談
- ドキュメントの該当セクションを再確認