/// データ取り込み機能の設定定数
/// 
/// タイムアウト、SLA、制限値などを定義。
class DataImportConfig {
  /// 画像エンリッチメント（サムネイル取得）のタイムアウト（ミリ秒）
  /// 
  /// 要件: 最大3枚/1200ms以内
  static const int kMaxEnrichTimeMs = 1200;

  /// UI応答SLA（ミリ秒）
  /// 
  /// 要件: 解析→候補表示まで1.5秒以内
  static const int kUiResponseSlaMs = 1500;

  /// タグ最大数
  /// 
  /// 検索インデックスのパフォーマンスを考慮
  static const int kMaxTagsCount = 64;

  /// 自由テキストから抽出する単語の最小文字数
  static const int kMinWordLength = 2;

  /// OCR解析のタイムアウト（ミリ秒）
  static const int kOcrParseTimeoutMs = 3000;

  /// 画像アップロードの最大サイズ（バイト）
  static const int kMaxImageSizeBytes = 10 * 1024 * 1024; // 10MB

  /// 一度に処理できる最大アイテム数
  static const int kMaxBatchSize = 100;

  /// エンリッチメント時の並列処理数
  /// 
  /// 要件: 最大3枚の画像を同時取得
  static const int kMaxParallelEnrich = 3;

  /// 候補カード表示の最大行数
  static const int kMaxCandidateLines = 50;

  /// 検索時のタグのみ表示トグルのデフォルト値
  static const bool kIncludeTagOnlyByDefault = false;

  /// データ取り込み確認ダイアログの自動表示間隔（日数）
  /// 
  /// OCR注意事項の再表示頻度
  static const int kWarningDialogIntervalDays = 7;

  /// ゲームプレイ情報のメタデータキー
  /// 
  /// 購入情報は保存しない（nullまたは未設定）
  static const List<String> kGamePlayMetadataKeys = [
    'play_time',
    'achievement',
    'level',
    'score',
    // 'purchase_info', // ← 保存しない
  ];

  /// サポートされるカテゴリのリスト
  static const List<String> kSupportedCategories = [
    'video',
    'shopping',
    'food_delivery',
    'convenience_store',
    'music',
    'game_play',
    'mobile_apps',
    'screen_time',
    'fashion',
    'receipt',
  ];

  /// デバッグモードフラグ
  /// 
  /// true の場合、詳細ログを出力
  static const bool kDebugMode = false;

  /// ローカルストレージのキー
  static const String kLastWarningDialogKey = 'last_ocr_warning_dialog';
  static const String kIncludeTagOnlyKey = 'include_tag_only_in_search';
}

