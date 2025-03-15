// Supabase接続をテストする関数
Future<void> testSupabaseConnection() async {
  try {
    final client = Supabase.instance.client;
    
    // バージョン情報を取得（軽量なクエリ）
    final response = await client.rpc('version').execute();
    
    if (response.error == null) {
      print('Supabase接続成功: ${response.data}');
    } else {
      print('Supabase接続エラー: ${response.error?.message}');
    }
  } catch (e) {
    print('Supabase接続テスト例外: $e');
  }
} 