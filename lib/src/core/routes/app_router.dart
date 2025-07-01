import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/content/bloc/content_bloc.dart';
import '../../features/content/repositories/content_repository.dart';
import '../../features/content/screens/content_list_screen.dart';
import '../../features/content/screens/content_detail_screen.dart';
import '../../features/content/screens/content_create_screen.dart';
import '../../features/youtube/youtube_explore_screen.dart';
import '../../features/star/screens/star_timeline_sample_screen.dart';
import '../../../main.dart';  // HomeScreenをインポート
import '../../../routes/app_routes.dart';
import '../../../screens/home_screen.dart';
import '../../../screens/category_screen.dart';
import '../../../screens/star_detail_screen.dart';

class AppRouter {
  final ContentRepository contentRepository;
  final GoRouter router;
  
  AppRouter({
    required this.contentRepository,
  }) : router = _router;

  static final GoRouter _router = GoRouter(
    initialLocation: '/',
    routes: [
      // ホーム
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      
      // YouTube探索
      GoRoute(
        path: '/youtube',
        builder: (context, state) => const YouTubeExploreScreen(),
      ),
      
      // スタータイムラインサンプル
      GoRoute(
        path: '/star-timeline',
        builder: (context, state) => const StarTimelineSampleScreen(),
      ),
      
      // コンテンツ一覧
      GoRoute(
        path: '/contents',
        builder: (context, state) {
          return ProviderScope(
            overrides: [
              contentRepositoryProvider.overrideWithValue(contentRepository),
            ],
            child: const ContentListScreen(),
          );
        },
      ),
      
      // スター別コンテンツ一覧
      GoRoute(
        path: '/stars/:starId/contents',
        builder: (context, state) {
          final starId = state.pathParameters['starId'] ?? '';
          return ProviderScope(
            overrides: [
              contentRepositoryProvider.overrideWithValue(contentRepository),
            ],
            child: ContentListScreen(
              authorId: starId,
              title: 'スターのコンテンツ',
            ),
          );
        },
      ),
      
      // コンテンツ詳細
      GoRoute(
        path: '/contents/:contentId',
        builder: (context, state) {
          final contentId = state.pathParameters['contentId'] ?? '';
          return ProviderScope(
            overrides: [
              contentRepositoryProvider.overrideWithValue(contentRepository),
            ],
            child: ContentDetailScreen(contentId: contentId),
          );
        },
      ),
      
      // コンテンツ作成
      GoRoute(
        path: '/contents/create',
        builder: (context, state) {
          return ProviderScope(
            overrides: [
              contentRepositoryProvider.overrideWithValue(contentRepository),
            ],
            child: const ContentCreateScreen(),
          );
        },
      ),
      
      // コンテンツ編集
      GoRoute(
        path: '/contents/edit/:contentId',
        builder: (context, state) {
          final contentId = state.pathParameters['contentId'] ?? '';
          return ProviderScope(
            overrides: [
              contentRepositoryProvider.overrideWithValue(contentRepository),
            ],
            child: const ContentCreateScreen(
              isEditing: true,
            ),
          );
        },
      ),
      
      // カテゴリー
      GoRoute(
        path: '/category/:name',
        builder: (context, state) {
          final categoryName = state.pathParameters['name'] ?? '';
          return CategoryScreen(category: categoryName);
        },
      ),
      
      // スター
      GoRoute(
        path: '/star/:id',
        builder: (context, state) {
          final star = state.extra as Map<String, dynamic>;
          // 実際のアプリではIDを使ってスター情報をフェッチする処理が必要
          return StarDetailScreen(star: star);
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('エラー: ${state.error}'),
      ),
    ),
  );
} 

// コンテンツリポジトリのプロバイダー (app.dartでも定義されているが、ここでも定義しておく)
final contentRepositoryProvider = Provider<ContentRepository>((ref) {
  throw UnimplementedError('コンテンツリポジトリはオーバーライドする必要があります');
}); 