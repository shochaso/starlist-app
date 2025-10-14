/// データ取り込み対応サービスマトリクス
/// 
/// MVP版で対応するサービスとカテゴリを定義。
/// 対応外のサービスは「タグのみ」モードで保存される。
class SupportMatrix {
  /// カテゴリ別対応サービスマップ
  static const Map<String, List<String>> services = {
    // 動画配信（MVP: YouTubeのみ）
    'video': [
      'youtube', // ✅ 実装済み
      // 以下は「タグのみ」経路
      'prime_video',
      'netflix',
      'unext',
      'hulu_jp',
    ],
    
    // ショッピング（MVP: Amazon、楽天、Yahoo!）
    'shopping': [
      'amazon', // ✅ 実装済み
      'rakuten',
      'yahoo_shopping',
    ],
    
    // フードデリバリー
    'food_delivery': [
      'ubereats',
      'demaecan',
    ],
    
    // コンビニ（セイコーマート除外）
    'convenience_store': [
      'seven',
      'familymart',
      'lawson',
      'daily_yamazaki',
      'ministop',
    ],
    
    // 音楽（MVP: Spotifyのみ）
    'music': [
      'spotify', // ✅ 実装済み
      'amazon_music',
      'apple_music',
    ],
    
    // ゲーム（プレイ情報のみ、購入情報は保存しない）
    'game_play': [
      'steam',
      'psn',
      'nintendo',
    ],
    
    // スマホアプリ
    'mobile_apps': [
      'ios_appstore',
      'android_playstore',
    ],
    
    // アプリ使用時間
    'screen_time': [
      'ios_screentime',
      'android_digital_wellbeing',
    ],
    
    // ファッション
    'fashion': [
      'zozo',
      'uniqlo',
      'gu',
      'shein',
      'wear_log', // 手入力
    ],
    
    // レシート（MVP: 実装済み）
    'receipt': [
      'receipt_ocr', // ✅ 実装済み
    ],
  };

  /// MVP実装済みサービス（フルモード対応）
  static const List<String> mvpImplemented = [
    'youtube',
    'amazon',
    'spotify',
    'receipt_ocr',
  ];

  /// カテゴリとサービスが対応しているかチェック
  /// 
  /// [category] カテゴリ名（例: 'video', 'shopping'）
  /// [service] サービス名（省略時はカテゴリのみチェック）
  /// 
  /// 戻り値: 対応していれば true
  static bool isSupported(String category, [String? service]) {
    final list = services[category];
    if (list == null) return false;
    return service == null ? true : list.contains(service);
  }

  /// MVP実装済み（フルモード対応）かチェック
  /// 
  /// [service] サービス名
  /// 
  /// 戻り値: フルモード対応なら true、タグのみなら false
  static bool isMvpImplemented(String service) {
    return mvpImplemented.contains(service);
  }

  /// カテゴリからサービスリストを取得
  /// 
  /// [category] カテゴリ名
  /// 
  /// 戻り値: サービス名のリスト（存在しない場合は空リスト）
  static List<String> getServicesForCategory(String category) {
    return services[category] ?? [];
  }

  /// 全カテゴリのリストを取得
  static List<String> getAllCategories() {
    return services.keys.toList();
  }

  /// サービス名から表示用ラベルを取得
  static String getServiceLabel(String service) {
    const labels = {
      // 動画
      'youtube': 'YouTube',
      'prime_video': 'Amazon Prime Video',
      'netflix': 'Netflix',
      'unext': 'U-NEXT',
      'hulu_jp': 'Hulu（日本）',
      
      // ショッピング
      'amazon': 'Amazon',
      'rakuten': '楽天市場',
      'yahoo_shopping': 'Yahoo!ショッピング',
      
      // フードデリバリー
      'ubereats': 'Uber Eats',
      'demaecan': '出前館',
      
      // コンビニ
      'seven': 'セブンイレブン',
      'familymart': 'ファミリーマート',
      'lawson': 'ローソン',
      'daily_yamazaki': 'デイリーヤマザキ',
      'ministop': 'ミニストップ',
      
      // 音楽
      'spotify': 'Spotify',
      'amazon_music': 'Amazon Music',
      'apple_music': 'Apple Music',
      
      // ゲーム
      'steam': 'Steam',
      'psn': 'PlayStation Network',
      'nintendo': 'Nintendo',
      
      // スマホアプリ
      'ios_appstore': 'iOS App Store',
      'android_playstore': 'Google Play',
      
      // 使用時間
      'ios_screentime': 'iOSスクリーンタイム',
      'android_digital_wellbeing': 'Android Digital Wellbeing',
      
      // ファッション
      'zozo': 'ZOZOTOWN',
      'uniqlo': 'UNIQLO',
      'gu': 'GU',
      'shein': 'SHEIN',
      'wear_log': '着用ログ',
      
      // レシート
      'receipt_ocr': 'レシート',
    };
    
    return labels[service] ?? service;
  }

  /// カテゴリ名から表示用ラベルを取得
  static String getCategoryLabel(String category) {
    const labels = {
      'video': '動画',
      'shopping': 'ショッピング',
      'food_delivery': 'フードデリバリー',
      'convenience_store': 'コンビニ',
      'music': '音楽',
      'game_play': 'ゲーム',
      'mobile_apps': 'スマホアプリ',
      'screen_time': 'アプリ使用時間',
      'fashion': 'ファッション',
      'receipt': 'レシート',
    };
    
    return labels[category] ?? category;
  }
}

