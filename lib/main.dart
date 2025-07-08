import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'src/core/services/lightweight_preloader.dart';
import 'src/core/theme/app_theme.dart';
import 'screens/starlist_main_screen.dart';
import 'features/auth/screens/star_signup_screen.dart';
import 'features/auth/screens/star_email_signup_screen.dart';
import 'features/star/screens/star_dashboard_screen.dart';
import 'features/subscription/screens/plan_management_screen.dart';
import 'features/data_integration/screens/data_import_screen.dart';
import 'features/search/screens/search_screen.dart';
import 'features/mylist/screens/mylist_screen.dart';
import 'features/profile/screens/profile_screen.dart';
import 'features/app/screens/settings_screen.dart';
import 'src/widgets/theme_test_screen.dart';

// 軽量化のためのグローバル変数
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = 
    FlutterLocalNotificationsPlugin();

// Riverpodプロバイダー名の衝突を避けるため
final userTypeProvider = StateProvider<String>((ref) => 'fan');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 軽量化: 段階的初期化
  await _initializeLightweight();
  
  runApp(
    ProviderScope(
      child: StarlistApp(),
    ),
  );
}

/// 軽量化された初期化処理
Future<void> _initializeLightweight() async {
  try {
    // Phase 1: 必要最小限の初期化
    await _initializeCore();
    
    // Phase 2: 軽量化プリローダーの初期化
    await LightweightPreloader().initializeLightweight();
    
    // Phase 3: バックグラウンドで残りの初期化
    _initializeBackgroundServices();
    
  } catch (e) {
    debugPrint('軽量化初期化エラー: $e');
    // エラーが発生してもアプリは起動する
  }
}

/// コア機能の初期化（軽量化版）
Future<void> _initializeCore() async {
  // 環境変数の読み込み
  await dotenv.load(fileName: ".env");
  
  // Supabaseの初期化（必須）
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );
}

/// バックグラウンドサービスの初期化（軽量化版）
void _initializeBackgroundServices() {
  // 非同期でバックグラウンド初期化
  Future.delayed(Duration(seconds: 2), () async {
    try {
      // Firebase初期化（プッシュ通知用）
      await Firebase.initializeApp();
      
      // 通知設定
      await _setupNotifications();
      
    } catch (e) {
      debugPrint('バックグラウンド初期化エラー: $e');
    }
  });
}

/// 通知設定（軽量化版）
Future<void> _setupNotifications() async {
  // Android通知設定
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  
  // iOS通知設定
  const DarwinInitializationSettings initializationSettingsIOS =
      DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
  
  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );
  
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
}

/// 軽量化されたメインアプリ
class StarlistApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Starlist',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: '/',
      routes: {
        '/': (context) => const StarlistMainScreen(),
        '/star-signup': (context) => const StarSignupScreen(),
        '/star-email-signup': (context) => const StarEmailSignupScreen(),
        '/star-dashboard': (context) => const StarDashboardScreen(),
        '/plan-management': (context) => const PlanManagementScreen(),
        '/data-import': (context) => const DataImportScreen(),
        '/theme-test': (context) => const ThemeTestScreen(),
        '/search': (context) => const SearchScreen(),
        '/mylist': (context) => const MylistScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/home': (context) => const StarlistMainScreen(),
      },
      debugShowCheckedModeBanner: false,
      // 軽量化のためのパフォーマンス設定
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaleFactor: 1.0, // テキストスケールを固定（軽量化）
          ),
          child: child!,
        );
      },
    );
  }
}
