/// 認証関連のバリデーションロジックを提供するクラス
class AuthValidators {
  /// メールアドレスのバリデーション
  /// 
  /// 基本的な形式チェックを行い、エラーがあればエラーメッセージを返します。
  /// 問題がなければnullを返します。
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'メールアドレスを入力してください';
    }
    
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return '有効なメールアドレスを入力してください';
    }
    
    return null;
  }
  
  /// パスワードのバリデーション
  /// 
  /// 最低限の長さと複雑さをチェックし、エラーがあればエラーメッセージを返します。
  /// 問題がなければnullを返します。
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'パスワードを入力してください';
    }
    
    if (value.length < 6) {
      return 'パスワードは6文字以上で入力してください';
    }
    
    return null;
  }
  
  /// パスワード確認用のバリデーション
  /// 
  /// パスワードと確認用パスワードが一致するかチェックします。
  /// 問題がなければnullを返します。
  static String? validatePasswordConfirmation(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'パスワード（確認用）を入力してください';
    }
    
    if (value != password) {
      return 'パスワードと確認用パスワードが一致しません';
    }
    
    return null;
  }
  
  /// ユーザー名のバリデーション
  /// 
  /// ユーザー名の形式をチェックします。
  /// 問題がなければnullを返します。
  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'ユーザー名を入力してください';
    }
    
    if (value.length < 3) {
      return 'ユーザー名は3文字以上で入力してください';
    }
    
    final usernameRegex = RegExp(r'^[a-zA-Z0-9_]+$');
    if (!usernameRegex.hasMatch(value)) {
      return 'ユーザー名は英数字とアンダースコアのみ使用できます';
    }
    
    return null;
  }
  
  /// 表示名のバリデーション
  /// 
  /// 表示名の形式をチェックします。
  /// 問題がなければnullを返します。
  static String? validateDisplayName(String? value) {
    if (value == null || value.isEmpty) {
      return '表示名を入力してください';
    }
    
    if (value.length < 2) {
      return '表示名は2文字以上で入力してください';
    }
    
    return null;
  }
} 