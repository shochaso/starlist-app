# CSP Report-Only 観測チェックリスト（48-72時間）

## 📋 観測期間

- **開始日時**: [PR #20 マージ日時]
- **観測期間**: 48-72時間
- **目標**: Enforce 化に向けた最小許可セットの決定

---

## ✅ チェック項目

### 1. Console 違反の確認

- [ ] ブラウザの開発者ツールで Console タブを確認
- [ ] 重大な違反がないことを確認
- [ ] 軽微な違反のみの場合、対応済みであることを確認

**確認方法**:
```bash
# ブラウザの開発者ツール（F12）を開く
# Console タブで CSP 違反がないことを確認
```

---

### 2. CSP Report エンドポイントの疎通確認

- [ ] `/_/csp-report` に 204 で到達していること
- [ ] 疎通テストが成功していること

**確認コマンド**:
```bash
curl -i -X POST \
  -H "Content-Type: application/csp-report" \
  --data '{"csp-report":{"effective-directive":"connect-src","blocked-uri":"https://example.com","document-uri":"https://starlist.app"}}' \
  "https://zjwvmoxpacbpwawlwbrd.functions.supabase.co/csp-report"

# 期待: HTTP/1.1 204 No Content
```

---

### 3. CSP Report ログの確認

- [ ] Supabase Dashboard で Edge Function のログを確認
- [ ] ブロックされたリソースを特定
- [ ] 許可が必要なリソースをリストアップ

**確認方法**:
1. Supabase Dashboard にログイン
2. Edge Functions → `csp-report` を選択
3. ログを確認し、以下の情報を抽出:
   - `blocked-uri`: ブロックされたリソースのURL
   - `effective-directive`: ブロックされたディレクティブ

---

### 4. 許可が必要なリソースの特定

CSP Report ログから以下を抽出:

#### connect-src
- [ ] ブロックされた接続先をリストアップ
- [ ] 必要な接続先のみを許可リストに追加

#### img-src
- [ ] ブロックされた画像リソースをリストアップ
- [ ] 必要な画像リソースのみを許可リストに追加

#### font-src
- [ ] ブロックされたフォントリソースをリストアップ
- [ ] 必要なフォントリソースのみを許可リストに追加

---

## 📊 観測結果の記録

### Console 違反

```
[記録欄]
- 重大な違反: [有/無]
- 軽微な違反: [有/無、対応状況]
```

### CSP Report ログ

```
[記録欄]
- blocked-uri: [URL]
- effective-directive: [ディレクティブ名]
- document-uri: [ページURL]
```

### 許可が必要なリソース

```
[記録欄]
- connect-src: [必要な接続先のリスト]
- img-src: [必要な画像リソースのリスト]
- font-src: [必要なフォントリソースのリスト]
```

---

## 🚀 次のアクション

観測期間終了後、以下の情報を共有してください:

1. **Console 違反の有無**
   - 重大な違反: [有/無]
   - 軽微な違反: [有/無、対応状況]

2. **CSP Report ログの要点**
   - `blocked-uri` と `effective-directive` を数行抜粋

3. **許可が必要なリソース**
   - `connect-src`, `img-src`, `font-src` の最小許可セット

いただき次第、CSP Enforce 化 PR の最小許可セットを即座にご提案いたします。

---

**最終更新**: CSP Report-Only 観測チェックリスト作成時点

