import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide Provider;

/// Supabaseクライアントのプロバイダー
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

/// Supabase認証状態のプロバイダー
final authStateProvider = StreamProvider<AuthState>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return client.auth.onAuthStateChange;
});

/// 現在のユーザーのプロバイダー
final currentUserProvider = Provider<User?>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return client.auth.currentUser;
});

/// ユーザーがログインしているかどうかのプロバイダー
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(currentUserProvider) != null;
});

/// Supabase認証サービス
class SupabaseAuthService {
  final SupabaseClient _client;

  SupabaseAuthService(this._client);

  /// メールとパスワードでサインアップ
  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    Map<String, dynamic>? data,
  }) async {
    return await _client.auth.signUp(
      email: email,
      password: password,
      data: data,
    );
  }
  
  /// ユーザー登録（signUp）
  /// email: メールアドレス
  /// password: パスワード
  /// userData: ユーザー情報（メタデータ）
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    Map<String, dynamic>? userData,
  }) async {
    return await _client.auth.signUp(
      email: email,
      password: password,
      data: userData,
    );
  }

  /// メールとパスワードでサインイン
  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// 現在のセッションを取得
  Future<Session?> getSession() async {
    return _client.auth.currentSession;
  }

  /// サインアウト
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  /// パスワードリセットメールを送信
  Future<void> resetPassword(String email) async {
    await _client.auth.resetPasswordForEmail(email);
  }

  /// 新しいパスワードを設定
  Future<UserResponse> updatePassword(String newPassword) async {
    return await _client.auth.updateUser(
      UserAttributes(password: newPassword),
    );
  }
}

/// Supabase認証サービスのプロバイダー
final supabaseAuthServiceProvider = Provider<SupabaseAuthService>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseAuthService(client);
}); 