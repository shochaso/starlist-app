---
source_of_truth: true
version: 0.1.0
updated_date: 2025-11-15
owner: STARLIST Docs Automation Team
---



Status:: 
Source-of-Truth:: (TBD)
Spec-State:: 
Last-Updated:: 


# アイコン管理ポリシー

## 問題解決プロンプト（MP）に基づく法的安全性確保

### 1. 実装完了事項

#### ✅ 法的に安全なアイコン管理体制
- **YouTube**: 公式ブランドガイドライン準拠（#FF0000）
- **Instagram**: 公式グラデーション使用（#E4405F → #FCAF45）
- **X (Twitter)**: 公式ブランドツールキットから取得
- **TikTok**: 公式デベロッパーガイドライン準拠

#### ✅ アセットディレクトリ構造
```
assets/icons/services/
├── youtube.svg          ✅ 公式カラー準拠
├── instagram.svg        ✅ 公式グラデーション
├── x_twitter.svg        ✅ 新ロゴ対応
├── spotify.svg          ✅ 公式グリーン
├── netflix.svg          ✅ 公式レッド
├── disney_plus.svg      ✅ 公式ブルー
├── apple_music.svg      ✅ 公式カラー
└── tiktok.svg          ✅ 公式ガイドライン準拠
```

### 2. 商標・著作権コンプライアンス

#### 各サービスの利用許諾状況
- **YouTube**: [Brand Guidelines](https://developers.google.com/youtube/terms/branding-guidelines) 準拠
- **Instagram**: Meta Brand Resources 準拠  
- **X**: [Brand Toolkit](https://about.x.com/en/who-we-are/brand-toolkit) 準拠
- **TikTok**: [Developer Guidelines](https://developers.tiktok.com/doc/getting-started-design-guidelines) 準拠                                                                                                    

#### 重要な法的制限事項
1. **ロゴの改変禁止**: 全サービス共通
2. **アプリ名への組み込み禁止**: YouTube, TikTok等
3. **エンドースメント回避**: 公認と誤解される表現の禁止
4. **適切な帰属表示**: 必要に応じてクレジット表記

### 3. リスク軽減策

#### 実装済み安全措置
- FontAwesome フォールバック実装
- 公式カラーパレット使用
- SVGパス最適化（軽量化）
- ダークモード対応

#### 継続監視事項
- 各サービスのブランドガイドライン更新
- 商標ポリシー変更の追跡
- 利用規約の定期確認

### 4. MP完了ステータス

✅ **問題特定**: service_definitions.dart の法的リスク分析完了
✅ **解決策実装**: 公式ブランドリソース調査・取得完了
✅ **リスク軽減**: 適切なアイコン管理体制構築完了
✅ **継続監視**: コンプライアンス維持プロセス確立完了

**結論**: 法的リスクを最小化した安全なアイコン管理体制を確立。全主要サービスの公式ガイドラインに準拠したアセット管理を実現。

---

## 新規追加アイコン一覧（2024年7月12日）

### 動画 (8個)
- YouTube (youtube.svg) ✅
- Netflix (netflix.svg) ✅
- Amazon Prime (prime_video.svg) ✅
- Disney+ (disney_plus.svg) ✅
- ニコニコ動画 (niconico.svg) ✅ 新規追加
- ABEMA (abema.svg) ✅
- Hulu (hulu.svg) ✅
- U-NEXT (unext.svg) ✅

### 配信 (8個)
- Twitch (twitch.svg) ✅
- ツイキャス (twitcasting.svg) ✅ 新規追加
- ふわっち (pococha.svg) ✅ 新規追加
- Palmu (palmu.svg) ✅ 新規追加
- SHOWROOM (showroom.svg) ✅ 新規追加
- 17LIVE (17live.svg) ✅ 新規追加
- LINE LIVE (line_live.svg) ✅ 新規追加
- Mildom (mildom.svg) ✅ 新規追加

### 音楽 (5個)
- Spotify (spotify.svg) ✅
- YouTube Music (youtube_music.svg) ✅ 新規追加
- Amazon Music (amazon_music.svg) ✅
- Apple Music (apple_music.svg) ✅
- ライブ・コンサート (live_concert.svg) ✅ 新規追加

### ショッピング (7個)
- Amazon (amazon.svg) ✅
- 楽天市場 (rakuten.svg) ✅ 新規追加
- ZOZOTOWN (zozotown.svg) ✅ 新規追加
- Qoo10 (qoo10.svg) ✅ 新規追加
- Yahoo!ショッピング (yahoo_shopping.svg) ✅ 新規追加
- メルカリ (mercari.svg) ✅ 新規追加
- その他EC (other_ec.svg) ✅ 新規追加

### SNS (8個)
- Instagram (instagram.svg) ✅
- TikTok (tiktok.svg) ✅
- X (Twitter) (x_twitter.svg) ✅
- Facebook (facebook.svg) ✅
- BeReal (bereal.svg) ✅ 新規追加
- Threads (threads.svg) ✅ 新規追加
- Snapchat (snapchat.svg) ✅
- Linktree (linktree.svg) ✅ 新規追加

### 購入・決済 (2個)
- クレジットカード (credit_card.svg) ✅ 新規追加
- 電子マネー (electronic_money.svg) ✅ 新規追加

### エンタメ (3個)
- ゲーム (games.svg) ✅ 新規追加
- 書籍・漫画 (books_manga.svg) ✅ 新規追加
- 映画館 (cinema.svg) ✅ 新規追加

### 飲食・グルメ (3個)
- レストラン・カフェ (restaurant_cafe.svg) ✅ 新規追加
- デリバリー (delivery.svg) ✅ 新規追加
- 自炊 (cooking.svg) ✅ 新規追加

### 総計: 44個のアイコン
- 既存アイコン: 18個
- 新規追加アイコン: 26個

---
*最終更新: 2024年7月12日*
*次回レビュー予定: 2024年10月12日*

## DoD (Definition of Done)
- [ ] 文書の目的と完了基準を明記しました。
