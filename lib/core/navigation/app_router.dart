import 'package:go_router/go_router.dart';
import 'package:starlist/features/registration/presentation/screens/1_follower_check_screen.dart';
import 'package:starlist/features/registration/presentation/screens/2_basic_info_screen.dart';
import 'package:starlist/features/registration/presentation/screens/3_profile_info_screen.dart';
import 'package:starlist/features/registration/presentation/screens/4_verification_screen.dart';
import 'package:starlist/features/registration/presentation/screens/5_sns_link_screen.dart';
import 'package:starlist/features/registration/presentation/screens/6_terms_screen.dart';
import 'package:starlist/features/registration/presentation/screens/registration_complete_screen.dart';


final GoRouter appRouter = GoRouter(
  initialLocation: '/follower-check',
  routes: [
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
  ],
); 