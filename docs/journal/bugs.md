# Bugs - バグ・懸念事項リスト

> 🐛 発見したバグや懸念点を記録  
> **優先度**: P0（緊急）、P1（高）、P2（中）、P3（低）

---

## 🔴 緊急（P0）

*現在なし*

---

## 🟠 高優先度（P1）

### 2025-10-15: SVGアセット破損問題
- **症状**: `prime_video.svg` が `<!DOCTYPE html>` になっている
- **影響**: SVGパース エラー、Whiteout（白画面）
- **原因**: ビルド時にアセットが不正なHTMLに置き換わった
- **解決策**: `flutter clean` + 再ビルドで解決
- **再発防止**: アセットの整合性チェックスクリプト作成を検討
- **ステータス**: ✅ 解決済み（2025-10-15）

---

## 🟡 中優先度（P2）

### 2025-10-15: `RenderFlex overflowed` エラー
- **症状**: UIレイアウトがオーバーフローして表示崩れ
- **場所**: `PostCard` ウィジェット
- **詳細**: 
  ```
  A RenderFlex overflowed by 38 pixels on the bottom.
  Column ← ClipRRect ← Padding ← PostCard
  ```
- **影響度**: 中（表示崩れだが動作は可能）
- **次回対応**: レスポンシブデザインの見直し
- **ステータス**: 📅 未対応

### 2025-10-15: `setState() called during build`
- **症状**: ビルド中に `setState()` が呼ばれている
- **影響**: パフォーマンス低下、潜在的なバグ
- **場所**: 複数箇所で発生
- **次回対応**: ビルドフック の適切な使用
- **ステータス**: 📅 未対応

---

## 🟢 低優先度（P3）

### 2025-10-15: Notoフォントの文字表示問題
- **症状**: 一部の文字がNotoフォントで表示されない
- **メッセージ**: `Could not find a set of Noto fonts to display all missing characters`
- **影響度**: 低（代替フォントで表示される）
- **対応**: 必要に応じてフォントアセット追加
- **ステータス**: 📅 未対応

---

## ⚠️ 懸念事項

### データインポート精度
- **懸念**: Netflix/Amazon等のデータ取り込み精度が不明
- **リスク**: ユーザーデータが不正確になる可能性
- **対策案**: 
  - インポート診断機能を拡充
  - ユーザーフィードバック収集
  - 精度検証テスト実施

### パフォーマンス
- **懸念**: 114画面、大量のプロバイダー・サービスでパフォーマンス低下の可能性
- **対策案**:
  - 遅延ロード実装
  - キャッシュ戦略最適化
  - パフォーマンステスト実施

### セキュリティ
- **懸念**: Supabase RLSポリシーの完全性
- **対策**: セキュリティ監査実施予定

---

## 📋 バグ報告テンプレート

```markdown
### YYYY-MM-DD: バグタイトル
- **症状**: 何が起きるか
- **再現手順**: 
  1. 〇〇する
  2. △△を開く
  3. エラー発生
- **期待される動作**: 本来どうあるべきか
- **影響度**: P0/P1/P2/P3
- **環境**: Flutter 3.35.5, Chrome, iOS等
- **ステータス**: 📅 未対応 / 🔄 対応中 / ✅ 解決済み
```

---

## 🔍 デバッグTips

### よくあるFlutterエラー
- `setState() during build` → `WidgetsBinding.instance.addPostFrameCallback` を使用
- `RenderFlex overflowed` → `Flexible`, `Expanded`, `ListView` で対応
- `Invalid SVG data` → アセットファイルの整合性確認

### ログ確認
```bash
# Flutter Web
flutter run -d chrome --verbose

# クリーンビルド
flutter clean && flutter pub get && flutter run
```

---

## 📊 バグ統計

### 解決済み
- ✅ SVGアセット破損（2025-10-15）

### 未解決
- 📅 RenderFlex overflow（P2）
- 📅 setState during build（P2）
- 📅 Notoフォント問題（P3）

### 懸念事項
- ⚠️ データインポート精度
- ⚠️ パフォーマンス
- ⚠️ セキュリティ

---

最終更新: 2025-10-15



