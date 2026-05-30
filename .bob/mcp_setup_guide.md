# Draw.io MCP設定ガイド

このガイドでは、BobでDraw.io MCPサーバーを使用する方法を説明します。

## 概要

Draw.io MCPサーバーを使用すると、Bobから直接図表を作成・編集できます。以下の機能が利用可能です：

- **XML形式での図表作成**: draw.io形式のXMLを生成して図表を作成
- **Mermaid形式での図表作成**: Mermaid記法で図表を作成
- **CSV形式での図表作成**: CSVデータから組織図やフローチャートを作成
- **図表の検索**: draw.ioの図形ライブラリから特定の図形を検索

## 設定方法

### 1. 前提条件

- Node.js（v18以上）がインストールされていること
- npmまたはnpxが使用可能であること

### 2. 設定ファイル

`.bob/mcp_settings.json`ファイルが既に作成されています：

```json
{
  "mcpServers": {
    "drawio": {
      "command": "npx",
      "args": [
        "-y",
        "@drawio/mcp"
      ],
      "disabled": false,
      "alwaysAllow": []
    }
  }
}
```

### 3. 設定の有効化

1. **Bobを再起動**: 設定を反映させるためにBobを再起動します
2. **MCP接続の確認**: Bobが起動したら、MCPサーバーが正常に接続されているか確認します

## 使用方法

### 基本的な使い方

Bobに以下のようなリクエストをすることで、Draw.io MCPサーバーの機能を使用できます：

#### 1. フローチャートの作成

```
「ユーザー登録プロセスのフローチャートを作成して」
```

Bobは自動的にDraw.io MCPサーバーを使用して図表を生成します。

#### 2. アーキテクチャ図の作成

```
「3層アーキテクチャの図を作成して」
```

#### 3. Mermaid記法での作成

```
「Mermaid形式でシーケンス図を作成して」
```

### 利用可能なツール

Draw.io MCPサーバーは以下のツールを提供します：

1. **open_drawio_xml**: draw.io XML形式で図表を作成
2. **open_drawio_mermaid**: Mermaid記法で図表を作成
3. **open_drawio_csv**: CSV形式で図表を作成
4. **search_shapes**: draw.ioの図形ライブラリを検索

## トラブルシューティング

### MCPサーバーが接続されない場合

1. **Node.jsのバージョン確認**:
   ```bash
   node --version
   ```
   v18以上であることを確認

2. **npxの動作確認**:
   ```bash
   npx -y @drawio/mcp --version
   ```

3. **Bobのログ確認**: Bobのログでエラーメッセージを確認

### 図表が表示されない場合

- ブラウザのポップアップブロッカーを無効化
- Bobの設定で外部リンクの許可を確認

## 高度な設定

### 特定のツールを常に許可する

頻繁に使用するツールを`alwaysAllow`リストに追加できます：

```json
{
  "mcpServers": {
    "drawio": {
      "command": "npx",
      "args": ["-y", "@drawio/mcp"],
      "disabled": false,
      "alwaysAllow": [
        "open_drawio_xml",
        "open_drawio_mermaid"
      ]
    }
  }
}
```

### MCPサーバーの無効化

一時的に無効化する場合は`disabled`を`true`に設定：

```json
{
  "mcpServers": {
    "drawio": {
      "command": "npx",
      "args": ["-y", "@drawio/mcp"],
      "disabled": true,
      "alwaysAllow": []
    }
  }
}
```

## 参考リンク

- [Draw.io MCP公式ドキュメント](https://github.com/jgraph/drawio-mcp)
- [Model Context Protocol (MCP)](https://modelcontextprotocol.io/)
- [Draw.io公式サイト](https://www.drawio.com/)

## サポート

問題が発生した場合は、以下を確認してください：

1. `.bob/mcp_settings.json`の設定が正しいか
2. Node.jsとnpxが正常に動作しているか
3. Bobのログにエラーメッセージがないか

---

**作成日**: 2026年5月29日
**最終更新**: 2026年5月29日