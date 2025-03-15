import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiKeyManager {
  static String getSupabaseUrl() => dotenv.env['SUPABASE_URL'] ?? '';
  static String getSupabaseAnonKey() => dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  
  static String getYoutubeApiKey() => dotenv.env['YOUTUBE_API_KEY'] ?? '';
  static String getSpotifyClientId() => dotenv.env['SPOTIFY_CLIENT_ID'] ?? '';
  static String getSpotifyClientSecret() => dotenv.env['SPOTIFY_CLIENT_SECRET'] ?? '';
  static String getTwitterApiKey() => dotenv.env['TWITTER_API_KEY'] ?? '';

  // APIキー有効性チェック
  static bool hasValidYoutubeApiKey() => getYoutubeApiKey().isNotEmpty;
  static bool hasValidSpotifyCredentials() => 
      getSpotifyClientId().isNotEmpty && getSpotifyClientSecret().isNotEmpty;

  // すべての必要なキーが設定されているか確認
  static bool hasAllRequiredKeys() {
    return getSupabaseUrl().isNotEmpty && 
           getSupabaseAnonKey().isNotEmpty &&
           hasValidYoutubeApiKey() &&
           hasValidSpotifyCredentials();
  }

  // エラーメッセージ取得
  static String getMissingKeysMessage() {
    final missingKeys = <String>[];
    
    if (getSupabaseUrl().isEmpty) missingKeys.add('SUPABASE_URL');
    if (getSupabaseAnonKey().isEmpty) missingKeys.add('SUPABASE_ANON_KEY');
    if (!hasValidYoutubeApiKey()) missingKeys.add('YOUTUBE_API_KEY');
    if (!hasValidSpotifyCredentials()) missingKeys.add('SPOTIFY_CLIENT_ID/SECRET');
    
    if (missingKeys.isEmpty) return '';
    return '次の環境変数が設定されていません: ${missingKeys.join(', ')}';
  }
} 