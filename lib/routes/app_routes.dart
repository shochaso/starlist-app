import 'package:flutter/material.dart';
import 'package:starlist_app/models/star.dart';
import 'package:starlist_app/screens/home_screen.dart';
import 'package:starlist_app/screens/category_screen.dart';
import 'package:starlist_app/screens/star_detail_screen.dart';

class AppRoutes {
  static const String home = '/';
  static const String category = '/category';
  static const String starDetail = '/star_detail';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => HomeScreen());

      case category:
        final String categoryName = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => CategoryScreen(category: categoryName),
        );

      case starDetail:
        final Star star = settings.arguments as Star;
        return MaterialPageRoute(
          builder: (_) => StarDetailScreen(star: star),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('ルートが見つかりません: ${settings.name}'),
            ),
          ),
        );
    }
  }
} 