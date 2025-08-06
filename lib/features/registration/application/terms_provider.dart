import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';

@immutable
class TermsState {
  final bool termsAccepted;
  final bool privacyAccepted;
  final bool isFormValid;

  const TermsState({
    this.termsAccepted = false,
    this.privacyAccepted = false,
    this.isFormValid = false,
  });

  TermsState copyWith({
    bool? termsAccepted,
    bool? privacyAccepted,
    bool? isFormValid,
  }) {
    return TermsState(
      termsAccepted: termsAccepted ?? this.termsAccepted,
      privacyAccepted: privacyAccepted ?? this.privacyAccepted,
      isFormValid: isFormValid ?? this.isFormValid,
    );
  }
}

class TermsNotifier extends StateNotifier<TermsState> {
  TermsNotifier() : super(const TermsState());

  void setTermsAccepted(bool value) {
    state = state.copyWith(termsAccepted: value);
    _validateForm();
  }

  void setPrivacyAccepted(bool value) {
    state = state.copyWith(privacyAccepted: value);
    _validateForm();
  }

  void _validateForm() {
    state = state.copyWith(isFormValid: state.termsAccepted && state.privacyAccepted);
  }
}

final termsProvider = StateNotifierProvider<TermsNotifier, TermsState>((ref) {
  return TermsNotifier();
}); 