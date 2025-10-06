import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// SupabaseClientをRiverpodで提供するプロバイダー
/// 
/// アプリの起動時にSupabase.initializeが済んでいることが前提
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  final client = Supabase.instance.client;
  
  // 認証前でも read-only は可だが、RLSで user_id 必須の操作は不可
  // セッション状態のログ出力（デバッグ用）
  if (client.auth.currentSession == null) {
    // セッションが存在しない場合でも、一部の操作は可能
    // 認証が必要な操作では、適切なエラーハンドリングを行う
  }
  
  return client;
});

/// 現在のSupabaseユーザーを取得するプロバイダー
final currentSupabaseUserProvider = StreamProvider<User?>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return client.auth.onAuthStateChange.map((data) => data.session?.user);
});

/// Supabase認証状態を監視するプロバイダー
final supabaseAuthStateProvider = StreamProvider<AuthState>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return client.auth.onAuthStateChange;
});