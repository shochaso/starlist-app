/// 中学生でもできる！YouTube API設定ガイド
/// 
/// このファイルでAPIキーの設定をします
library;

class SimpleYouTubeSetup {
  /// ステップ1: APIキーを設定する
  /// 
  /// 1. Google Cloud Consoleに行く: https://console.cloud.google.com/
  /// 2. 新しいプロジェクトを作る
  /// 3. 「APIとサービス」→「ライブラリ」に行く
  /// 4. 「YouTube Data API v3」を探して有効にする
  /// 5. 「認証情報」に行って「APIキーを作成」をクリック
  /// 6. 作成されたAPIキーをコピーして下の''の中に貼り付ける
  
  static const String myApiKey = 'YOUR_API_KEY_HERE';  // ← ここにAPIキーを貼り付け！
  
  /// ステップ2: よく使うYouTuberのチャンネルIDリスト
  /// 
  /// チャンネルIDの調べ方：
  /// 1. YouTuberのチャンネルページに行く
  /// 2. URLの最後の部分がチャンネルID
  /// 例: https://www.youtube.com/channel/UC123456789... → UC123456789...が チャンネルID
  
  static const Map<String, String> popularYouTubers = {
    'ヒカキン': 'UCZf__ehlCEBPop-_sldpBUQ',
    'はじめしゃちょー': 'UCgMPP6RRjktV7krOfyUewqw', 
    'フィッシャーズ': 'UCibEhpu5HP45-w7Bq1ZIulw',
    'キヨ': 'UCuC4_VGkmxNJF1SJ3E_i4sQ',
    'テスト用チャンネル': 'UC_x5XG1OV2P6uZZ5FSM9Ttw', // Google Developers
  };
  
  /// ステップ3: 設定をチェックする関数
  static bool isSetupComplete() {
    // APIキーが設定されているかチェック
    if (myApiKey == 'YOUR_API_KEY_HERE') {
      print('❌ APIキーが設定されていません！');
      print('📝 SimpleYouTubeSetup.myApiKeyにYour APIキーを設定してください');
      return false;
    }
    
    if (myApiKey.length < 30) {
      print('❌ APIキーが短すぎます。正しいAPIキーを設定してください');
      return false;
    }
    
    print('✅ 設定完了！YouTube APIが使えます');
    return true;
  }
  
  /// 設定確認用の関数（デバッグ用）
  static void printSetupStatus() {
    print('=== YouTube API 設定状況 ===');
    print('APIキー設定済み: ${myApiKey != 'YOUR_API_KEY_HERE'}');
    print('APIキーの長さ: ${myApiKey.length}文字');
    print('登録済みYouTuber数: ${popularYouTubers.length}人');
    print('==========================');
  }
}