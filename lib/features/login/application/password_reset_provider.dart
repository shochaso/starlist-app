import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starlist_app/src/features/auth/services/auth_service.dart';

class PasswordResetState {
  final String email;
  final bool isLoading;
  final String? error;
  final bool isSuccess;

  const PasswordResetState({
    this.email = '',
    this.isLoading = false,
    this.error,
    this.isSuccess = false,
  });

  PasswordResetState copyWith({
    String? email,
    bool? isLoading,
    String? error,
    bool? isSuccess,
  }) {
    return PasswordResetState(
      email: email ?? this.email,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

class PasswordResetNotifier extends StateNotifier<PasswordResetState> {
  PasswordResetNotifier(this._authService) : super(const PasswordResetState());

  final AuthService _authService;

  void onEmailChanged(String email) {
    state = state.copyWith(email: email);
  }

  Future<void> sendResetLink() async {
    state = state.copyWith(isLoading: true, error: null, isSuccess: false);
    try {
      await _authService.resetPassword(state.email);
      state = state.copyWith(isLoading: false, isSuccess: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final passwordResetProvider =
    StateNotifierProvider<PasswordResetNotifier, PasswordResetState>((ref) {
  return PasswordResetNotifier(AuthService());
}); 