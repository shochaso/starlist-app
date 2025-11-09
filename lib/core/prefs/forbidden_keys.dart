/// 保存禁止キーリスト（機密情報）
/// 
/// Webではこれらのキーでの永続化を禁止します。
/// モバイルではSecureStorageを使用しますが、Webでは例外をスローします。
const forbiddenKeys = {
  'token',
  'access_token',
  'refresh_token',
  'jwt',
  'supabase.auth.token',
  'auth_token',
  'session_token',
};

