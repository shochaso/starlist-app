import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/app_config.dart';
import '../errors/app_exceptions.dart';

/// Supabaseクライアントクラス
/// 
/// Supabaseとの通信を担当します。
class SupabaseClient {
  /// シングルトンインスタンス
  static final SupabaseClient _instance = SupabaseClient._internal();

  /// シングルトンインスタンスを取得
  factory SupabaseClient() => _instance;

  /// プライベートコンストラクタ
  SupabaseClient._internal();

  /// Supabaseクライアントインスタンス
  late final GotrueClient _auth;
  late final SupabaseClient _client;

  /// 初期化済みかどうか
  bool _isInitialized = false;

  /// 初期化済みかどうかを取得
  bool get isInitialized => _isInitialized;

  /// 認証クライアントを取得
  GotrueClient get auth => _auth;

  /// Supabaseクライアントを取得
  SupabaseClient get client => _client;

  /// 現在のユーザーを取得
  User? get currentUser => _auth.currentUser;

  /// 初期化
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final appConfig = AppConfig();
      
      await Supabase.initialize(
        url: appConfig.supabaseUrl,
        anonKey: appConfig.supabaseAnonKey,
      );

      _auth = Supabase.instance.client.auth;
      _client = Supabase.instance.client;
      _isInitialized = true;
    } catch (e) {
      throw DatabaseException('Supabaseの初期化に失敗しました: ${e.toString()}');
    }
  }

  /// サインアップ
  Future<User?> signUp({
    required String email,
    required String password,
    Map<String, dynamic>? data,
  }) async {
    try {
      final response = await _auth.signUp(
        email: email,
        password: password,
        data: data,
      );
      return response.user;
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  /// メールアドレスとパスワードでサインイン
  Future<User?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response.user;
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  /// OAuthプロバイダーでサインイン
  Future<void> signInWithOAuth(OAuthProvider provider) async {
    try {
      await _auth.signInWithOAuth(provider);
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  /// サインアウト
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  /// パスワードリセットメールを送信
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.resetPasswordForEmail(email);
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  /// パスワードを更新
  Future<void> updatePassword(String newPassword) async {
    try {
      await _auth.updateUser(UserAttributes(password: newPassword));
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  /// ユーザープロファイルを更新
  Future<User?> updateUserProfile(Map<String, dynamic> attributes) async {
    try {
      final response = await _auth.updateUser(UserAttributes(data: attributes));
      return response.user;
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  /// データを取得
  Future<List<Map<String, dynamic>>> select(
    String table, {
    String? columns,
    String? filter,
    List<String>? filterValues,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    try {
      PostgrestFilterBuilder query = _client.from(table).select(columns ?? '*');

      if (filter != null) {
        if (filterValues != null) {
          query = query.filter(filter, filterValues);
        } else {
          query = query.filter(filter);
        }
      }

      if (orderBy != null) {
        query = query.order(orderBy);
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      if (offset != null) {
        query = query.range(offset, offset + (limit ?? 10) - 1);
      }

      final response = await query;
      return response as List<Map<String, dynamic>>;
    } catch (e) {
      throw _handleDatabaseError(e);
    }
  }

  /// データを挿入
  Future<Map<String, dynamic>> insert(
    String table,
    Map<String, dynamic> data, {
    bool upsert = false,
    String? onConflict,
  }) async {
    try {
      final query = _client.from(table).insert(data);

      if (upsert) {
        if (onConflict != null) {
          query.onConflict(onConflict);
        }
        query.upsert();
      }

      final response = await query.select();
      return response.first as Map<String, dynamic>;
    } catch (e) {
      throw _handleDatabaseError(e);
    }
  }

  /// データを更新
  Future<List<Map<String, dynamic>>> update(
    String table,
    Map<String, dynamic> data, {
    required String filter,
    List<String>? filterValues,
  }) async {
    try {
      PostgrestFilterBuilder query = _client.from(table).update(data);

      if (filterValues != null) {
        query = query.filter(filter, filterValues);
      } else {
        query = query.filter(filter);
      }

      final response = await query.select();
      return response as List<Map<String, dynamic>>;
    } catch (e) {
      throw _handleDatabaseError(e);
    }
  }

  /// データを削除
  Future<void> delete(
    String table, {
    required String filter,
    List<String>? filterValues,
  }) async {
    try {
      PostgrestFilterBuilder query = _client.from(table).delete();

      if (filterValues != null) {
        query = query.filter(filter, filterValues);
      } else {
        query = query.filter(filter);
      }

      await query;
    } catch (e) {
      throw _handleDatabaseError(e);
    }
  }

  /// ストレージにファイルをアップロード
  Future<String> uploadFile(
    String bucket,
    String path,
    List<int> fileBytes, {
    String? contentType,
    Map<String, String>? metadata,
  }) async {
    try {
      final response = await _client.storage.from(bucket).uploadBinary(
            path,
            fileBytes,
            fileOptions: FileOptions(
              contentType: contentType,
              metadata: metadata,
            ),
          );
      return response;
    } catch (e) {
      throw _handleStorageError(e);
    }
  }

  /// ストレージからファイルを削除
  Future<void> deleteFile(String bucket, String path) async {
    try {
      await _client.storage.from(bucket).remove([path]);
    } catch (e) {
      throw _handleStorageError(e);
    }
  }

  /// ストレージからファイルのURLを取得
  String getFileUrl(String bucket, String path) {
    try {
      return _client.storage.from(bucket).getPublicUrl(path);
    } catch (e) {
      throw _handleStorageError(e);
    }
  }

  /// 認証エラーのハンドリング
  AppException _handleAuthError(dynamic error) {
    if (error is AuthException) {
      return AuthException(
        error.message,
        code: error.statusCode?.toString(),
        details: error,
      );
    }
    return AuthException('認証エラーが発生しました: ${error.toString()}', details: error);
  }

  /// データベースエラーのハンドリング
  AppException _handleDatabaseError(dynamic error) {
    if (error is PostgrestException) {
      return DatabaseException(
        error.message,
        code: error.code,
        details: error,
      );
    }
    return DatabaseException('データベースエラーが発生しました: ${error.toString()}', details: error);
  }

  /// ストレージエラーのハンドリング
  AppException _handleStorageError(dynamic error) {
    if (error is StorageException) {
      return DatabaseException(
        error.message,
        code: error.statusCode?.toString(),
        details: error,
      );
    }
    return DatabaseException('ストレージエラーが発生しました: ${error.toString()}', details: error);
  }
}
