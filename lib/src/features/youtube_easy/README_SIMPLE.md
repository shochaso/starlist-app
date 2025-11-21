---
source_of_truth: true
version: 0.1.0
updated_date: 2025-11-15
owner: STARLIST Docs Automation Team
---



# 🎬 中学生でもできる！YouTube API連携

## 📚 これは何？

StarlistアプリでYouTuberの動画情報を取得できる**超簡単版**です！  
中学生でも30分で設定できるように作りました。

## 🚀 できること

- ✅ YouTuberのチャンネル情報表示
- ✅ 最新動画リスト表示  
- ✅ 動画のサムネイル・タイトル・再生回数表示
- ✅ 動画をタップしてYouTubeアプリで再生
- ✅ 人気YouTuberの情報をワンクリック取得

## 📋 必要なもの

1. **Googleアカウント** (普通のGmailアカウントでOK)
2. **YouTube APIキー** (無料で取得できます)
3. **インターネット接続**

## 🛠️ 設定手順（5分でできる！）

### ステップ1: Google Cloud Consoleでプロジェクト作成

1. [Google Cloud Console](https://console.cloud.google.com/) を開く
2. 「新しいプロジェクト」をクリック
3. プロジェクト名に「YouTubeTest」と入力
4. 「作成」をクリック

### ステップ2: YouTube API を有効にする

1. 左メニューから「APIとサービス」→「ライブラリ」をクリック
2. 検索ボックスに「YouTube Data API」と入力
3. 「YouTube Data API v3」をクリック
4. 「有効にする」をクリック

### ステップ3: APIキーを作成

1. 左メニューから「APIとサービス」→「認証情報」をクリック
2. 上の「+ 認証情報を作成」→「APIキー」をクリック
3. APIキーが表示されるのでコピー（重要！）
4. 「制限」をクリックして制限を設定（推奨）
   - アプリケーションの制限：なし
   - API の制限：「キーを制限」→「YouTube Data API v3」を選択

### ステップ4: Flutterアプリに設定

1. `lib/src/features/youtube_easy/simple_youtube_setup.dart` を開く
2. `myApiKey` の `'YOUR_API_KEY_HERE'` を削除
3. コピーしたAPIキーを貼り付け

```dart
// 変更前
static const String myApiKey = 'YOUR_API_KEY_HERE';

// 変更後（例）
static const String myApiKey = 'AIzaSyBOti4mM-6x9WDnZIjIeyEU21OpBX4Om8z';
```

### ステップ5: アプリを実行

1. Flutter アプリを再起動
2. YouTube連携画面を開く
3. 「ヒカキン」ボタンなどをクリックして テスト！

## 📱 使い方

### 基本的な使い方

```dart
import 'package:starlist/src/features/youtube_easy/simple_youtube_widget.dart';

// 画面に表示
SimpleYouTubeWidget()
```

### コードで動画を取得する方法

```dart
import 'package:starlist/src/features/youtube_easy/simple_youtube_service.dart';
import 'package:starlist/src/features/youtube_easy/simple_youtube_setup.dart';

// APIキーを設定
SimpleYouTubeService.apiKey = SimpleYouTubeSetup.myApiKey;

// チャンネル情報を取得
final channel = await SimpleYouTubeService.getChannel('チャンネルID');

// 動画リストを取得  
final videos = await SimpleYouTubeService.getChannelVideos('チャンネルID');

// 動画を検索
final searchResults = await SimpleYouTubeService.searchVideos('ヒカキン');
```

## 🔧 カスタマイズ方法

### 好きなYouTuberを追加

`simple_youtube_setup.dart` の `popularYouTubers` に追加：

```dart
static const Map<String, String> popularYouTubers = {
  'ヒカキン': 'UCZf__ehlCEBPop-_sldpBUQ',
  '好きなYouTuber': 'チャンネルID',  // ← 追加
};
```

### チャンネルIDの調べ方

1. YouTuberのチャンネルページに行く
2. URLをチェック：
   - `https://www.youtube.com/channel/UC123456789...` → `UC123456789...` がチャンネルID
   - `https://www.youtube.com/@YouTuberName` の場合は、ページのソースを表示して `"channelId":"UC..."` を探す

### 取得する動画数を変更

`simple_youtube_service.dart` の `maxResults` を変更：

```dart
// 10本 → 20本に変更
'&maxResults=20'
```

## ⚠️ 注意事項

### APIの制限について

- **無料枠**: 1日10,000リクエスト
- **チャンネル情報取得**: 1リクエスト消費
- **動画リスト取得**: 2-3リクエスト消費
- **動画検索**: 100リクエスト消費（注意！）

### エラーが出たときの対処法

#### ❌ 「APIキーが無効」エラー
- APIキーが正しく設定されているか確認
- YouTube Data API v3が有効になっているか確認

#### ❌ 「クォータ超過」エラー  
- 1日の制限を超えています
- 明日まで待つか、Google Cloud Consoleで課金を有効にする

#### ❌ 「チャンネルが見つからない」エラー
- チャンネルIDが正しいか確認
- チャンネルが非公開になっていないか確認

## 🎯 応用例

### Starlistアプリでの活用方法

1. **スター登録時にYouTubeチャンネル連携**
   ```dart
   final channel = await SimpleYouTubeService.getChannel(channelId);
   // スターのプロフィールに反映
   ```

2. **毎日ピック機能で最新動画を自動取得**
   ```dart
   final videos = await SimpleYouTubeService.getChannelVideos(channelId);
   // 最新動画を毎日ピックに追加
   ```

3. **投票システムで動画比較**
   ```dart
   // 2つの動画で人気投票
   final video1 = videos[0];
   final video2 = videos[1];
   ```

## 🔗 参考リンク

- [YouTube Data API v3 公式ドキュメント](https://developers.google.com/youtube/v3)
- [Google Cloud Console](https://console.cloud.google.com/)
- [Flutter url_launcher パッケージ](https://pub.dev/packages/url_launcher)

## 📞 困ったときは

1. まず `SimpleYouTubeSetup.printSetupStatus()` で設定確認
2. エラーメッセージをよく読む
3. APIキーと制限設定を再確認
4. 無料枠の使用状況をGoogle Cloud Consoleで確認

---

**🎉 これで中学生でもYouTube APIが使えます！**  
**何か分からないことがあれば、エラーメッセージを確認してね！**

## DoD (Definition of Done)
- [ ] 文書の目的と完了基準を明記しました。
