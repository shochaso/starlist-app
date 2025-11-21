/// Centralized access to environment configuration values used across the app.
///
/// Values are primarily supplied via `--dart-define` at build time. Each getter
/// falls back to a sane development default so that the application can still
/// run in local environments without manual configuration.
class EnvironmentConfig {
  const EnvironmentConfig._();

  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://zjwvmoxpacbpwawlwbrd.supabase.co',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inpqd3Ztb3hwYWNicHdhd2x3YnJkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDEzNTQwMzMsImV4cCI6MjA1NjkzMDAzM30.37KDj4QhQmv6crotphR9GnPTM_0zv0PCCnKfXvsZx_g',
  );

  static const String assetsCdnOrigin = String.fromEnvironment(
    'ASSETS_CDN_ORIGIN',
    defaultValue: 'https://cdn.starlist.jp',
  );

  static const String bucketPublicIcons = String.fromEnvironment(
    'BUCKET_PUBLIC_ICONS',
    defaultValue: 'public/icons',
  );

  static const String bucketPublicDerived = String.fromEnvironment(
    'BUCKET_PUBLIC_DERIVED',
    defaultValue: 'public/derived',
  );

  static const String bucketPrivateOriginals = String.fromEnvironment(
    'BUCKET_PRIVATE_ORIGINALS',
    defaultValue: 'private/originals',
  );

  static const int signedUrlTtlSeconds = int.fromEnvironment(
    'SIGNED_URL_TTL_SECONDS',
    defaultValue: 900,
  );

  static const String appBuildVersion = String.fromEnvironment(
    'APP_BUILD_VERSION',
    defaultValue: 'dev',
  );

  static const String docAiApiBase = String.fromEnvironment(
    'API_BASE',
    defaultValue: 'https://ocr-proxy-1092709877001.us-central1.run.app',
  );

  static const String openaiApiKey = String.fromEnvironment(
    'OPENAI_API_KEY',
    defaultValue: '',
  );

  static const String youtubeApiKey = String.fromEnvironment(
    'YOUTUBE_API_KEY',
    defaultValue: '',
  );
}
