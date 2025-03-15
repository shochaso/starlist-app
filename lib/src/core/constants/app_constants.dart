/// アプリケーション全体で使用する定数を定義するクラス
class AppConstants {
  // プライベートコンストラクタ
  AppConstants._();

  // アプリ情報
  static const String appName = 'Starlist';
  static const String appVersion = '1.0.0';
  
  // API エンドポイント
  static const String apiBaseUrl = 'https://api.starlist.app';
  static const String youtubeApiBaseUrl = 'https://www.googleapis.com/youtube/v3';
  static const String spotifyApiBaseUrl = 'https://api.spotify.com/v1';
  
  // ローカルストレージキー
  static const String tokenKey = 'auth_token';
  static const String userKey = 'current_user';
  static const String themeKey = 'app_theme';
  static const String languageKey = 'app_language';
  
  // デフォルト設定
  static const int defaultPageSize = 20;
  static const int maxFollowLimitFree = 5;
  static const int maxFollowLimitStandard = 10;
  static const int maxFollowLimitPremium = 20;
  
  // サブスクリプションプラン
  static const String soloFanPlan = 'solo_fan';
  static const String lightPlan = 'light';
  static const String standardPlan = 'standard';
  static const String premiumPlan = 'premium';
  
  // サブスクリプション価格（円）
  static const int soloFanPrice = 300;
  static const int lightPrice = 500;
  static const int standardPrice = 980;
  static const int premiumPrice = 1980;
  
  // 遅延表示日数
  static const int lightDelayDays = 7;
  static const int standardDelayDays = 3;
  static const int premiumDelayDays = 0;
  
  // バッジレベル
  static const String bronzeBadge = 'bronze';
  static const String silverBadge = 'silver';
  static const String goldBadge = 'gold';
  
  // バッジ獲得条件（円）
  static const int bronzeBadgeThreshold = 3000;
  static const int silverBadgeThreshold = 10000;
  static const int goldBadgeThreshold = 30000;
  
  // アニメーション
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 500);
  static const Duration longAnimationDuration = Duration(milliseconds: 800);
  
  // エラーメッセージ
  static const String networkErrorMessage = 'ネットワーク接続エラーが発生しました。インターネット接続を確認してください。';
  static const String serverErrorMessage = 'サーバーエラーが発生しました。しばらく経ってからもう一度お試しください。';
  static const String authErrorMessage = '認証エラーが発生しました。再度ログインしてください。';
  static const String unknownErrorMessage = '予期せぬエラーが発生しました。';
  
  // 画像パス
  static const String defaultAvatarPath = 'assets/images/default_avatar.png';
  static const String defaultBannerPath = 'assets/images/default_banner.png';
  static const String logoPath = 'assets/images/logo.png';
  
  // コンテンツカテゴリ
  static const List<String> contentCategories = [
    'YouTube',
    '音楽',
    '映像',
    '書籍',
    '購入',
    'アプリ',
    '食事',
    'その他'
  ];
  
  // スタータイプ
  static const List<String> starTypes = [
    'YouTuber',
    'VTuber',
    'ストリーマー',
    'クリエイター',
    '一般人スター'
  ];
}
