import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/repositories/auth_repository.dart';
import '../../../shared/models/user_model.dart';
import '../../../core/errors/app_exceptions.dart';

/// 認証サービスクラス
/// 
/// 認証関連のビジネスロジックを担当します。
class AuthService {
  /// 認証リポジトリ
  final AuthRepository _authRepository;

  /// コンストラクタ
  AuthService({AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepository();

  /// メールアドレスとパスワードでサインアップ
  Future<UserModel?> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String username,
    required String displayName,
  }) async {
    try {
      // ユーザー名の重複チェックなどの追加バリデーション
      if (username.length < 3) {
        throw ValidationException('ユーザー名は3文字以上である必要があります');
      }

      if (password.length < 8) {
        throw ValidationException('パスワードは8文字以上である必要があります');
      }

      // リポジトリを通じてサインアップ
      final user = await _authRepository.signUpWithEmailAndPassword(
        email: email,
        password: password,
        username: username,
        displayName: displayName,
      );

      if (user == null) {
        return null;
      }

      // UserModelに変換して返す
      return _convertToUserModel(user);
    } catch (e) {
      if (e is ValidationException || e is AuthException) rethrow;
      throw ServiceException('サインアップ中にエラーが発生しました: ${e.toString()}', details: e);
    }
  }

  /// メールアドレスとパスワードでサインイン
  Future<UserModel?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      // リポジトリを通じてサインイン
      final user = await _authRepository.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (user == null) {
        return null;
      }

      // UserModelに変換して返す
      return _convertToUserModel(user);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw ServiceException('サインイン中にエラーが発生しました: ${e.toString()}', details: e);
    }
  }

  /// Googleでサインイン
  Future<void> signInWithGoogle() async {
    try {
      await _authRepository.signInWithGoogle();
    } catch (e) {
      if (e is AuthException) rethrow;
      throw ServiceException('Googleサインイン中にエラーが発生しました: ${e.toString()}', details: e);
    }
  }

  /// Appleでサインイン
  Future<void> signInWithApple() async {
    try {
      await _authRepository.signInWithApple();
    } catch (e) {
      if (e is AuthException) rethrow;
      throw ServiceException('Appleサインイン中にエラーが発生しました: ${e.toString()}', details: e);
    }
  }

  /// Twitterでサインイン
  Future<void> signInWithTwitter() async {
    try {
      await _authRepository.signInWithTwitter();
    } catch (e) {
      if (e is AuthException) rethrow;
      throw ServiceException('Twitterサインイン中にエラーが発生しました: ${e.toString()}', details: e);
    }
  }

  /// Instagramでサインイン
  Future<void> signInWithInstagram() async {
    try {
      await _authRepository.signInWithInstagram();
    } catch (e) {
      if (e is AuthException) rethrow;
      throw ServiceException('Instagramサインイン中にエラーが発生しました: ${e.toString()}', details: e);
    }
  }

  /// サインアウト
  Future<void> signOut() async {
    try {
      await _authRepository.signOut();
    } catch (e) {
      if (e is AuthException) rethrow;
      throw ServiceException('サインアウト中にエラーが発生しました: ${e.toString()}', details: e);
    }
  }

  /// パスワードリセットメールを送信
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      // メールアドレスの形式チェック
      if (!_isValidEmail(email)) {
        throw ValidationException('有効なメールアドレスを入力してください');
      }

      await _authRepository.sendPasswordResetEmail(email);
    } catch (e) {
      if (e is ValidationException || e is AuthException) rethrow;
      throw ServiceException('パスワードリセットメール送信中にエラーが発生しました: ${e.toString()}', details: e);
    }
  }

  /// パスワードを更新
  Future<void> updatePassword(String newPassword) async {
    try {
      // パスワードの強度チェック
      if (newPassword.length < 8) {
        throw ValidationException('パスワードは8文字以上である必要があります');
      }

      if (!_isStrongPassword(newPassword)) {
        throw ValidationException('パスワードには文字、数字、特殊文字を含める必要があります');
      }

      await _authRepository.updatePassword(newPassword);
    } catch (e) {
      if (e is ValidationException || e is AuthException) rethrow;
      throw ServiceException('パスワード更新中にエラーが発生しました: ${e.toString()}', details: e);
    }
  }

  /// ユーザープロファイルを更新
  Future<UserModel?> updateUserProfile({
    String? username,
    String? displayName,
    String? profileImageUrl,
    String? bannerImageUrl,
    String? bio,
  }) async {
    try {
      // ユーザー名のバリデーション
      if (username != null && username.length < 3) {
        throw ValidationException('ユーザー名は3文字以上である必要があります');
      }

      // 表示名のバリデーション
      if (displayName != null && displayName.isEmpty) {
        throw ValidationException('表示名は空にできません');
      }

      // 自己紹介のバリデーション
      if (bio != null && bio.length > 500) {
        throw ValidationException('自己紹介は500文字以内である必要があります');
      }

      final user = await _authRepository.updateUserProfile(
        username: username,
        displayName: displayName,
        profileImageUrl: profileImageUrl,
        bannerImageUrl: bannerImageUrl,
        bio: bio,
      );

      if (user == null) {
        return null;
      }

      return _convertToUserModel(user);
    } catch (e) {
      if (e is ValidationException || e is AuthException) rethrow;
      throw ServiceException('プロフィール更新中にエラーが発生しました: ${e.toString()}', details: e);
    }
  }

  /// 現在のユーザーを取得
  UserModel? getCurrentUser() {
    final user = _authRepository.getCurrentUser();
    if (user == null) {
      return null;
    }

    return _convertToUserModel(user);
  }

  /// 認証状態の変更を監視
  Stream<UserModel?> authStateChanges() {
    return _authRepository.authStateChanges().map((state) {
      final user = state.session?.user;
      if (user == null) {
        return null;
      }

      return _convertToUserModel(user);
    });
  }

  /// ユーザーセッションの変更を監視
  Stream<UserModel?> userSessionChanges() {
    return _authRepository.userSessionChanges().map((state) {
      final user = state.session?.user;
      if (user == null) {
        return null;
      }

      return _convertToUserModel(user);
    });
  }

  /// ユーザーがサインインしているかどうかを確認
  bool isSignedIn() {
    return _authRepository.isSignedIn();
  }

  /// ユーザーのメールアドレスが確認済みかどうかを確認
  bool isEmailVerified() {
    return _authRepository.isEmailVerified();
  }

  /// スター認証リクエストを送信
  Future<void> requestStarVerification({
    required String socialMediaUrl,
    String? verificationDocumentUrl,
  }) async {
    try {
      final user = _authRepository.getCurrentUser();
      if (user == null) {
        throw AuthException('認証されていません');
      }

      // URLのバリデーション
      if (!_isValidUrl(socialMediaUrl)) {
        throw ValidationException('有効なSNSプロフィールURLを入力してください');
      }

      if (verificationDocumentUrl != null && !_isValidUrl(verificationDocumentUrl)) {
        throw ValidationException('有効な証明書類URLを入力してください');
      }

      await _authRepository.requestStarVerification(
        userId: user.id,
        socialMediaUrl: socialMediaUrl,
        verificationDocumentUrl: verificationDocumentUrl,
      );
    } catch (e) {
      if (e is ValidationException || e is AuthException || e is DatabaseException) rethrow;
      throw ServiceException('スター認証リクエスト送信中にエラーが発生しました: ${e.toString()}', details: e);
    }
  }

  /// スター認証ステータスを確認
  Future<String> checkStarVerificationStatus() async {
    try {
      final user = _authRepository.getCurrentUser();
      if (user == null) {
        throw AuthException('認証されていません');
      }

      return await _authRepository.checkStarVerificationStatus(user.id);
    } catch (e) {
      if (e is AuthException || e is DatabaseException) rethrow;
      throw ServiceException('スター認証ステータス確認中にエラーが発生しました: ${e.toString()}', details: e);
    }
  }

  /// ユーザータイプを更新（ファン→スター）
  Future<void> updateUserType(UserType userType) async {
    try {
      final user = _authRepository.getCurrentUser();
      if (user == null) {
        throw AuthException('認証されていません');
      }

      await _authRepository.updateUserType(user.id, userType.toString().split('.').last);
    } catch (e) {
      if (e is AuthException || e is DatabaseException) rethrow;
      throw ServiceException('ユーザータイプ更新中にエラーが発生しました: ${e.toString()}', details: e);
    }
  }

  /// SupabaseのUserをUserModelに変換
  UserModel _convertToUserModel(User user) {
    final userData = user.userMetadata ?? {};
    
    return UserModel(
      id: user.id,
      email: user.email ?? '',
      username: userData['username'] ?? '',
      displayName: userData['display_name'] ?? '',
      profileImageUrl: userData['profile_image_url'],
      bannerImageUrl: userData['banner_image_url'],
      bio: userData['bio'],
      userType: _getUserTypeFromString(userData['user_type'] ?? 'fan'),
      isVerified: userData['is_verified'] == true,
      followersCount: 0,
      followingCount: 0,
      createdAt: user.createdAt ?? DateTime.now(),
      updatedAt: user.updatedAt ?? DateTime.now(),
    );
  }

  /// 文字列からUserTypeを取得
  UserType _getUserTypeFromString(String userTypeStr) {
    switch (userTypeStr.toLowerCase()) {
      case 'star':
        return UserType.star;
      case 'admin':
        return UserType.admin;
      case 'fan':
      default:
        return UserType.fan;
    }
  }

  /// メールアドレスの形式をチェック
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email);
  }

  /// パスワードの強度をチェック
  bool _isStrongPassword(String password) {
    // 文字、数字、特殊文字を含むかチェック
    final hasLetter = RegExp(r'[a-zA-Z]').hasMatch(password);
    final hasDigit = RegExp(r'[0-9]').hasMatch(password);
    final hasSpecial = RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password);
    
    return hasLetter && hasDigit && hasSpecial;
  }

  /// URLの形式をチェック
  bool _isValidUrl(String url) {
    final urlRegex = RegExp(
      r'^(http|https)://'
      r'([a-zA-Z0-9]([a-zA-Z0-9-]*[a-zA-Z0-9])?\.)+[a-zA-Z0-9]([a-zA-Z0-9-]*[a-zA-Z0-9])?'
      r'(/[a-zA-Z0-9_\-\.~!*\'();:@&=+$,/?%#\[\]]*)?$'
    );
    return urlRegex.hasMatch(url);
  }
}

/// バリデーション例外クラス
class ValidationException implements Exception {
  final String message;
  final dynamic details;

  ValidationException(this.message, {this.details});

  @override
  String toString() => 'ValidationException: $message';
}

/// サービス例外クラス
class ServiceException implements Exception {
  final String message;
  final dynamic details;

  ServiceException(this.message, {this.details});

  @override
  String toString() => 'ServiceException: $message';
}
