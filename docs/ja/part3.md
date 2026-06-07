# Part 3: 動作確認とレビュー

このパートでは、Part 2 で追加した機能が正しく動作するか総合確認し、IBM Bob にコードレビューを依頼します。

## このパートのゴール

- 追加した機能をテストする
- IBM Bob にコードレビューを依頼する
- コードの品質を確認する

## ステップ 1: 追加した機能をテストする

!!! example "実践: 追加した機能をテストしよう"
    
    Part 2 で追加した機能を、重複しない観点でテストします。

!!! note "Part 2 でテスト済みの場合"
    
    Part 2 の作業中に、IBM Bob が自動的にテストスクリプトを作成し、実行ボタンを押すだけでテストまで完了している場合があります。その場合も、ここでは最終確認として、追加した機能が期待どおり動作していることをダブルチェックしてください。

!!! note "テスト観点"
    
    Swagger UI のレスポンス例では、1 回検索すれば追加されたレスポンス項目をまとめて確認できます。そのため、ここでは **レスポンス項目の確認** と **価格フィルターの挙動確認** に分けてテストします。

### テスト 1: レスポンス項目の総合確認

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
          "product_name": "赤いスポーツシューズ",
          "image_url": "https://example.com/images/red-shoes.jpg",
          "similarity_score": 0.5474,
          "price": 7500,
          "category": "スニーカー",
          "description": "普段使いにもスポーツにも使える万能シューズ。クッション性に優れています。",
          "recommendation_reason": "検索内容と関連しています（類似度: 0.5474）"
        }
      ]
    }
    ```

#### 確認ポイント

- **`image_url`** フィールドが存在する
- URL が正しい形式（**`https://`** で始まる）
- **`recommendation_reason`** フィールドが存在する
- レコメンド理由が分かりやすい日本語で表示される
- 既存の **`product_name`**、**`price`**、**`category`**、**`description`** も表示される

### テスト 2: 価格フィルターの挙動確認

#### 手順

1. Swagger UI で **`/search`** を開く
2. 「Try it out」をクリック
3. 以下を入力:

    ```json
    {
      "query": "スニーカー",
      "min_price": 5000,
      "max_price": 10000
    }
    ```

4. 「Execute」をクリック
5. 結果を確認: すべての商品の価格が 5000〜10000 円の範囲内

#### 確認ポイント

- 指定した価格範囲の商品のみ表示される
- 範囲外の商品は表示されない
- **`image_url`** と **`recommendation_reason`** も引き続き表示される

#### 余裕があれば: 色々な価格帯を試す

```json
// 高価格帯
{
  "query": "カメラ",
  "min_price": 50000,
  "max_price": 100000
}

// 低価格帯
{
  "query": "カメラ",
  "min_price": 0,
  "max_price": 20000
}
```

### テスト完了チェック

- [ ] 1 回の検索結果で **`image_url`** と **`recommendation_reason`** を確認した
- [ ] 価格フィルターで範囲外の商品が除外されることを確認した
- [ ] 追加した機能が組み合わせても正しく動作することを確認した

## ステップ 2: IBM Bob にコードレビューを依頼する

!!! example "実践: コードレビューを依頼しよう"
    
    IBM Bob にコードの品質をチェックしてもらいます。

### コードレビューとは？

**コードレビュー** = コードの品質を確認すること

**目的**:

- バグを見つける
- 改善点を発見する
- ベストプラクティスを学ぶ

### レビューを依頼

!!! note "`/review` コマンドについて"
    
    IBM Bob には `/review` コマンドがあります。しかし、IBM Bob 1.0.3 では、`/review <file>` のようにファイル名を渡して対象ファイルを指定する使い方には対応していません。ファイル単位でレビューしたい場合は、以下のように自然文で「app.py をレビューして」と依頼してください。

チャット入力欄に以下を入力して Enter:

```text
app.py をレビューして
```

!!! tip "IBM Bob のコードレビュー"
    
    レビューを依頼すると、IBM Bob がコードレビューを実行します。

まずは API の入口である `app.py` からレビューします。機能 1 で商品データや Milvus のコレクション定義を変更した場合は、関連する共通ファイルもレビューします:

```text
schema.py をレビューして
insert_sample_data.py をレビューして
```

### IBM Bob のレビュー結果を確認

IBM Bob が以下のような分析をします:

#### app.py コードレビュー

##### ✅ 良い点

###### 1. **構造とアーキテクチャ**

- FastAPI を使用した明確な RESTful API 設計
- Pydantic モデルによる型安全なリクエスト / レスポンス
- 適切な関心の分離（`common.py`、`schema.py` からのインポート）

###### 2. **多言語対応**

- `msg()` 関数による日本語 / 英語の切り替え
- すべてのユーザー向けメッセージが多言語対応

###### 3. **エラーハンドリング**

- 適切な HTTP ステータスコード（503, 500）
- try-except ブロックによる例外処理
- ユーザーフレンドリーなエラーメッセージ

###### 4. **機能の充実**

- ✅ ベクトル検索
- ✅ 価格フィルタ（`min_price`, `max_price`）
- ✅ 推奨理由の自動生成
- ✅ ヘルスチェックエンドポイント

###### 5. **CORS 設定**

- フロントエンドからのアクセスを許可

##### ⚠️ 改善提案

###### 1. **非推奨の `on_event` の使用（行 137, 171）**

```python
# 現在（非推奨）
@app.on_event("startup")
async def startup_event():
    ...

# 推奨: lifespan イベントハンドラーを使用
from contextlib import asynccontextmanager

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup
    global embedding_model, collection
    embedding_model = load_embedding_model()
    connect_to_milvus()
    collection = load_collection()
    yield
    # Shutdown
    connections.disconnect("default")

app = FastAPI(lifespan=lifespan, ...)
```

###### 2. **グローバル変数の使用（行 38-39）**

```python
# 現在
embedding_model: Optional[SentenceTransformer] = None
collection: Optional[Collection] = None

# 推奨: 依存性注入またはアプリケーション状態を使用
app.state.embedding_model = None
app.state.collection = None
```

###### 3. **バリデーションの追加**

```python
class SearchRequest(BaseModel):
    query: str
    top_k: int = 5
    min_price: Optional[int] = None
    max_price: Optional[int] = None
    
    # 追加推奨
    @validator('top_k')
    def validate_top_k(cls, v):
        if v < 1 or v > 100:
            raise ValueError('top_k must be between 1 and 100')
        return v
    
    @validator('max_price')
    def validate_price_range(cls, v, values):
        if v is not None and 'min_price' in values and values['min_price'] is not None:
            if v < values['min_price']:
                raise ValueError('max_price must be greater than min_price')
        return v
```

###### 4. **ロギングの改善**

```python
import logging

logger = logging.getLogger(__name__)

# print() の代わりに logger を使用
logger.info(f"Connecting to Milvus: {host}:{port}")
logger.error(f"Failed to connect: {e}")
```

###### 5. **セキュリティ強化**

```python
# CORS 設定を本番環境用に制限
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000"],  # 特定のオリジンのみ
    allow_credentials=True,
    allow_methods=["GET", "POST"],  # 必要なメソッドのみ
    allow_headers=["*"],
)
```

###### 6. **パフォーマンス最適化**

```python
# キャッシュの追加（頻繁に検索されるクエリ用）
from functools import lru_cache

@lru_cache(maxsize=100)
def get_query_embedding(query: str):
    return embedding_model.encode([query], normalize_embeddings=True)[0].tolist()
```

###### 7. **テストの追加**

```python
# tests/test_app.py
from fastapi.testclient import TestClient

def test_search_endpoint():
    client = TestClient(app)
    response = client.post("/search", json={"query": "赤いスニーカー"})
    assert response.status_code == 200
    assert "results" in response.json()
```

##### 📊 コード品質スコア

| 項目 | スコア | コメント |
|------|--------|----------|
| 可読性 | 9/10 | 明確な命名、適切なコメント |
| 保守性 | 8/10 | モジュール化されているが、グローバル変数の使用 |
| 拡張性 | 9/10 | 新機能の追加が容易 |
| エラー処理 | 8/10 | 基本的な処理は実装済み |
| セキュリティ | 6/10 | CORS 設定が緩い |
| パフォーマンス | 7/10 | キャッシュなし |

**総合評価: 8.0/10** - 本番環境への移行前に上記の改善を推奨

##### 🎯 優先度の高い改善

1. **高**: `on_event` を `lifespan` に移行（FastAPI 0.93.0 以降で非推奨）
2. **中**: バリデーションの追加（不正な入力の防止）
3. **中**: ロギングの実装（デバッグとモニタリング）
4. **低**: CORS 設定の厳格化（本番環境用）

現在のコードは機能的には完全に動作しており、デモアプリケーションとしては優れています！

### 改善点を確認

IBM Bob が指摘した改善点を確認します。

**よくある改善点**:

- ログ出力の追加
- エラーハンドリングの強化
- ドキュメントコメントの追加
- テストコードの作成

??? note "改善提案の扱い"
    IBM Bob のレビュー結果には、本番環境を想定した改善提案も含まれます。グローバル変数、CORS 設定、キャッシュ、テスト追加などは、本番化する際に検討する項目です。

### 改善を依頼（オプション）

改善したい点があれば、IBM Bob に依頼します:

- ログ出力を追加する場合:

```text
app.py の検索処理にログ出力を追加して
```

- バリデーションを追加する場合:

```text
app.py の SearchRequest に top_k と価格範囲のバリデーションを追加して
```

- CORS 設定を見直す場合:

```text
app.py の CORS 設定を本番環境向けに制限して
```

- テストコードを追加する場合:

```text
app.py の search エンドポイントのテストコードを追加して
```

## Part 3 完了チェック

- [ ] Part 2 で追加した機能を、重複しない観点でテストした
- [ ] IBM Bob にコードレビューを依頼した
- [ ] 商品データの定義を変更した場合は、`schema.py` やデータ投入ファイルもレビューした
- [ ] レビュー結果を確認し、改善点を把握した

## FAQ

??? question "Q1: テストが失敗する"

    対処法:
    
    1. アプリケーションが起動しているか確認
    2. 変更が保存されているか確認
    3. アプリケーションを手動で再起動
    
        1. アプリケーションを起動しているターミナルで ++ctrl+c++ （停止）
        2. **`python app.py`** を実行（[:material-play-circle: 起動方法](part1.md#app-restart)）

??? question "Q2: レビュー結果が表示されない"

    対処法:
    
    1. レビュー依頼を正しく入力したか確認
    2. ファイル名が正しいか確認
    3. IBM Bob を再起動

## ステップ 3: 環境のクリーンアップ

!!! example "実践: 仮想環境をクリーンアップしよう"
    
    ハンズオンで使用した仮想環境を終了し、ハンズオン用フォルダを削除します。

### クリーンアップの目的

このハンズオンでは、デスクトップの `vector-search-builder-ja` フォルダ内で作業しました。作業が終わったら、まず仮想環境を無効化します。その後、デスクトップの `vector-search-builder-ja` フォルダを削除すると、ハンズオン用のファイル、`venv`、設定ファイルをまとめて片付けられます。

### IBM Bob にクリーンアップを依頼

IBM Bob のチャット入力欄に以下を入力:

```text
Python の仮想環境を無効化して、デスクトップの vector-search-builder-ja フォルダを削除して。
```

!!! info "クリーンアップの考え方"
    
    `deactivate` は、現在のターミナルで有効化している仮想環境を終了するだけです。インストール済みパッケージは `venv` フォルダ内に残ります。`deactivate` はフォルダ削除に含まれる操作ではなく、削除前に現在のターミナルを通常状態に戻す操作です。`deactivate` した上で、デスクトップに作成した `vector-search-builder-ja` フォルダを削除します。プロジェクト内の `venv` や設定ファイルもまとめて削除されます。

??? tip "手動でクリーンアップする場合"
    ターミナルで以下を実行:
    
    === ":fontawesome-brands-apple: Mac"
        ```bash
        deactivate
        cd ~/Desktop
        rm -rf vector-search-builder-ja
        ```
    
    === ":fontawesome-brands-windows: Windows"
        ```bash
        deactivate
        cd %USERPROFILE%\Desktop
        rmdir /s /q vector-search-builder-ja
        ```

??? info "venv だけを削除する場合"
    通常は `vector-search-builder-ja` フォルダごと削除すれば十分です。プロジェクトのファイルを残して仮想環境だけ削除したい場合は、以下を実行します。

    === ":fontawesome-brands-apple: Mac"
        ```bash
        deactivate
        cd ~/Desktop/vector-search-builder-ja/setup/participant
        rm -rf venv
        ```
    
    === ":fontawesome-brands-windows: Windows"
        ```bash
        deactivate
        cd %USERPROFILE%\Desktop\vector-search-builder-ja\setup\participant
        rmdir /s /q venv
        ```

??? question "Q: venv を残しておきたい場合は？"
    
    このハンズオンで学んだ技術を今後も使用する予定がある場合は、`venv` フォルダを削除する必要はありません。`deactivate` だけ実行して、次回のプロジェクトで再利用できます。

### クリーンアップ完了チェック

- [ ] 仮想環境を無効化した
- [ ] `vector-search-builder-ja` フォルダを削除した

## 次のステップ

Part 3 が完了したら、[まとめ](summary.md) に進みましょう！
