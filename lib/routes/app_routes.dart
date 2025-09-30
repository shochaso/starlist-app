import 'package:flutter/material.dart';
import '../models/star.dart';
import '../screens/home_screen.dart';
import '../screens/category_screen.dart';
import '../screens/star_detail_screen.dart';
import '../screens/following_screen.dart';
import '../screens/fan_mypage_screen.dart';
import '../screens/star_mypage_screen.dart';
import '../screens/category_list_screen.dart';
import '../src/features/content/models/content_consumption_model.dart';
import '../src/features/content/screens/category_content_list_screen.dart';
import '../src/features/content/screens/content_archive_search_screen.dart';

class AppRoutes {
  static const String home = '/';
  static const String category = '/category';
  static const String categoryList = '/category_list';
  static const String categoryContentList = '/category_contents';
  static const String contentArchiveSearch = '/content_archive_search';
  static const String starDetail = '/star_detail';
  static const String following = '/following';
  static const String fanMypage = '/fan_mypage';
  static const String starMypage = '/star_mypage';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(
          builder: (context) => HomeScreen(
            onThemeToggle: settings.arguments as VoidCallback?,
          ),
        );

      case category:
        Map<String, dynamic>? args;
        if (settings.arguments is String) {
          args = {'title': settings.arguments as String};
        } else if (settings.arguments is Map<String, dynamic>) {
          args = settings.arguments as Map<String, dynamic>;
        }
        
        return MaterialPageRoute(
          builder: (context) => CategoryScreen(
            category: args?['title'] ?? '',
          ),
        );
        
      case categoryList:
        return MaterialPageRoute(
          builder: (context) => const CategoryListScreen(),
        );

      case categoryContentList:
        final args = settings.arguments;
        ContentCategory? initialCategory;
        String? title;
        if (args is Map<String, dynamic>) {
          final categoryArg = args['category'];
          if (categoryArg is ContentCategory) {
            initialCategory = categoryArg;
          } else if (categoryArg is String) {
            for (final category in ContentCategory.values) {
              if (category.name == categoryArg) {
                initialCategory = category;
                break;
              }
            }
          }
          title = args['title'] as String?;
        }
        return MaterialPageRoute(
          builder: (context) => CategoryContentListScreen(
            initialCategory: initialCategory,
            title: title,
          ),
        );

      case contentArchiveSearch:
        return MaterialPageRoute(
          builder: (context) => const ContentArchiveSearchScreen(),
        );

      case starDetail:
        final Star star = settings.arguments as Star;
        return MaterialPageRoute(
          builder: (context) => StarDetailScreen(
            star: star,
          ),
        );

      case following:
        return MaterialPageRoute(
          builder: (context) => const FollowingScreen(),
        );

      case fanMypage:
        return MaterialPageRoute(
          builder: (context) => const FanMyPageScreen(),
        );
        
      case starMypage:
        return MaterialPageRoute(
          builder: (context) => const StarMyPageScreen(),
        );

      default:
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            body: Center(
              child: Text('ルートが見つかりません: ${settings.name}'),
            ),
          ),
        );
    }
  }
} 
