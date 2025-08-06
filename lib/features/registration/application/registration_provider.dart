import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starlist/features/registration/application/basic_info_provider.dart';
import 'package:starlist/features/registration/application/profile_info_provider.dart';
import 'package:starlist/features/registration/application/sns_link_provider.dart';
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
      final basicInfo = ref.read(basicInfoProvider);
      final profileInfo = ref.read(profileInfoProvider);
      final snsInfo = ref.read(snsLinkProvider);

      // Instantiate services
      final authService = AuthService();
      final storageService = StorageService();
      final profileService = ProfileService();

      // 2. Create user account
      final userModel = await authService.registerWithEmailAndPassword(
        email: basicInfo.email,
        password: basicInfo.password,
        username: basicInfo.username,
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