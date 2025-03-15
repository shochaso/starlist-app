import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/services/auth_service.dart';
import '../../../shared/models/user_model.dart';

/// 認証状態クラス
/// 
/// アプリケーションの認証状態を管理します。
class AuthState {
  /// 認証状態
  final AuthStatus status;
  
  /// 現在のユーザー
  final UserModel? user;
  
  /// エラーメッセージ
  final String? errorMessage;
  
  /// 読み込み中かどうか
  final bool isLoading;

  /// コンストラクタ
  const AuthState({
    this.status = AuthStatus.unauthenticated,
    this.user,
    this.errorMessage,
    this.isLoading = false,
  });

  /// 初期状態を作成
  factory AuthState.initial() {
    return const AuthState(
      status: AuthStatus.initial,
      user: null,
      errorMessage: null,
      isLoading: false,
    );
  }

  /// 認証済み状態を作成
  factory AuthState.authenticated(UserModel user) {
    return AuthState(
      status: AuthStatus.authenticated,
      user: user,
      errorMessage: null,
      isLoading: false,
    );
  }

  /// 未認証状態を作成
  factory AuthState.unauthenticated() {
    return const AuthState(
      status: AuthStatus.unauthenticated,
      user: null,
      errorMessage: null,
      isLoading: false,
    );
  }

  /// エラー状態を作成
  factory AuthState.error(String message) {
    return AuthState(
      status: AuthStatus.error,
      user: null,
      errorMessage: message,
      isLoading: false,
    );
  }

  /// 読み込み中状態を作成
  factory AuthState.loading() {
    return const AuthState(
      status: AuthStatus.loading,
      user: null,
      errorMessage: null,
      isLoading: true,
    );
  }

  /// 新しい状態をコピーして作成
  AuthState copyWith({
    AuthStatus? status,
    UserModel? user,
    String? errorMessage,
    bool? isLoading,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  /// エラーメッセージをクリア
  AuthState clearError() {
    return copyWith(
      errorMessage: null,
    );
  }

  /// 読み込み中状態に更新
  AuthState toLoading() {
    return copyWith(
      status: AuthStatus.loading,
      isLoading: true,
      errorMessage: null,
    );
  }

  /// ユーザーがスターかどうかを確認
  bool get isStar => user?.userType == UserType.star;

  /// ユーザーが管理者かどうかを確認
  bool get isAdmin => user?.userType == UserType.admin;

  /// ユーザーが認証済みかどうかを確認
  bool get isAuthenticated => status == AuthStatus.authenticated && user != null;

  /// ユーザーが認証されていないかどうかを確認
  bool get isUnauthenticated => status == AuthStatus.unauthenticated || user == null;
}

/// 認証状態の種類
enum AuthStatus {
  /// 初期状態
  initial,
  
  /// 認証済み
  authenticated,
  
  /// 未認証
  unauthenticated,
  
  /// エラー
  error,
  
  /// 読み込み中
  loading,
}

/// 認証状態プロバイダー
final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(AuthService());
});

/// 認証状態通知クラス
class AuthNotifier extends StateNotifier<AuthState> {
  /// 認証サービス
  final AuthService _authService;

  /// コンストラクタ
  AuthNotifier(this._authService) : super(AuthState.initial()) {
    // 初期化時に現在のユーザーを確認
    _checkCurrentUser();
    
    // 認証状態の変更を監視
    _listenToAuthChanges();
  }

  /// 現在のユーザーを確認
  void _checkCurrentUser() {
    final user = _authService.getCurrentUser();
    if (user != null) {
      state = AuthState.authenticated(user);
    } else {
      state = AuthState.unauthenticated();
    }
  }

  /// 認証状態の変更を監視
  void _listenToAuthChanges() {
    _authService.authStateChanges().listen((user) {
      if (user != null) {
        state = AuthState.authenticated(user);
      } else {
        state = AuthState.unauthenticated();
      }
    });
  }

  /// メールアドレスとパスワードでサインアップ
  Future<void> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String username,
    required String displayName,
  }) async {
    try {
      state = state.toLoading();
      
      final user = await _authService.signUpWithEmailAndPassword(
        email: email,
        password: password,
        username: username,
        displayName: displayName,
      );
      
      if (user != null) {
        state = AuthState.authenticated(user);
      } else {
        state = AuthState.error('サインアップに失敗しました');
      }
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  /// メールアドレスとパスワードでサインイン
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      state = state.toLoading();
      
      final user = await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (user != null) {
        state = AuthState.authenticated(user);
      } else {
        state = AuthState.error('サインインに失敗しました');
      }
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  /// Googleでサインイン
  Future<void> signInWithGoogle() async {
    try {
      state = state.toLoading();
      
      await _authService.signInWithGoogle();
      
      // 注: OAuth認証はリダイレクトを使用するため、
      // 認証状態の変更は_listenToAuthChangesで検出されます
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  /// Appleでサインイン
  Future<void> signInWithApple() async {
    try {
      state = state.toLoading();
      
      await _authService.signInWithApple();
      
      // 注: OAuth認証はリダイレクトを使用するため、
      // 認証状態の変更は_listenToAuthChangesで検出されます
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  /// Twitterでサインイン
  Future<void> signInWithTwitter() async {
    try {
      state = state.toLoading();
      
      await _authService.signInWithTwitter();
      
      // 注: OAuth認証はリダイレクトを使用するため、
      // 認証状態の変更は_listenToAuthChangesで検出されます
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  /// Instagramでサインイン
  Future<void> signInWithInstagram() async {
    try {
      state = state.toLoading();
      
      await _authService.signInWithInstagram();
      
      // 注: OAuth認証はリダイレクトを使用するため、
      // 認証状態の変更は_listenToAuthChangesで検出されます
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  /// サインアウト
  Future<void> signOut() async {
    try {
      state = state.toLoading();
      
      await _authService.signOut();
      
      state = AuthState.unauthenticated();
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  /// パスワードリセットメールを送信
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      state = state.toLoading();
      
      await _authService.sendPasswordResetEmail(email);
      
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        isLoading: false,
      );
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  /// パスワードを更新
  Future<void> updatePassword(String newPassword) async {
    try {
      state = state.toLoading();
      
      await _authService.updatePassword(newPassword);
      
      state = state.copyWith(
        isLoading: false,
      );
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  /// ユーザープロファイルを更新
  Future<void> updateUserProfile({
    String? username,
    String? displayName,
    String? profileImageUrl,
    String? bannerImageUrl,
    String? bio,
  }) async {
    try {
      state = state.toLoading();
      
      final user = await _authService.updateUserProfile(
        username: username,
        displayName: displayName,
        profileImageUrl: profileImageUrl,
        bannerImageUrl: bannerImageUrl,
        bio: bio,
      );
      
      if (user != null) {
        state = AuthState.authenticated(user);
      } else {
        state = AuthState.error('プロフィール更新に失敗しました');
      }
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  /// スター認証リクエストを送信
  Future<void> requestStarVerification({
    required String socialMediaUrl,
    String? verificationDocumentUrl,
  }) async {
    try {
      state = state.toLoading();
      
      await _authService.requestStarVerification(
        socialMediaUrl: socialMediaUrl,
        verificationDocumentUrl: verificationDocumentUrl,
      );
      
      state = state.copyWith(
        isLoading: false,
      );
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  /// スター認証ステータスを確認
  Future<void> checkStarVerificationStatus() async {
    try {
      state = state.toLoading();
      
      final status = await _authService.checkStarVerificationStatus();
      
      state = state.copyWith(
        isLoading: false,
      );
      
      // 認証ステータスに応じた処理
      if (status == 'approved') {
        await _authService.updateUserType(UserType.star);
        
        // ユーザー情報を更新
        final user = _authService.getCurrentUser();
        if (user != null) {
          state = AuthState.authenticated(user);
        }
      }
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  /// エラーメッセージをクリア
  void clearError() {
    state = state.clearError();
  }
}
