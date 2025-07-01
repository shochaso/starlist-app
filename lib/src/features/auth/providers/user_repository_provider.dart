import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;

import '../repositories/user_repository.dart';
import '../supabase_provider.dart';

/// ユーザーリポジトリのプロバイダー
final userRepositoryProvider = riverpod.Provider<UserRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return UserRepository(client);
}); 