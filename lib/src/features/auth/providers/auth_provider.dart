import 'package:flutter/foundation.dart';
import '../errors/auth_errors.dart';

/// 認証プロバイダーインターフェース
abstract class AuthProvider {
  /// プロバイダー名
  String get providerName;
  
  /// サインイン
  Future<AuthResult> signIn([Map<String, dynamic>? params]);
  
  /// サインアウト
  Future<void> signOut();
  
  /// 認証状態の変更を監視
  Stream<AuthState> authStateChanges();
  
  /// トークンの更新
  Future<AuthToken> refreshToken(AuthToken token);
  
  /// トークンの検証
  Future<bool> validateToken(AuthToken token);
}

/// メール/パスワード認証プロバイダー
class EmailPasswordAuthProvider implements AuthProvider {
  final AuthApiClient _authApiClient;
  final AuthStateNotifier _authStateNotifier;
  
  EmailPasswordAuthProvider(this._authApiClient, this._authStateNotifier);
  
  @override
  String get providerName => 'email_password';
  
  @override
  Future<AuthResult> signIn([Map<String, dynamic>? params]) async {
    final email = params?['email'] as String?;
    final password = params?['password'] as String?;
    
    if (email == null || password == null) {
      throw ValidationException('メールアドレスとパスワードは必須です');
    }
    
    try {
      final response = await _authApiClient.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final user = UserModel.fromJson(response['user']);
      final token = AuthToken.fromJson(response['token']);
      
      // 認証状態を更新
      _authStateNotifier.updateAuthState(AuthState(
        isAuthenticated: true,
        user: user,
      ));
      
      return AuthResult(
        user: user,
        token: token,
      );
    } catch (e) {
      throw AuthErrorHandler.handleApiError(e);
    }
  }
  
  @override
  Future<void> signOut() async {
    try {
      await _authApiClient.signOut();
      
      // 認証状態を更新
      _authStateNotifier.updateAuthState(AuthState(
        isAuthenticated: false,
        user: null,
      ));
    } catch (e) {
      throw AuthErrorHandler.handleApiError(e);
    }
  }
  
  @override
  Stream<AuthState> authStateChanges() {
    return _authStateNotifier.authStateChanges;
  }
  
  @override
  Future<AuthToken> refreshToken(AuthToken token) async {
    try {
      final response = await _authApiClient.refreshToken(
        refreshToken: token.refreshToken,
      );
      
      return AuthToken.fromJson(response);
    } catch (e) {
      throw AuthErrorHandler.handleApiError(e);
    }
  }
  
  @override
  Future<bool> validateToken(AuthToken token) async {
    try {
      final response = await _authApiClient.validateToken(
        accessToken: token.accessToken,
      );
      
      return response['valid'] as bool;
    } catch (e) {
      return false;
    }
  }
  
  /// メールアドレスとパスワードでサインアップ
  Future<AuthResult> signUp({
    required String email,
    required String password,
    required String username,
    required String displayName,
  }) async {
    try {
      final response = await _authApiClient.signUpWithEmailAndPassword(
        email: email,
        password: password,
        username: username,
        displayName: displayName,
      );
      
      final user = UserModel.fromJson(response['user']);
      final token = AuthToken.fromJson(response['token']);
      
      // 認証状態を更新
      _authStateNotifier.updateAuthState(AuthState(
        isAuthenticated: true,
        user: user,
      ));
      
      return AuthResult(
        user: user,
        token: token,
      );
    } catch (e) {
      throw AuthErrorHandler.handleApiError(e);
    }
  }
  
  /// パスワードリセットメールを送信
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _authApiClient.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw AuthErrorHandler.handleApiError(e);
    }
  }
}

/// Google認証プロバイダー
class GoogleAuthProvider implements AuthProvider {
  final AuthApiClient _authApiClient;
  final AuthStateNotifier _authStateNotifier;
  
  GoogleAuthProvider(this._authApiClient, this._authStateNotifier);
  
  @override
  String get providerName => 'google';
  
  @override
  Future<AuthResult> signIn([Map<String, dynamic>? params]) async {
    try {
      final response = await _authApiClient.signInWithGoogle();
      
      final user = UserModel.fromJson(response['user']);
      final token = AuthToken.fromJson(response['token']);
      
      // 認証状態を更新
      _authStateNotifier.updateAuthState(AuthState(
        isAuthenticated: true,
        user: user,
      ));
      
      return AuthResult(
        user: user,
        token: token,
      );
    } catch (e) {
      throw AuthErrorHandler.handleApiError(e);
    }
  }
  
  @override
  Future<void> signOut() async {
    try {
      await _authApiClient.signOut();
      
      // 認証状態を更新
      _authStateNotifier.updateAuthState(AuthState(
        isAuthenticated: false,
        user: null,
      ));
    } catch (e) {
      throw AuthErrorHandler.handleApiError(e);
    }
  }
  
  @override
  Stream<AuthState> authStateChanges() {
    return _authStateNotifier.authStateChanges;
  }
  
  @override
  Future<AuthToken> refreshToken(AuthToken token) async {
    try {
      final response = await _authApiClient.refreshToken(
        refreshToken: token.refreshToken,
      );
      
      return AuthToken.fromJson(response);
    } catch (e) {
      throw AuthErrorHandler.handleApiError(e);
    }
  }
  
  @override
  Future<bool> validateToken(AuthToken token) async {
    try {
      final response = await _authApiClient.validateToken(
        accessToken: token.accessToken,
      );
      
      return response['valid'] as bool;
    } catch (e) {
      return false;
    }
  }
}

/// Apple認証プロバイダー
class AppleAuthProvider implements AuthProvider {
  final AuthApiClient _authApiClient;
  final AuthStateNotifier _authStateNotifier;
  
  AppleAuthProvider(this._authApiClient, this._authStateNotifier);
  
  @override
  String get providerName => 'apple';
  
  @override
  Future<AuthResult> signIn([Map<String, dynamic>? params]) async {
    try {
      final response = await _authApiClient.signInWithApple();
      
      final user = UserModel.fromJson(response['user']);
      final token = AuthToken.fromJson(response['token']);
      
      // 認証状態を更新
      _authStateNotifier.updateAuthState(AuthState(
        isAuthenticated: true,
        user: user,
      ));
      
      return AuthResult(
        user: user,
        token: token,
      );
    } catch (e) {
      throw AuthErrorHandler.handleApiError(e);
    }
  }
  
  @override
  Future<void> signOut() async {
    try {
      await _authApiClient.signOut();
      
      // 認証状態を更新
      _authStateNotifier.updateAuthState(AuthState(
        isAuthenticated: false,
        user: null,
      ));
    } catch (e) {
      throw AuthErrorHandler.handleApiError(e);
    }
  }
  
  @override
  Stream<AuthState> authStateChanges() {
    return _authStateNotifier.authStateChanges;
  }
  
  @override
  Future<AuthToken> refreshToken(AuthToken token) async {
    try {
      final response = await _authApiClient.refreshToken(
        refreshToken: token.refreshToken,
      );
      
      return AuthToken.fromJson(response);
    } catch (e) {
      throw AuthErrorHandler.handleApiError(e);
    }
  }
  
  @override
  Future<bool> validateToken(AuthToken token) async {
    try {
      final response = await _authApiClient.validateToken(
        accessToken: token.accessToken,
      );
      
      return response['valid'] as bool;
    } catch (e) {
      return false;
    }
  }
}

/// Twitter認証プロバイダー
class TwitterAuthProvider implements AuthProvider {
  final AuthApiClient _authApiClient;
  final AuthStateNotifier _authStateNotifier;
  
  TwitterAuthProvider(this._authApiClient, this._authStateNotifier);
  
  @override
  String get providerName => 'twitter';
  
  @override
  Future<AuthResult> signIn([Map<String, dynamic>? params]) async {
    try {
      final response = await _authApiClient.signInWithTwitter();
      
      final user = UserModel.fromJson(response['user']);
      final token = AuthToken.fromJson(response['token']);
      
      // 認証状態を更新
      _authStateNotifier.updateAuthState(AuthState(
        isAuthenticated: true,
        user: user,
      ));
      
      return AuthResult(
        user: user,
        token: token,
      );
    } catch (e) {
      throw AuthErrorHandler.handleApiError(e);
    }
  }
  
  @override
  Future<void> signOut() async {
    try {
      await _authApiClient.signOut();
      
      // 認証状態を更新
      _authStateNotifier.updateAuthState(AuthState(
        isAuthenticated: false,
        user: null,
      ));
    } catch (e) {
      throw AuthErrorHandler.handleApiError(e);
    }
  }
  
  @override
  Stream<AuthState> authStateChanges() {
    return _authStateNotifier.authStateChanges;
  }
  
  @override
  Future<AuthToken> refreshToken(AuthToken token) async {
    try {
      final response = await _authApiClient.refreshToken(
        refreshToken: token.refreshToken,
      );
      
      return AuthToken.fromJson(response);
    } catch (e) {
      throw AuthErrorHandler.handleApiError(e);
    }
  }
  
  @override
  Future<bool> validateToken(AuthToken token) async {
    try {
      final response = await _authApiClient.validateToken(
        accessToken: token.accessToken,
      );
      
      return response['valid'] as bool;
    } catch (e) {
      return false;
    }
  }
}

/// Instagram認証プロバイダー
class InstagramAuthProvider implements AuthProvider {
  final AuthApiClient _authApiClient;
  final AuthStateNotifier _authStateNotifier;
  
  InstagramAuthProvider(this._authApiClient, this._authStateNotifier);
  
  @override
  String get providerName => 'instagram';
  
  @override
  Future<AuthResult> signIn([Map<String, dynamic>? params]) async {
    try {
      final response = await _authApiClient.signInWithInstagram();
      
      final user = UserModel.fromJson(response['user']);
      final token = AuthToken.fromJson(response['token']);
      
      // 認証状態を更新
      _authStateNotifier.updateAuthState(AuthState(
        isAuthenticated: true,
        user: user,
      ));
      
      return AuthResult(
        user: user,
        token: token,
      );
    } catch (e) {
      throw AuthErrorHandler.handleApiError(e);
    }
  }
  
  @override
  Future<void> signOut() async {
    try {
      await _authApiClient.signOut();
      
      // 認証状態を更新
      _authStateNotifier.updateAuthState(AuthState(
        isAuthenticated: false,
        user: null,
      ));
    } catch (e) {
      throw AuthErrorHandler.handleApiError(e);
    }
  }
  
  @override
  Stream<AuthState> authStateChanges() {
    return _authStateNotifier.authStateChanges;
  }
  
  @override
  Future<AuthToken> refreshToken(AuthToken token) async {
    try {
      final response = await _authApiClient.refreshToken(
        refreshToken: token.refreshToken,
      );
      
      return AuthToken.fromJson(response);
    } catch (e) {
      throw AuthErrorHandler.handleApiError(e);
    }
  }
  
  @override
  Future<bool> validateToken(AuthToken token) async {
    try {
      final response = await _authApiClient.validateToken(
        accessToken: token.accessToken,
      );
      
      return response['valid'] as bool;
    } catch (e) {
      return false;
    }
  }
}

/// 認証状態通知クラス
class AuthStateNotifier extends ChangeNotifier {
  /// 認証状態
  AuthState _authState = AuthState(
    isAuthenticated: false,
    user: null,
  );
  
  /// 認証状態のコントローラー
  final _authStateController = StreamController<AuthState>.broadcast();
  
  /// 認証状態の変更を監視
  Stream<AuthState> get authStateChanges => _authStateController.stream;
  
  /// 認証状態を取得
  AuthState get authState => _authState;
  
  /// 認証状態を更新
  void updateAuthState(AuthState state) {
    _authState = state;
    _authStateController.add(state);
    notifyListeners();
  }
  
  /// リソース解放
  @override
  void dispose() {
    _authStateController.close();
    super.dispose();
  }
}

/// 認証API クライアント
class AuthApiClient {
  final String _baseUrl;
  final Map<String, String> _headers;
  
  AuthApiClient({
    required String baseUrl,
    Map<String, String>? headers,
  }) : _baseUrl = baseUrl,
       _headers = headers ?? {'Content-Type': 'application/json'};
  
  /// メールアドレスとパスワードでサインイン
  Future<Map<String, dynamic>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    // 実際の実装ではHTTPリクエストを送信
    // ここではモックデータを返す
    await Future.delayed(Duration(milliseconds: 500));
    
    return {
      'user': {
        'id': 'user123',
        'email': email,
        'username': 'user123',
        'display_name': 'User 123',
        'created_at': DateTime.now().toIso8601String(),
      },
      'token': {
        'access_token': 'mock_access_token',
        'refresh_token': 'mock_refresh_token',
        'token_type': 'Bearer',
        'expires_at': DateTime.now().add(Duration(hours: 1)).toIso8601String(),
        'provider': 'email_password',
      },
    };
  }
  
  /// メールアドレスとパスワードでサインアップ
  Future<Map<String, dynamic>> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String username,
    required String displayName,
  }) async {
    // 実際の実装ではHTTPリクエストを送信
    // ここではモックデータを返す
    await Future.delayed(Duration(milliseconds: 500));
    
    return {
      'user': {
        'id': 'user123',
        'email': email,
        'username': username,
        'display_name': displayName,
        'created_at': DateTime.now().toIso8601String(),
      },
      'token': {
        'access_token': 'mock_access_token',
        'refresh_token': 'mock_refresh_token',
        'token_type': 'Bearer',
        'expires_at': DateTime.now().add(Duration(hours: 1)).toIso8601String(),
        'provider': 'email_password',
      },
    };
  }
  
  /// Googleでサインイン
  Future<Map<String, dynamic>> signInWithGoogle() async {
    // 実際の実装ではHTTPリクエストを送信
    // ここではモックデータを返す
    await Future.delayed(Duration(milliseconds: 500));
    
    return {
      'user': {
        'id': 'user456',
        'email': 'user@gmail.com',
        'username': 'user456',
        'display_name': 'User 456',
        'created_at': DateTime.now().toIso8601String(),
      },
      'token': {
        'access_token': 'mock_access_token',
        'refresh_token': 'mock_refresh_token',
        'token_type': 'Bearer',
        'expires_at': DateTime.now().add(Duration(hours: 1)).toIso8601String(),
        'provider': 'google',
      },
    };
  }
  
  /// Appleでサインイン
  Future<Map<String, dynamic>> signInWithApple() async {
    // 実際の実装ではHTTPリクエストを送信
    // ここではモックデータを返す
    await Future.delayed(Duration(milliseconds: 500));
    
    return {
      'user': {
        'id': 'user789',
        'email': 'user@icloud.com',
        'username': 'user789',
        'display_name': 'User 789',
        'created_at': DateTime.now().toIso8601String(),
      },
      'token': {
        'access_token': 'mock_access_token',
        'refresh_token': 'mock_refresh_token',
        'token_type': 'Bearer',
        'expires_at': DateTime.now().add(Duration(hours: 1)).toIso8601String(),
        'provider': 'apple',
      },
    };
  }
  
  /// Twitterでサインイン
  Future<Map<String, dynamic>> signInWithTwitter() async {
    // 実際の実装ではHTTPリクエストを送信
    // ここではモックデータを返す
    await Future.delayed(Duration(milliseconds: 500));
    
    return {
      'user': {
        'id': 'user101112',
        'email': 'user@twitter.com',
        'username': 'user101112',
        'display_name': 'User 101112',
        'created_at': DateTime.now().toIso8601String(),
      },
      'token': {
        'access_token': 'mock_access_token',
        'refresh_token': 'mock_refresh_token',
        'token_type': 'Bearer',
        'expires_at': DateTime.now().add(Duration(hours: 1)).toIso8601String(),
        'provider': 'twitter',
      },
    };
  }
  
  /// Instagramでサインイン
  Future<Map<String, dynamic>> signInWithInstagram() async {
    // 実際の実装ではHTTPリクエストを送信
    // ここではモックデータを返す
    await Future.delayed(Duration(milliseconds: 500));
    
    return {
      'user': {
        'id': 'user131415',
        'email': 'user@instagram.com',
        'username': 'user131415',
        'display_name': 'User 131415',
        'created_at': DateTime.now().toIso8601String(),
      },
      'token': {
        'access_token': 'mock_access_token',
        'refresh_token': 'mock_refresh_token',
        'token_type': 'Bearer',
        'expires_at': DateTime.now().add(Duration(hours: 1)).toIso8601String(),
        'provider': 'instagram',
      },
    };
  }
  
  /// サインアウト
  Future<void> signOut() async {
    // 実際の実装ではHTTPリクエストを送信
    await Future.delayed(Duration(milliseconds: 500));
  }
  
  /// トークンを更新
  Future<Map<String, dynamic>> refreshToken({
    required String? refreshToken,
  }) async {
    // 実際の実装ではHTTPリクエストを送信
    // ここではモックデータを返す
    await Future.delayed(Duration(milliseconds: 500));
    
    return {
      'access_token': 'new_mock_access_token',
      'refresh_token': refreshToken,
      'token_type': 'Bearer',
      'expires_at': DateTime.now().add(Duration(hours: 1)).toIso8601String(),
      'provider': 'email_password',
    };
  }
  
  /// トークンを検証
  Future<Map<String, dynamic>> validateToken({
    required String accessToken,
  }) async {
    // 実際の実装ではHTTPリクエストを送信
    // ここではモックデータを返す
    await Future.delayed(Duration(milliseconds: 500));
    
    return {
      'valid': true,
    };
  }
  
  /// パスワードリセットメールを送信
  Future<void> sendPasswordResetEmail({
    required String email,
  }) async {
    // 実際の実装ではHTTPリクエストを送信
    await Future.delayed(Duration(milliseconds: 500));
  }
}

/// 認証結果クラス
class AuthResult {
  final UserModel user;
  final AuthToken? token;
  
  AuthResult({
    required this.user,
    this.token,
  });
}

/// 認証状態クラス
class AuthState {
  final bool isAuthenticated;
  final UserModel? user;
  
  AuthState({
    required this.isAuthenticated,
    this.user,
  });
}

/// ユーザーモデルクラス
class UserModel {
  final String id;
  final String email;
  final String username;
  final String displayName;
  final DateTime createdAt;
  final String? profileImageUrl;
  final String? bannerImageUrl;
  final String? bio;
  
  UserModel({
    required this.id,
    required this.email,
    required this.username,
    required this.displayName,
    required this.createdAt,
    this.profileImageUrl,
    this.bannerImageUrl,
    this.bio,
  });
  
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      username: json['username'],
      displayName: json['display_name'],
      createdAt: DateTime.parse(json['created_at']),
      profileImageUrl: json['profile_image_url'],
      bannerImageUrl: json['banner_image_url'],
      bio: json['bio'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'display_name': displayName,
      'created_at': createdAt.toIso8601String(),
      'profile_image_url': profileImageUrl,
      'banner_image_url': bannerImageUrl,
      'bio': bio,
    };
  }
  
  UserModel copyWith({
    String? id,
    String? email,
    String? username,
    String? displayName,
    DateTime? createdAt,
    String? profileImageUrl,
    String? bannerImageUrl,
    String? bio,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      createdAt: createdAt ?? this.createdAt,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      bannerImageUrl: bannerImageUrl ?? this.bannerImageUrl,
      bio: bio ?? this.bio,
    );
  }
}

/// 認証トークンクラス
class AuthToken {
  final String accessToken;
  final String? refreshToken;
  final String tokenType;
  final DateTime expiresAt;
  final String provider;
  
  AuthToken({
    required this.accessToken,
    this.refreshToken,
    required this.tokenType,
    required this.expiresAt,
    required this.provider,
  });
  
  bool get isExpired => DateTime.now().isAfter(expiresAt);
  
  bool get isExpiringSoon => DateTime.now().isAfter(expiresAt.subtract(Duration(minutes: 5)));
  
  factory AuthToken.fromJson(Map<String, dynamic> json) {
    return AuthToken(
      accessToken: json['access_token'],
      refreshToken: json['refresh_token'],
      tokenType: json['token_type'] ?? 'Bearer',
      expiresAt: DateTime.parse(json['expires_at']),
      provider: json['provider'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'token_type': tokenType,
      'expires_at': expiresAt.toIso8601String(),
      'provider': provider,
    };
  }
}

/// バリデーション例外
class ValidationException implements Exception {
  final String message;
  
  ValidationException(this.message);
  
  @override
  String toString() => message;
}
