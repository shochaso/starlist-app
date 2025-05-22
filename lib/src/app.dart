import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide Provider;

import '../screens/home_screen.dart';
import '../routes/app_routes.dart';

// テーマモード設定のプロバイダー
final themeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.light);

class StarlistApp extends ConsumerWidget {
  final SupabaseClient supabaseClient;

  const StarlistApp({
    Key? key,
    required this.supabaseClient,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    
    return MaterialApp(
      title: 'Starlist',
      // ライトテーマ（Starlink風）
      theme: ThemeData.light().copyWith(
        primaryColor: Colors.white,
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.light(
          primary: Colors.black,
          secondary: Colors.grey.shade900,
          surface: Colors.white,
          background: Colors.white,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: Colors.black,
          onBackground: Colors.black,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          centerTitle: true,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
        ),
        cardTheme: CardTheme(
          color: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            elevation: 1,
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 12,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Colors.black,
          ),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.grey.shade600,
          type: BottomNavigationBarType.fixed,
        ),
        textTheme: TextTheme(
          displayLarge: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          displayMedium: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          displaySmall: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          headlineMedium: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          headlineSmall: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          titleLarge: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          titleMedium: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          titleSmall: TextStyle(color: Colors.black),
          bodyLarge: TextStyle(color: Colors.black),
          bodyMedium: TextStyle(color: Colors.black87),
          bodySmall: TextStyle(color: Colors.black54),
        ),
      ),
      // ダークテーマ（App Store風）
      darkTheme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        colorScheme: ColorScheme.dark(
          primary: Colors.blue,
          secondary: Colors.blueAccent,
          surface: Colors.grey.shade900,
          background: Colors.black,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: Colors.white,
          onBackground: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
        ),
        cardTheme: CardTheme(
          color: Colors.grey.shade900,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey.shade800,
            foregroundColor: Colors.white,
            elevation: 1,
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 12,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Colors.blue,
          ),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.black,
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey.shade600,
          type: BottomNavigationBarType.fixed,
        ),
        textTheme: TextTheme(
          displayLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          displayMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          displaySmall: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          headlineMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          headlineSmall: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          titleMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          titleSmall: TextStyle(color: Colors.white),
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.grey.shade200),
          bodySmall: TextStyle(color: Colors.grey.shade400),
        ),
      ),
      themeMode: themeMode,
      initialRoute: AppRoutes.home,
      onGenerateRoute: AppRoutes.generateRoute,
      home: HomeScreen(
        onThemeToggle: () {
          ref.read(themeProvider.notifier).state = 
            themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
        },
      ),
    );
  }
} 