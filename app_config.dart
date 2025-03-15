import 'package:flutter/foundation.dart';

/// アプリケーション全体の設定を管理するクラス
class AppConfig {
  /// シングルトンインスタンス
  static final AppConfig _instance = AppConfig._internal();

  /// シングルトンインスタンスを取得
  factory AppConfig() => _instance;

  /// プライベートコンストラクタ
  AppConfig._internal();

  /// 環境設定
  late final Environment _environment;

  /// Supabase URL
  late final String _supabaseUrl;

  /// Supabase API キー
  late final String _supabaseAnonKey;

  /// YouTube API キー
  late final String _youtubeApiKey;

  /// Spotify クライアント ID
  late final String _spotifyClientId;

  /// Spotify クライアントシークレット
  late final String _spotifyClientSecret;

  /// 環境設定を取得
  Environment get environment => _environment;

  /// Supabase URL を取得
  String get supabaseUrl => _supabaseUrl;

  /// Supabase API キーを取得
  String get supabaseAnonKey => _supabaseAnonKey;

  /// YouTube API キーを取得
  String get youtubeApiKey => _youtubeApiKey;

  /// Spotify クライアント ID を取得
  String get spotifyClientId => _spotifyClientId;

  /// Spotify クライアントシークレットを取得
  String get spotifyClientSecret => _spotifyClientSecret;

  /// アプリケーション設定を初期化
  void initialize({
    required Environment environment,
    required String supabaseUrl,
    required String supabaseAnonKey,
    required String youtubeApiKey,
    required String spotifyClientId,
    required String spotifyClientSecret,
  }) {
    _environment = environment;
    _supabaseUrl = supabaseUrl;
    _supabaseAnonKey = supabaseAnonKey;
    _youtubeApiKey = youtubeApiKey;
    _spotifyClientId = spotifyClientId;
    _spotifyClientSecret = spotifyClientSecret;
  }

  /// 開発環境かどうかを判定
  bool get isDevelopment => _environment == Environment.development;

  /// 本番環境かどうかを判定
  bool get isProduction => _environment == Environment.production;

  /// ステージング環境かどうかを判定
  bool get isStaging => _environment == Environment.staging;

  /// デバッグモードかどうかを判定
  bool get isDebugMode => kDebugMode;
}

/// アプリケーション環境
enum Environment {
  /// 開発環境
  development,

  /// ステージング環境
  staging,

  /// 本番環境
  production,
}
