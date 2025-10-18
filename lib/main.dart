import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config/environment_config.dart';
import 'core/navigation/app_router.dart';
import 'theme/app_theme.dart';
import 'src/services/notification_service.dart';
import 'services/service_icon_registry.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env.development');

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.dumpErrorToConsole(details);
  };
  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    print('[GlobalError] $error');
    return true;
  };

  try {
    await Supabase.initialize(
      url: EnvironmentConfig.supabaseUrl,
      anonKey: EnvironmentConfig.supabaseAnonKey,
    );
  } catch (error, stackTrace) {
    debugPrint('[Supabase] Initialization skipped: $error');
    debugPrintStack(stackTrace: stackTrace);
  }

  await NotificationService().init();
  await ServiceIconRegistry.init();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Starlist • HMR',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: createAppRouter(),
      debugShowCheckedModeBanner: false,
    );
  }
}
