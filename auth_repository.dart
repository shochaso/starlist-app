import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/errors/app_exceptions.dart';
import '../domain/services/auth_service.dart';

/// 認証リポジトリクラス
/// 
/// Supabaseとの認証関連の通信を担当します。
class AuthRepository {
  /// Supabaseクライアント
  final SupabaseClient _supabaseClient;

  /// コンストラクタ
  AuthRepository({SupabaseClient? supabaseClient})
      : _supabaseClient = supabaseClient ?? Supabase.instance.client;

  /// メールアドレスとパスワードでサインアップ
  Future<User?> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String username,
    required String displayName,
  }) async {
    try {
      // ユーザーデータを準備
      final userData = {
        'username': username,
        'display_name': displayName,
        'user_type': 'fan', // デフォルトはファン
      };

      // サインアップ
      final response = await _supabaseClient.auth.signUp(
        email: email,
        password: password,
        data: userData,
      );

      if (response.user == null) {
        throw AuthException('サインアップに失敗しました');
      }

      return response.user;
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('サインアップ中にエラーが発生しました: ${e.toString()}', details: e);
    }
  }

  /// メールアドレスとパスワードでサインイン
  Future<User?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw AuthException('サインインに失敗しました');
      }

      return response.user;
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('サインイン中にエラーが発生しました: ${e.toString()}', details: e);
    }
  }

  /// Googleでサインイン
  Future<void> signInWithGoogle() async {
    try {
      await _supabaseClient.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.starlist://login-callback',
      );
    } catch (e) {
      throw AuthException('Googleサインイン中にエラーが発生しました: ${e.toString()}', details: e);
    }
  }

  /// Appleでサインイン
  Future<void> signInWithApple() async {
    try {
      await _supabaseClient.auth.signInWithOAuth(
        OAuthProvider.apple,
        redirectTo: 'io.supabase.starlist://login-callback',
      );
    } catch (e) {
      throw AuthException('Appleサインイン中にエラーが発生しました: ${e.toString()}', details: e);
    }
  }

  /// Twitterでサインイン
  Future<void> signInWithTwitter() async {
    try {
      await _supabaseClient.auth.signInWithOAuth(
        OAuthProvider.twitter,
        redirectTo: 'io.supabase.starlist://login-callback',
      );
    } catch (e) {
      throw AuthException('Twitterサインイン中にエラーが発生しました: ${e.toString()}', details: e);
    }
  }

  /// Instagramでサインイン（注：Supabaseは直接Instagramをサポートしていないため、カスタム実装が必要）
  Future<void> signInWithInstagram() async {
    throw UnimplementedError('Instagramサインインは現在実装されていません');
  }

  /// サインアウト
  Future<void> signOut() async {
    try {
      await _supabaseClient.auth.signOut();
    } catch (e) {
      throw AuthException('サインアウト中にエラーが発生しました: ${e.toString()}', details: e);
    }
  }

  /// パスワードリセットメールを送信
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _supabaseClient.auth.resetPasswordForEmail(
        email,
        redirectTo: 'io.supabase.starlist://reset-callback',
      );
    } catch (e) {
      throw AuthException('パスワードリセットメール送信中にエラーが発生しました: ${e.toString()}', details: e);
    }
  }

  /// パスワードを更新
  Future<void> updatePassword(String newPassword) async {
    try {
      await _supabaseClient.auth.updateUser(
        UserAttributes(password: newPassword),
      );
    } catch (e) {
      throw AuthException('パスワード更新中にエラーが発生しました: ${e.toString()}', details: e);
    }
  }

  /// ユーザープロファイルを更新
  Future<User?> updateUserProfile({
    String? username,
    String? displayName,
    String? profileImageUrl,
    String? bannerImageUrl,
    String? bio,
  }) async {
    try {
      final userData = <String, dynamic>{};

      if (username != null) userData['username'] = username;
      if (displayName != null) userData['display_name'] = displayName;
      if (profileImageUrl != null) userData['profile_image_url'] = profileImageUrl;
      if (bannerImageUrl != null) userData['banner_image_url'] = bannerImageUrl;
      if (bio != null) userData['bio'] = bio;

      final response = await _supabaseClient.auth.updateUser(
        UserAttributes(data: userData),
      );

      return response.user;
    } catch (e) {
      throw AuthException('プロフィール更新中にエラーが発生しました: ${e.toString()}', details: e);
    }
  }

  /// 現在のユーザーを取得
  User? getCurrentUser() {
    return _supabaseClient.auth.currentUser;
  }

  /// 認証状態の変更を監視
  Stream<AuthState> authStateChanges() {
    return _supabaseClient.auth.onAuthStateChange;
  }

  /// ユーザーセッションの変更を監視
  Stream<AuthState> userSessionChanges() {
    return _supabaseClient.auth.onAuthStateChange.where(
      (state) => state.event == AuthChangeEvent.tokenRefreshed || 
                 state.event == AuthChangeEvent.signedIn ||
                 state.event == AuthChangeEvent.signedOut,
    );
  }

  /// ユーザーがサインインしているかどうかを確認
  bool isSignedIn() {
    return _supabaseClient.auth.currentUser != null;
  }

  /// ユーザーのメールアドレスが確認済みかどうかを確認
  bool isEmailVerified() {
    final user = _supabaseClient.auth.currentUser;
    return user?.emailConfirmedAt != null;
  }

  /// スター認証リクエストを送信
  Future<void> requestStarVerification({
    required String userId,
    required String socialMediaUrl,
    String? verificationDocumentUrl,
  }) async {
    try {
      // スター認証リクエストをデータベースに保存
      await _supabaseClient.from('star_verification_requests').insert({
        'user_id': userId,
        'social_media_url': socialMediaUrl,
        'verification_document_url': verificationDocumentUrl,
        'status': 'pending',
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw DatabaseException('スター認証リクエスト送信中にエラーが発生しました: ${e.toString()}', details: e);
    }
  }

  /// スター認証ステータスを確認
  Future<String> checkStarVerificationStatus(String userId) async {
    try {
      final response = await _supabaseClient
          .from('star_verification_requests')
          .select('status')
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(1)
          .single();

      return response['status'] as String;
    } catch (e) {
      throw DatabaseException('スター認証ステータス確認中にエラーが発生しました: ${e.toString()}', details: e);
    }
  }

  /// ユーザータイプを更新（ファン→スター）
  Future<void> updateUserType(String userId, String userType) async {
    try {
      // ユーザーデータを更新
      await _supabaseClient.from('profiles').update({
        'user_type': userType,
      }).eq('id', userId);

      // 認証ユーザーデータも更新
      final user = _supabaseClient.auth.currentUser;
      if (user != null) {
        await _supabaseClient.auth.updateUser(
          UserAttributes(data: {'user_type': userType}),
        );
      }
    } catch (e) {
      throw DatabaseException('ユーザータイプ更新中にエラーが発生しました: ${e.toString()}', details: e);
    }
  }
}
