import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:starlist/src/features/auth/models/user_model.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  User? get currentUser => _supabase.auth.currentUser;

  Future<UserModel> signInWithEmailAndPassword(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (response.user == null) {
        throw Exception('ログインに失敗しました');
      }
      // This is a simplified user model conversion. 
      // In a real app, you'd fetch more details from your 'profiles' table.
      return UserModel.fromSupabaseUser(response.user!);
    } catch (e) {
      throw Exception('ログインに失敗しました: ${e.toString()}');
    }
  }

  Future<UserModel> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'username': username},
      );
      if (response.user == null) {
        throw Exception('ユーザー登録に失敗しました');
      }
      return UserModel.fromSupabaseUser(response.user!);
    } catch (e) {
      // Handle specific Supabase errors, e.g., user already exists
      if (e is AuthException && e.message.contains('User already registered')) {
         throw Exception('このメールアドレスは既に使用されています。');
      }
      throw Exception('ユーザー登録に失敗しました: ${e.toString()}');
    }
  }

  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      throw Exception('ログアウトに失敗しました: ${e.toString()}');
    }
  }

  Future<void> resetPassword(String email) async {
    try {
       await _supabase.auth.resetPasswordForEmail(email);
    } catch (e) {
      throw Exception('パスワードリセットに失敗しました: ${e.toString()}');
    }
  }
}
