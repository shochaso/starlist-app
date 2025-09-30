import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../screens/starlist_main_screen.dart';
import '../../../features/auth/screens/star_signup_screen.dart';
import '../../../features/auth/screens/star_email_signup_screen.dart';
import '../../../features/star/screens/star_dashboard_screen.dart';
import '../../features/subscription/screens/subscription_plans_screen.dart';
import '../../../features/app/screens/settings_screen.dart';
import '../../../features/data_integration/screens/data_import_screen.dart';
import '../../../features/search/screens/search_screen.dart';
import '../../../features/mylist/screens/mylist_screen.dart';
import '../../../features/profile/screens/profile_screen.dart';
import '../../features/content/screens/category_content_list_screen.dart';
import '../../features/content/screens/content_archive_search_screen.dart';
import '../../features/content/models/content_consumption_model.dart';

/// 軽量化されたアプリルーター
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      // ホーム画面
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const StarlistMainScreen(),
      ),
      
      // 認証関連
      GoRoute(
        path: '/star-signup',
        name: 'star-signup',
        builder: (context, state) => const StarSignupScreen(),
      ),
      GoRoute(
        path: '/star-email-signup',
        name: 'star-email-signup',
        builder: (context, state) => const StarEmailSignupScreen(),
      ),
      
      // スター関連
      GoRoute(
        path: '/star-dashboard',
        name: 'star-dashboard',
        builder: (context, state) => const StarDashboardScreen(),
      ),
      
      // プラン管理
      GoRoute(
        path: '/plan-management',
        name: 'plan-management',
        builder: (context, state) => const SubscriptionPlansScreen(),
      ),
      
      // 設定
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      
      // データ取り込み
      GoRoute(
        path: '/data-import',
        name: 'data-import',
        builder: (context, state) => const DataImportScreen(),
      ),
      
      // 検索
      GoRoute(
        path: '/search',
        name: 'search',
        builder: (context, state) => const SearchScreen(),
      ),
      
      // マイリスト
      GoRoute(
        path: '/mylist',
        name: 'mylist',
        builder: (context, state) => const MylistScreen(),
      ),
      
      // プロフィール
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      
      GoRoute(
        path: '/category-contents',
        name: 'category-contents',
        builder: (context, state) {
          final categoryParam = state.uri.queryParameters['category'];
          final title = state.uri.queryParameters['title'];
          final initialCategory = _parseContentCategory(categoryParam);
          return CategoryContentListScreen(
            initialCategory: initialCategory,
            title: title,
          );
        },
      ),
      
      GoRoute(
        path: '/content-archive',
        name: 'content-archive',
        builder: (context, state) => const ContentArchiveSearchScreen(),
      ),
    ],
    
    // 軽量化のためのエラーハンドリング
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(
        title: const Text('エラー'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'ページが見つかりません',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              state.error.toString(),
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('ホームに戻る'),
            ),
          ],
        ),
      ),
    ),
  );
});

ContentCategory? _parseContentCategory(String? value) {
  if (value == null) return null;
  for (final category in ContentCategory.values) {
    if (category.name == value) {
      return category;
    }
  }
  return null;
}
