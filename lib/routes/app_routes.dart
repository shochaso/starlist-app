import 'package:flutter/material.dart';
import '../models/star.dart';
import '../screens/home_screen.dart';
import '../screens/category_screen.dart';
import '../screens/star_detail_screen.dart';
import '../screens/following_screen.dart';
import '../screens/fan_mypage_screen.dart';
import '../screens/star_mypage_screen.dart';
import '../screens/category_list_screen.dart';

class AppRoutes {
  static const String home = '/';
  static const String category = '/category';
  static const String categoryList = '/category_list';
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
          builder: (context) => CategoryListScreen(),
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
          builder: (context) => FollowingScreen(),
        );

      case fanMypage:
        return MaterialPageRoute(
          builder: (context) => FanMyPageScreen(),
        );
        
      case starMypage:
        return MaterialPageRoute(
          builder: (context) => StarMyPageScreen(),
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