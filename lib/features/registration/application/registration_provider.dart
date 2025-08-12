import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starlist/features/registration/application/basic_info_provider.dart' as basic_info_provider;
import 'package:starlist/features/registration/application/profile_info_provider.dart' as profile_info_provider;
import 'package:starlist/features/registration/application/sns_link_provider.dart' as sns_link_provider;
import 'package:starlist/src/features/auth/services/auth_service.dart';
import 'package:starlist/src/features/auth/services/profile_service.dart';
import 'package:starlist/src/features/auth/services/storage_service.dart';

class RegistrationNotifier extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    // No initial action needed
  }

  Future<void> submitRegistration() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      // 1. Read data from all registration providers
      final basicInfo = ref.read(basic_info_provider.basicInfoProvider);
      final profileInfo = ref.read(profile_info_provider.profileInfoProvider);
      final snsInfo = ref.read(sns_link_provider.snsLinkProvider);

      // Instantiate services
      final authService = AuthService();
      final storageService = StorageService();
      final profileService = ProfileService();

      // 2. Create user account (store display_name in user_metadata too)
      final userModel = await authService.registerWithEmailAndPassword(
        email: basicInfo.email,
        password: basicInfo.password,
        username: basicInfo.username,
        displayName: basicInfo.displayName,
      );
      
      final userId = userModel.id;

      // 3. Upload profile image if selected
      String? avatarUrl;
      if (profileInfo.profileImage != null) {
        avatarUrl = await storageService.uploadProfileImage(profileInfo.profileImage!, userId);
      }

      // 4. Create user profile in database
      await profileService.createProfile(
        userId: userId,
        username: basicInfo.username,
        displayName: basicInfo.displayName,
        email: basicInfo.email,
        profileInfo: profileInfo,
        snsInfo: snsInfo,
        avatarUrl: avatarUrl,
      );
      
      // The user is now created and automatically logged in by Supabase signUp.
    });
  }
}

final registrationProvider = AsyncNotifierProvider<RegistrationNotifier, void>(() {
  return RegistrationNotifier();
}); 