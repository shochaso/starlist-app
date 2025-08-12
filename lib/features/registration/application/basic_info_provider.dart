import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';

@immutable
class BasicInfoState {
  final String username;
  final String displayName;
  final String email;
  final String password;
  final bool isFormValid;

  const BasicInfoState({
    this.username = '',
    this.displayName = '',
    this.email = '',
    this.password = '',
    this.isFormValid = false,
  });

  BasicInfoState copyWith({
    String? username,
    String? displayName,
    String? email,
    String? password,
    bool? isFormValid,
  }) {
    return BasicInfoState(
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      password: password ?? this.password,
      isFormValid: isFormValid ?? this.isFormValid,
    );
  }
}

class BasicInfoNotifier extends StateNotifier<BasicInfoState> {
  BasicInfoNotifier() : super(const BasicInfoState());

  void updateUsername(String value) {
    state = state.copyWith(username: value);
    _validateForm();
  }

  void updateDisplayName(String value) {
    state = state.copyWith(displayName: value);
    _validateForm();
  }

  void updateEmail(String value) {
    state = state.copyWith(email: value);
    _validateForm();
  }

  void updatePassword(String value) {
    state = state.copyWith(password: value);
    _validateForm();
  }

  void _validateForm() {
    final bool isUsernameValid = state.username.isNotEmpty;
    final bool isDisplayNameValid = state.displayName.isNotEmpty;
    final bool isEmailValid = state.email.contains('@');
    final bool isPasswordValid = state.password.length >= 8;

    final bool currentFormValid = isUsernameValid && isDisplayNameValid && isEmailValid && isPasswordValid;

    print('--- BasicInfoForm Validation ---');
    print('Username: ${state.username} (Valid: $isUsernameValid)');
    print('DisplayName: ${state.displayName} (Valid: $isDisplayNameValid)');
    print('Email: ${state.email} (Valid: $isEmailValid)');
    print('Password: ${state.password} (Valid: $isPasswordValid)');
    print('Overall Form Valid: $currentFormValid');
    print('------------------------------');

    state = state.copyWith(isFormValid: currentFormValid);
  }
}

final basicInfoProvider = StateNotifierProvider<BasicInfoNotifier, BasicInfoState>((ref) {
  return BasicInfoNotifier();
}); 