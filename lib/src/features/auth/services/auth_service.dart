import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../../../src/core/errors/app_exceptions.dart';
import '../../../../src/core/logging/logger.dart';
import '../../../../src/core/cache/cache_manager.dart';
import '../models/auth_models.dart';
import '../providers/auth_provider.dart';
import '../validators/validator_factory.dart';
import '../errors/auth_errors.dart';
import '../session/session_manager.dart';

/// 認証サービスクラス（改善版）
class AuthService {
  /// 認証リポジトリ
  final AuthRepository _authRepository;
  
  /// トークンマネージャー
  final TokenManager _tokenManager;
  
  /// セッションマネージャー
  final SessionManager _sessionManager;
  
  /// バリデーターファクトリー
  final ValidatorFactory _validatorFactory;
  
  /// ロガー
  final Logger _logger;
  
  /// 現在のユーザー
  UserModel? _currentUser;
  
  /// 認証状態のコントローラー
  final _authStateController = StreamController<UserModel?>.broadcast();
  
  /// コンストラクタ
  AuthService({
    required AuthRepository authRepository,
    required TokenManager tokenManager,
    required SessionManager sessionManager,
    required ValidatorFactory validatorFactory,
    Logger? logger,
  }) : _authRepository = authRepository,
       _tokenManager = tokenManager,
       _sessionManager = sessionManager,
       _validatorFactory = validatorFactory,
       _logger = logger ?? Logger() {
    // 初期化時に現在のユーザーを取得
    _initCurrentUser();
    
    // 認証状態の変更を監視
    _authRepository.authStateChanges().listen((state) {
      _currentUser = state.user;
      _authStateController.add(_currentUser);
    });
  }
  
  /// 初期化時に現在のユーザーを取得
  Future<void> _initCurrentUser() async {
    try {
      _currentUser = _authRepository.getCurrentUser();
      _authStateController.add(_currentUser);
    } catch (e) {
      _logger.error('Failed to initialize current user', e);
      _currentUser = null;
      _authStateController.add(null);
    }
  }
  
  /// メールアドレスとパスワードでサインアップ
  Future<UserModel> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String username,
    required String displayName,
  }) async {
    try {
      _logger.info('Attempting to sign up user with email: $email');
      
      // 非同期バリデーション
      final validationResults = await Future.wait([
        _validatorFactory.getEmailValidator().validate(email),
        _validatorFactory.getPasswordValidator().validate(password),
        _validatorFactory.getUsernameValidator().validate(username),
      ]);
      
      // バリデーションエラーがあればスロー
      for (final result in validationResults) {
        if (!result.isValid) {
          throw ValidationException(result.errorMessage!);
        }
      }
      
      // プロバイダーを取得
      final provider = _authRepository.getProvider('email_password') as EmailPasswordAuthProvider;
      
      // サインアップ
      final authResult = await provider.signUp(
        email: email,
        password: password,
        username: username,
        displayName: displayName,
      );
      
      // トークンを保存
      if (authResult.token != null) {
        await _tokenManager.saveToken(authResult.user.id, authResult.token!);
      }
      
      // 現在のユーザーを更新
      _currentUser = authResult.user;
      _authStateController.add(_currentUser);
      
      _logger.info('User signed up successfully: ${authResult.user.id}');
      
      return authResult.user;
    } catch (e) {
      _logger.error('Sign up failed', e);
      
      // エラーハンドリング
      if (e is ValidationException) {
        rethrow;
      }
      
      final authError = AuthErrorHandler.handleSupabaseError(e);
      throw authError;
    }
  }
  
  /// メールアドレスとパスワードでサインイン
  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      _logger.info('Attempting to sign in user with email: $email');
      
      // プロバイダーを取得
      final provider = _authRepository.getProvider('email_password');
      
      // サインイン
      final authResult = await provider.signIn({
        'email': email,
        'password': password,
      });
      
      // トークンを保存
      if (authResult.token != null) {
        await _tokenManager.saveToken(authResult.user.id, authResult.token!);
      }
      
      // 現在のユーザーを更新
      _currentUser = authResult.user;
      _authStateController.add(_currentUser);
      
      _logger.info('User signed in successfully: ${authResult.user.id}');
      
      return authResult.user;
    } catch (e) {
      _logger.error('Sign in failed', e);
      
      // エラーハンドリング
      final authError = AuthErrorHandler.handleSupabaseError(e);
      throw authError;
    }
  }
  
  /// ソーシャル認証でサインイン
  Future<UserModel> signInWithSocialProvider(String providerName) async {
    try {
      _logger.info('Attempting to sign in user with provider: $providerName');
      
      // プロバイダーを取得
      final provider = _authRepository.getProvider(providerName);
      
      // サインイン
      final authResult = await provider.signIn();
      
      // トークンを保存
      if (authResult.token != null) {
        await _tokenManager.saveToken(authResult.user.id, authResult.token!);
      }
      
      // 現在のユーザーを更新
      _currentUser = authResult.user;
      _authStateController.add(_currentUser);
      
      _logger.info('User signed in successfully with $providerName: ${authResult.user.id}');
      
      return authResult.user;
    } catch (e) {
      _logger.error('Social sign in failed with provider: $providerName', e);
      
      // エラーハンドリング
      final authError = AuthErrorHandler.handleSupabaseError(e);
      throw authError;
    }
  }
  
  /// サインアウト
  Future<void> signOut() async {
    try {
      _logger.info('Attempting to sign out user');
      
      if (_currentUser == null) {
        _logger.info('No user is currently signed in');
        return;
      }
      
      // 現在のプロバイダーを取得
      final provider = _authRepository.getProviderForUser(_currentUser!.id);
      if (provider == null) {
        _logger.warning('No provider found for user: ${_currentUser!.id}');
        return;
      }
      
      // サインアウト
      await provider.signOut();
      
      // トークンを削除
      await _tokenManager.deleteToken(_currentUser!.id);
      
      // 現在のユーザーをクリア
      final userId = _currentUser!.id;
      _currentUser = null;
      _authStateController.add(null);
      
      _logger.info('User signed out successfully: $userId');
    } catch (e) {
      _logger.error('Sign out failed', e);
      rethrow;
    }
  }
  
  /// 現在のユーザーを取得
  UserModel? getCurrentUser() {
    return _currentUser;
  }
  
  /// 認証状態の変更を監視
  Stream<UserModel?> authStateChanges() {
    return _authStateController.stream;
  }
  
  /// パスワードリセットメールを送信
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      _logger.info('Sending password reset email to: $email');
      
      // メールバリデーション
      final validationResult = await _validatorFactory.getEmailValidator().validate(email);
      if (!validationResult.isValid) {
        throw ValidationException(validationResult.errorMessage!);
      }
      
      // プロバイダーを取得
      final provider = _authRepository.getProvider('email_password') as EmailPasswordAuthProvider;
      
      // パスワードリセットメールを送信
      await provider.sendPasswordResetEmail(email);
      
      _logger.info('Password reset email sent successfully to: $email');
    } catch (e) {
      _logger.error('Failed to send password reset email', e);
      
      // エラーハンドリング
      if (e is ValidationException) {
        rethrow;
      }
      
      final authError = AuthErrorHandler.handleSupabaseError(e);
      throw authError;
    }
  }
  
  /// パスワードを更新
  Future<void> updatePassword(String newPassword) async {
    try {
      _logger.info('Attempting to update password');
      
      if (_currentUser == null) {
        throw AuthError(
          code: AuthErrorCode.userNotFound,
          message: 'ユーザーがサインインしていません',
        );
      }
      
      // パスワードバリデーション
      final validationResult = await _validatorFactory.getPasswordValidator().validate(newPassword);
      if (!validationResult.isValid) {
        throw ValidationException(validationResult.errorMessage!);
      }
      
      // パスワード更新
      await _authRepository.updatePassword(newPassword);
      
      _logger.info('Password updated successfully');
    } catch (e) {
      _logger.error('Failed to update password', e);
      
      // エラーハンドリング
      if (e is ValidationException) {
        rethrow;
      }
      
      if (e is AuthError) {
        rethrow;
      }
      
      final authError = AuthErrorHandler.handleSupabaseError(e);
      throw authError;
    }
  }
  
  /// ユーザープロファイルを更新
  Future<UserModel> updateUserProfile({
    String? username,
    String? displayName,
    String? profileImageUrl,
    String? bannerImageUrl,
    String? bio,
  }) async {
    try {
      _logger.info('Attempting to update user profile');
      
      if (_currentUser == null) {
        throw AuthError(
          code: AuthErrorCode.userNotFound,
          message: 'ユーザーがサインインしていません',
        );
      }
      
      // ユーザー名バリデーション（指定されている場合）
      if (username != null) {
        final validationResult = await _validatorFactory.getUsernameValidator().validate(username);
        if (!validationResult.isValid) {
          throw ValidationException(validationResult.errorMessage!);
        }
      }
      
      // プロファイル更新
      final updatedUser = await _authRepository.updateUserProfile(
        username: username,
        displayName: displayName,
        profileImageUrl: profileImageUrl,
        bannerImageUrl: bannerImageUrl,
        bio: bio,
      );
      
      // 現在のユーザーを更新
      _currentUser = updatedUser;
      _authStateController.add(_currentUser);
      
      _logger.info('User profile updated successfully');
      
      return updatedUser;
    } catch (e) {
      _logger.error('Failed to update user profile', e);
      
      // エラーハンドリング
      if (e is ValidationException) {
        rethrow;
      }
      
      if (e is AuthError) {
        rethrow;
      }
      
      final authError = AuthErrorHandler.handleSupabaseError(e);
      throw authError;
    }
  }
  
  /// セッション管理
  
  /// 現在のセッションを取得
  Future<SessionInfo?> getCurrentSession() {
    return _sessionManager.getCurrentSession();
  }
  
  /// 全てのセッションを取得
  Future<List<SessionInfo>> getAllSessions() async {
    if (_currentUser == null) {
      return [];
    }
    
    return _sessionManager.getAllSessions(_currentUser!.id);
  }
  
  /// セッションを終了
  Future<bool> terminateSession(String sessionId) {
    return _sessionManager.terminateSession(sessionId);
  }
  
  /// 他のセッションを全て終了
  Future<bool> terminateOtherSessions() {
    return _sessionManager.terminateOtherSessions();
  }
  
  /// セッションを更新
  Future<bool> refreshSession() {
    return _sessionManager.refreshSession();
  }
  
  /// リソース解放
  void dispose() {
    _authStateController.close();
  }
}
