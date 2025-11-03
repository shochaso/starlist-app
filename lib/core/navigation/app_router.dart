import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:starlist_app/features/login/screens/login_screen.dart';
import 'package:starlist_app/features/login/screens/password_reset_request_screen.dart';
import 'package:starlist_app/features/login/screens/password_reset_screen.dart';
// import 'package:starlist_app/screens/style_guide_page.dart'; // 一時的にコメントアウト
import 'package:starlist_app/features/star_data/presentation/star_data_youtube_page.dart';
import 'package:starlist_app/features/registration/presentation/screens/1_follower_check_screen.dart';
import 'package:starlist_app/features/registration/presentation/screens/2_basic_info_screen.dart';
import 'package:starlist_app/features/registration/presentation/screens/3_profile_info_screen.dart';
import 'package:starlist_app/features/registration/presentation/screens/4_verification_screen.dart';
import 'package:starlist_app/features/registration/presentation/screens/5_sns_link_screen.dart';
import 'package:starlist_app/features/registration/presentation/screens/6_terms_screen.dart';
import 'package:starlist_app/features/registration/presentation/screens/registration_complete_screen.dart';
import 'package:starlist_app/screens/starlist_main_screen.dart';
// import 'package:starlist_app/features/app/screens/settings_screen.dart'; // 一時的にコメントアウト
import 'package:starlist_app/screens/bootstrap_screen.dart';
import 'package:starlist_app/screens/fan_register_screen.dart';
import 'package:starlist_app/screens/star_teaser_screen.dart';
import 'package:starlist_app/screens/landing_screen.dart';

class _AuthStreamListenable extends ChangeNotifier {
  _AuthStreamListenable(Stream<AuthState> stream) {
    _sub = stream.listen((_) => notifyListeners());
  }
  late final StreamSubscription<AuthState> _sub;
  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

GoRouter createAppRouter() {
  return GoRouter(
    initialLocation: '/bootstrap',
    routes: [
      GoRoute(
        path: '/bootstrap',
        builder: (context, state) => const BootstrapScreen(),
      ),
      GoRoute(
        path: '/fan-register',
        builder: (context, state) => const FanRegisterScreen(),
      ),
      GoRoute(
        path: '/star-teaser',
        builder: (context, state) => const StarTeaserScreen(),
      ),
      GoRoute(
        path: '/landing',
        builder: (context, state) => const LandingScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const StarlistMainScreen(),
      ),
      GoRoute(
        path: '/password-reset-request',
        builder: (context, state) => const PasswordResetRequestScreen(),
      ),
      GoRoute(
        path: '/password-reset',
        builder: (context, state) => const PasswordResetScreen(),
      ),
      GoRoute(
        path: '/follower-check',
        builder: (context, state) => const FollowerCheckScreen(),
      ),
      GoRoute(
        path: '/basic-info',
        builder: (context, state) => const BasicInfoScreen(),
      ),
      GoRoute(
        path: '/profile-info',
        builder: (context, state) => const ProfileInfoScreen(),
      ),
      GoRoute(
        path: '/verification',
        builder: (context, state) => const VerificationScreen(),
      ),
      GoRoute(
        path: '/sns-link',
        builder: (context, state) => const SnsLinkScreen(),
      ),
      GoRoute(
        path: '/terms',
        builder: (context, state) => const TermsScreen(),
      ),
      GoRoute(
        path: '/registration-complete',
        builder: (context, state) => const RegistrationCompleteScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => Scaffold(
          appBar: AppBar(title: const Text('設定')),
          body: const Center(child: Text('設定画面（一時的に無効化）')),
        ),
      ),
      GoRoute(
        path: '/stars/:username/data',
        builder: (context, state) => const StarDataYoutubePage(),
      ),
      GoRoute(
        path: '/star-data',
        builder: (context, state) => const StarDataYoutubePage(),
      ),
      // GoRoute(
      //   path: '/style-guide',
      //   builder: (context, state) => const StyleGuidePage(),
      // ),
    ],
  );
}
