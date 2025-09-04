import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starlist_app/core/navigation/app_router.dart';
import 'package:starlist_app/core/theme/app_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'src/services/notification_service.dart';
import 'dart:ui';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.dumpErrorToConsole(details);
  };
  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    print('[GlobalError] $error');
    return true;
  };

  await Supabase.initialize(
    url: 'https://zjwvmoxpacbpwawlwbrd.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inpqd3Ztb3hwYWNicHdhd2x3YnJkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDEzNTQwMzMsImV4cCI6MjA1NjkzMDAzM30.37KDj4QhQmv6crotphR9GnPTM_0zv0PCCnKfXvsZx_g',
  );

  await NotificationService().init();

  runApp(const ProviderScope(child: MyApp()));
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