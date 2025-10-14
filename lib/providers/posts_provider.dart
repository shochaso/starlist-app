import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/post_model.dart';
import '../data/mock_posts/hanayama_mizuki_posts.dart';
import '../data/mock_posts/fujiwara_nomii_posts.dart';
import '../src/providers/membership_provider.dart';

/// 投稿データの状態管理
class PostsNotifier extends StateNotifier<List<PostModel>> {
  PostsNotifier() : super([
    ...HanayamaMizukiPosts.allPosts,
    ...FujiwaraNoMiiPosts.allPosts,
  ]);

  /// 投稿を追加
  void addPost(PostModel post) {
    state = [post, ...state];
  }

  /// 投稿を更新
  void updatePost(PostModel updatedPost) {
    state = state.map((post) {
      return post.id == updatedPost.id ? updatedPost : post;
    }).toList();
  }

  /// 投稿を削除
  void removePost(String postId) {
    state = state.where((post) => post.id != postId).toList();
  }

  /// いいねを切り替え
  void toggleLike(String postId) {
    state = state.map((post) {
      if (post.id == postId) {
        return post.copyWith(
          isLiked: !post.isLiked,
          likesCount: post.isLiked ? post.likesCount - 1 : post.likesCount + 1,
        );
      }
      return post;
    }).toList();
  }

  /// リフレッシュ
  void refresh() {
    state = [
      ...HanayamaMizukiPosts.allPosts,
      ...FujiwaraNoMiiPosts.allPosts,
    ];
  }
}

/// 投稿プロバイダー
final postsProvider = StateNotifierProvider<PostsNotifier, List<PostModel>>((ref) {
  return PostsNotifier();
});

/// ユーザーのアクセスレベルに基づいてフィルタリングされた投稿
final accessiblePostsProvider = Provider<List<PostModel>>((ref) {
  final posts = ref.watch(postsProvider);
  final membership = ref.watch(membershipProvider);
  
  // MembershipTypeからAccessLevelに変換
  AccessLevel userAccessLevel;
  switch (membership) {
    case MembershipType.free:
      userAccessLevel = AccessLevel.public;
      break;
    case MembershipType.light:
      userAccessLevel = AccessLevel.light;
      break;
    case MembershipType.standard:
      userAccessLevel = AccessLevel.standard;
      break;
    case MembershipType.premium:
      userAccessLevel = AccessLevel.premium;
      break;
  }
  
  return posts.where((post) => post.canAccess(userAccessLevel)).toList()
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
});

/// YouTube投稿のみを取得
final youtubePostsProvider = Provider<List<PostModel>>((ref) {
  final accessiblePosts = ref.watch(accessiblePostsProvider);
  return accessiblePosts.where((post) => post.type == PostType.youtube).toList();
});

/// ショッピング投稿のみを取得
final shoppingPostsProvider = Provider<List<PostModel>>((ref) {
  final accessiblePosts = ref.watch(accessiblePostsProvider);
  return accessiblePosts.where((post) => post.type == PostType.shopping).toList();
});

/// 公開投稿のみを取得
final publicPostsProvider = Provider<List<PostModel>>((ref) {
  final posts = ref.watch(postsProvider);
  return posts.where((post) => post.accessLevel == AccessLevel.public).toList()
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
});

/// プレミアム投稿のみを取得
final premiumPostsProvider = Provider<List<PostModel>>((ref) {
  final accessiblePosts = ref.watch(accessiblePostsProvider);
  return accessiblePosts.where((post) => post.accessLevel != AccessLevel.public).toList();
});

/// 最新の投稿を取得（ホーム画面用）
final latestPostsProvider = Provider<List<PostModel>>((ref) {
  final accessiblePosts = ref.watch(accessiblePostsProvider);
  return accessiblePosts.take(5).toList();
});

/// 花山瑞樹の投稿のみを取得
final hanayamaMizukiPostsProvider = Provider<List<PostModel>>((ref) {
  final accessiblePosts = ref.watch(accessiblePostsProvider);
  return accessiblePosts.where((post) => post.authorId == HanayamaMizukiPosts.authorId).toList();
});

/// ふじわらのみいの投稿のみを取得
final fujiwaraNoMiiPostsProvider = Provider<List<PostModel>>((ref) {
  final accessiblePosts = ref.watch(accessiblePostsProvider);
  return accessiblePosts.where((post) => post.authorId == FujiwaraNoMiiPosts.authorId).toList();
});

/// 投稿統計情報
final postStatsProvider = Provider<Map<String, int>>((ref) {
  final posts = ref.watch(postsProvider);
  final accessiblePosts = ref.watch(accessiblePostsProvider);
  
  return {
    'total': posts.length,
    'accessible': accessiblePosts.length,
    'public': posts.where((p) => p.accessLevel == AccessLevel.public).length,
    'premium': posts.where((p) => p.accessLevel != AccessLevel.public).length,
    'youtube': accessiblePosts.where((p) => p.type == PostType.youtube).length,
    'shopping': accessiblePosts.where((p) => p.type == PostType.shopping).length,
    'lifestyle': accessiblePosts.where((p) => p.type == PostType.lifestyle).length,
    'food': accessiblePosts.where((p) => p.type == PostType.food).length,
  };
});