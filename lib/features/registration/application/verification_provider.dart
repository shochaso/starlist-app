import 'dart:math';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';

@immutable
class VerificationState {
  final String verificationCode;
  final String snsUrl;
  final bool isFormValid;

  const VerificationState({
    required this.verificationCode,
    this.snsUrl = '',
    this.isFormValid = false,
  });

  VerificationState copyWith({
    String? verificationCode,
    String? snsUrl,
    bool? isFormValid,
  }) {
    return VerificationState(
      verificationCode: verificationCode ?? this.verificationCode,
      snsUrl: snsUrl ?? this.snsUrl,
      isFormValid: isFormValid ?? this.isFormValid,
    );
  }
}

class VerificationNotifier extends StateNotifier<VerificationState> {
  VerificationNotifier() : super(VerificationState(verificationCode: _generateCode()));

  static String _generateCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    final code = String.fromCharCodes(Iterable.generate(
        6, (_) => chars.codeUnitAt(random.nextInt(chars.length))));
    return 'Starlist-$code';
  }

  void updateSnsUrl(String url) {
    state = state.copyWith(snsUrl: url);
    _validateForm();
  }
  
  Future<void> copyCodeToClipboard() async {
    await Clipboard.setData(ClipboardData(text: state.verificationCode));
  }

  void _validateForm() {
    // A simple check for a valid URL pattern
    // The check is relaxed to enable the button as long as the field is not empty.
    final isValid = state.snsUrl.isNotEmpty;
    state = state.copyWith(isFormValid: isValid);
  }
}

final verificationProvider =
    StateNotifierProvider<VerificationNotifier, VerificationState>((ref) {
  return VerificationNotifier();
}); 