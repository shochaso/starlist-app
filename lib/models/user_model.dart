class UserModel {
  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final SubscriptionStatus subscriptionStatus;
  // 追加情報
  final List<String>? favoriteCategories;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.subscriptionStatus = SubscriptionStatus.free,
    this.favoriteCategories,
    required this.createdAt,
  });

  // Supabaseからの変換メソッド
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      email: map['email'],
      displayName: map['display_name'],
      photoUrl: map['photo_url'],
      subscriptionStatus: _mapSubscriptionStatus(map['subscription_status']),
      favoriteCategories: List<String>.from(map['favorite_categories'] ?? []),
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  // Supabaseへの変換メソッド
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'display_name': displayName,
      'photo_url': photoUrl,
      'subscription_status': subscriptionStatus.name,
      'favorite_categories': favoriteCategories,
      'created_at': createdAt.toIso8601String(),
    };
  }
  
  // ヘルパーメソッド
  static SubscriptionStatus _mapSubscriptionStatus(String? status) {
    if (status == null) return SubscriptionStatus.free;
    return SubscriptionStatus.values.firstWhere(
      (e) => e.name == status,
      orElse: () => SubscriptionStatus.free,
    );
  }

  // ユーザープロフィール更新メソッド
  Future<bool> updateProfile(SupabaseClient client, {
    String? displayName,
    String? photoUrl,
    List<String>? favoriteCategories,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (displayName != null) updates['display_name'] = displayName;
      if (photoUrl != null) updates['photo_url'] = photoUrl;
      if (favoriteCategories != null) updates['favorite_categories'] = favoriteCategories;
      
      await client.from('users').update(updates).eq('id', id);
      return true;
    } catch (e) {
      print('プロフィール更新エラー: $e');
      return false;
    }
  }

  // 静的ファクトリメソッド - 現在のユーザー取得
  static Future<UserModel?> getCurrentUser(SupabaseClient client) async {
    try {
      final userId = client.auth.currentUser?.id;
      if (userId == null) return null;
      
      final response = await client.from('users').select().eq('id', userId).single();
      return UserModel.fromMap(response);
    } catch (e) {
      print('ユーザー取得エラー: $e');
      return null;
    }
  }
} 