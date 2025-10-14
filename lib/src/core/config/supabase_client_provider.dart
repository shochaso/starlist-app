import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Provides the Supabase client instance
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  final client = Supabase.instance.client;
  // 起動時に Supabase.initialize 済みが前提（main.dart等）
  if (client.auth.currentSession == null) {
    // 認証前でも read-only は可だが、RLSで user_id 必須の操作は不可
    // ログイン画面などでは問題なし
  }
  return client;
});

