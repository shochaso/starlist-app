import 'dart:async';
import 'package:flutter/foundation.dart';
import '../errors/auth_errors.dart';

/// バリデーターインターフェース
abstract class Validator<T> {
  /// バリデーション実行
  Future<ValidationResult> validate(T value);
}

/// バリデーション結果クラス
class ValidationResult {
  /// 有効かどうか
  final bool isValid;
  
  /// エラーメッセージ
  final String? errorMessage;
  
  /// コンストラクタ
  ValidationResult({
    required this.isValid,
    this.errorMessage,
  });
  
  /// 有効な結果を作成
  factory ValidationResult.valid() {
    return ValidationResult(isValid: true);
  }
  
  /// 無効な結果を作成
  factory ValidationResult.invalid(String errorMessage) {
    return ValidationResult(
      isValid: false,
      errorMessage: errorMessage,
    );
  }
}

/// メールバリデーター
class EmailValidator implements Validator<String> {
  @override
  Future<ValidationResult> validate(String value) async {
    // 基本的な形式チェック
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value)) {
      return ValidationResult.invalid('有効なメールアドレスを入力してください');
    }
    
    // 必要に応じて追加のチェック（例：MXレコードの確認など）
    // 実際の実装では非同期処理が必要な場合がある
    
    return ValidationResult.valid();
  }
}

/// パスワードバリデーター
class PasswordValidator implements Validator<String> {
  @override
  Future<ValidationResult> validate(String value) async {
    // 長さチェック
    if (value.length < 8) {
      return ValidationResult.invalid('パスワードは8文字以上である必要があります');
    }
    
    // 強度チェック
    final hasLetter = RegExp(r'[a-zA-Z]').hasMatch(value);
    final hasDigit = RegExp(r'[0-9]').hasMatch(value);
    final hasSpecial = RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value);
    
    if (!hasLetter || !hasDigit || !hasSpecial) {
      return ValidationResult.invalid('パスワードには文字、数字、特殊文字を含める必要があります');
    }
    
    return ValidationResult.valid();
  }
}

/// ユーザー名バリデーター
class UsernameValidator implements Validator<String> {
  final AuthRepository _authRepository;
  
  UsernameValidator(this._authRepository);
  
  @override
  Future<ValidationResult> validate(String value) async {
    // 長さチェック
    if (value.length < 3) {
      return ValidationResult.invalid('ユーザー名は3文字以上である必要があります');
    }
    
    // 使用可能文字チェック
    final validCharsRegex = RegExp(r'^[a-zA-Z0-9_]+$');
    if (!validCharsRegex.hasMatch(value)) {
      return ValidationResult.invalid('ユーザー名には英数字とアンダースコアのみ使用できます');
    }
    
    // 重複チェック（非同期）
    try {
      final isAvailable = await _authRepository.isUsernameAvailable(value);
      if (!isAvailable) {
        return ValidationResult.invalid('このユーザー名は既に使用されています');
      }
    } catch (e) {
      // エラーが発生した場合は一旦有効とする（UIでの検証なので）
      // 最終的なバリデーションはサーバーサイドで行われる
    }
    
    return ValidationResult.valid();
  }
}

/// バリデーターファクトリー
class ValidatorFactory {
  final AuthRepository _authRepository;
  
  ValidatorFactory(this._authRepository);
  
  /// メールバリデーターを取得
  Validator<String> getEmailValidator() {
    return EmailValidator();
  }
  
  /// パスワードバリデーターを取得
  Validator<String> getPasswordValidator() {
    return PasswordValidator();
  }
  
  /// ユーザー名バリデーターを取得
  Validator<String> getUsernameValidator() {
    return UsernameValidator(_authRepository);
  }
}

/// 認証リポジトリ
class AuthRepository {
  final Map<String, AuthProvider> _providers = {};
  final AuthStateNotifier _authStateNotifier;
  
  AuthRepository(this._authStateNotifier);
  
  /// プロバイダーを登録
  void registerProvider(AuthProvider provider) {
    _providers[provider.providerName] = provider;
  }
  
  /// プロバイダーを取得
  AuthProvider? getProvider(String providerName) {
    return _providers[providerName];
  }
  
  /// ユーザーのプロバイダーを取得
  AuthProvider? getProviderForUser(String userId) {
    // 実際の実装ではユーザーIDからプロバイダーを特定する
    // ここでは簡略化のためにメール/パスワードプロバイダーを返す
    return _providers['email_password'];
  }
  
  /// 現在のユーザーを取得
  UserModel? getCurrentUser() {
    final state = _authStateNotifier.authState;
    return state.isAuthenticated ? state.user : null;
  }
  
  /// 認証状態の変更を監視
  Stream<AuthState> authStateChanges() {
    return _authStateNotifier.authStateChanges;
  }
  
  /// ユーザー名が利用可能かどうかを確認
  Future<bool> isUsernameAvailable(String username) async {
    // 実際の実装ではAPIリクエストを送信
    // ここではモックデータを返す
    await Future.delayed(Duration(milliseconds: 500));
    
    // 特定のユーザー名は既に使用されているとする
    final unavailableUsernames = ['admin', 'root', 'system', 'test'];
    return !unavailableUsernames.contains(username.toLowerCase());
  }
  
  /// パスワードを更新
  Future<void> updatePassword(String newPassword) async {
    // 実際の実装ではAPIリクエストを送信
    await Future.delayed(Duration(milliseconds: 500));
  }
  
  /// ユーザープロファイルを更新
  Future<UserModel> updateUserProfile({
    String? username,
    String? displayName,
    String? profileImageUrl,
    String? bannerImageUrl,
    String? bio,
  }) async {
    // 実際の実装ではAPIリクエストを送信
    // ここではモックデータを返す
    await Future.delayed(Duration(milliseconds: 500));
    
    final currentUser = getCurrentUser();
    if (currentUser == null) {
      throw AuthError(
        code: AuthErrorCode.userNotFound,
        message: 'ユーザーがサインインしていません',
      );
    }
    
    return currentUser.copyWith(
      username: username,
      displayName: displayName,
      profileImageUrl: profileImageUrl,
      bannerImageUrl: bannerImageUrl,
      bio: bio,
    );
  }
  
  /// 現在のセッションを取得
  Future<SessionInfo?> getCurrentSession() async {
    // 実際の実装ではAPIリクエストを送信
    // ここではモックデータを返す
    await Future.delayed(Duration(milliseconds: 500));
    
    final currentUser = getCurrentUser();
    if (currentUser == null) {
      return null;
    }
    
    return SessionInfo(
      id: 'session123',
      userId: currentUser.id,
      deviceInfo: await DeviceInfo.getCurrent(),
      lastAccessedAt: DateTime.now(),
      createdAt: DateTime.now().subtract(Duration(days: 1)),
      ipAddress: '192.168.1.1',
    );
  }
  
  /// 全てのセッションを取得
  Future<List<SessionInfo>> getAllSessions(String userId) async {
    // 実際の実装ではAPIリクエストを送信
    // ここではモックデータを返す
    await Future.delayed(Duration(milliseconds: 500));
    
    final currentSession = await getCurrentSession();
    if (currentSession == null) {
      return [];
    }
    
    // 現在のセッションと他の2つのセッションを返す
    return [
      currentSession,
      SessionInfo(
        id: 'session456',
        userId: userId,
        deviceInfo: DeviceInfo(
          name: 'iPhone 12',
          type: 'mobile',
          osVersion: 'iOS 15.0',
          appVersion: '1.0.0',
        ),
        lastAccessedAt: DateTime.now().subtract(Duration(hours: 2)),
        createdAt: DateTime.now().subtract(Duration(days: 5)),
        ipAddress: '203.0.113.1',
      ),
      SessionInfo(
        id: 'session789',
        userId: userId,
        deviceInfo: DeviceInfo(
          name: 'MacBook Pro',
          type: 'desktop',
          osVersion: 'macOS 12.0',
          appVersion: '1.0.0',
        ),
        lastAccessedAt: DateTime.now().subtract(Duration(days: 1)),
        createdAt: DateTime.now().subtract(Duration(days: 10)),
        ipAddress: '198.51.100.1',
      ),
    ];
  }
  
  /// セッションを終了
  Future<void> terminateSession(String sessionId) async {
    // 実際の実装ではAPIリクエストを送信
    await Future.delayed(Duration(milliseconds: 500));
  }
  
  /// 他のセッションを全て終了
  Future<void> terminateOtherSessions(String currentSessionId) async {
    // 実際の実装ではAPIリクエストを送信
    await Future.delayed(Duration(milliseconds: 500));
  }
}

/// セッション情報クラス
class SessionInfo {
  /// セッションID
  final String id;
  
  /// ユーザーID
  final String userId;
  
  /// デバイス情報
  final DeviceInfo deviceInfo;
  
  /// 最終アクセス日時
  final DateTime lastAccessedAt;
  
  /// 作成日時
  final DateTime createdAt;
  
  /// IPアドレス
  final String ipAddress;
  
  /// コンストラクタ
  SessionInfo({
    required this.id,
    required this.userId,
    required this.deviceInfo,
    required this.lastAccessedAt,
    required this.createdAt,
    required this.ipAddress,
  });
  
  /// JSONからインスタンスを生成
  factory SessionInfo.fromJson(Map<String, dynamic> json) {
    return SessionInfo(
      id: json['id'],
      userId: json['user_id'],
      deviceInfo: DeviceInfo.fromJson(json['device_info']),
      lastAccessedAt: DateTime.parse(json['last_accessed_at']),
      createdAt: DateTime.parse(json['created_at']),
      ipAddress: json['ip_address'],
    );
  }
  
  /// インスタンスからJSONを生成
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'device_info': deviceInfo.toJson(),
      'last_accessed_at': lastAccessedAt.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'ip_address': ipAddress,
    };
  }
}

/// デバイス情報クラス
class DeviceInfo {
  /// デバイス名
  final String name;
  
  /// デバイスタイプ
  final String type;
  
  /// OSバージョン
  final String osVersion;
  
  /// アプリバージョン
  final String appVersion;
  
  /// コンストラクタ
  DeviceInfo({
    required this.name,
    required this.type,
    required this.osVersion,
    required this.appVersion,
  });
  
  /// 現在のデバイス情報を取得
  static Future<DeviceInfo> getCurrent() async {
    // デバイス情報取得ロジック
    // 実際の実装ではdevice_infoパッケージなどを使用
    return DeviceInfo(
      name: 'Unknown Device',
      type: 'Unknown',
      osVersion: 'Unknown',
      appVersion: 'Unknown',
    );
  }
  
  /// JSONからインスタンスを生成
  factory DeviceInfo.fromJson(Map<String, dynamic> json) {
    return DeviceInfo(
      name: json['name'],
      type: json['type'],
      osVersion: json['os_version'],
      appVersion: json['app_version'],
    );
  }
  
  /// インスタンスからJSONを生成
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type,
      'os_version': osVersion,
      'app_version': appVersion,
    };
  }
}
