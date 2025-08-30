import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starlist_app/core/navigation/app_router.dart';
import 'package:starlist_app/core/theme/app_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'src/services/notification_service.dart';
import 'dart:ui';

Future<void> _autoLoginAndSetup() async {
  final client = Supabase.instance.client;
  try {
    print('[AutoLogin] start');

    // 既存セッションがあってもテストユーザーで上書きサインインしてセッションを更新
    try {
      await client.auth.signInWithPassword(
        email: 'shochaso@gmail.com',
        password: 'password1234',
      );
      print('[AutoLogin] signIn (force) success');
    } catch (e) {
      print('[AutoLogin] force signIn failed, try signUp: $e');
      try {
        await client.auth.signUp(email: 'shochaso@gmail.com', password: 'password1234');
        await client.auth.signInWithPassword(email: 'shochaso@gmail.com', password: 'password1234');
        print('[AutoLogin] signUp+signIn success');
      } catch (e2) { print('[AutoLogin] signUp+signIn error: $e2'); }
    }

    final startedAt = DateTime.now();
    while (client.auth.currentUser == null && DateTime.now().difference(startedAt).inMilliseconds < 1500) {
      await Future.delayed(const Duration(milliseconds: 100));
      try { await client.auth.refreshSession(); } catch (_) {}
    }

    final userId = client.auth.currentUser?.id;
    print('[AutoLogin] currentUser: ${userId ?? 'null'}');
    if (userId != null && userId.isNotEmpty) {
      final today = DateTime.now().toIso8601String().split('T')[0];
      try {
        await client.rpc('initialize_daily_gacha_attempts', params: {'user_id_param': userId});
        print('[AutoLogin] initialize_daily_gacha_attempts called');
      } catch (e) { print('[AutoLogin] RPC init error: $e'); }

      try {
        await client
            .from('gacha_attempts')
            .upsert({
              'user_id': userId,
              'date': today,
              'base_attempts': 10,
              'bonus_attempts': 0,
              'used_attempts': 0,
              'updated_at': DateTime.now().toIso8601String(),
            }, onConflict: 'user_id,date');
        print('[AutoLogin] gacha_attempts upserted to 10');
      } catch (e) {
        print('[AutoLogin] upsert error, fallback update: $e');
        try {
          await client
              .from('gacha_attempts')
              .update({'base_attempts': 10, 'updated_at': DateTime.now().toIso8601String()})
              .eq('user_id', userId)
              .eq('date', today);
          print('[AutoLogin] gacha_attempts updated to 10');
        } catch (e2) { print('[AutoLogin] update error: $e2'); }
      }
    }
    print('[AutoLogin] end');
  } catch (e) { print('[AutoLogin] fatal error: $e'); }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // グローバルエラーハンドラ（未処理例外で終了しない）
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.dumpErrorToConsole(details);
  };
  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    // Supabaseのrefresh token例外などを握りつぶして継続
    print('[GlobalError] $error');
    return true;
  };

  await Supabase.initialize(
    url: 'https://zjwvmoxpacbpwawlwbrd.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inpqd3Ztb3hwYWNicHdhd2x3YnJkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDEzNTQwMzMsImV4cCI6MjA1NjkzMDAzM30.37KDj4QhQmv6crotphR9GnPTM_0zv0PCCnKfXvsZx_g',
  );

  await SentryFlutter.init((options) {
    options.dsn = const String.fromEnvironment('SENTRY_DSN', defaultValue: '');
    options.tracesSampleRate = 0.25;
  }, appRunner: () async {
    await NotificationService().init();
    await _autoLoginAndSetup();
    runApp(const ProviderScope(child: MyApp()));
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Starlist',
      theme: AppTheme.lightTheme,
      routerConfig: createAppRouter(),
      debugShowCheckedModeBanner: false,
    );
  }
}
