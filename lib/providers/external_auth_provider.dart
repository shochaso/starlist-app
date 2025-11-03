import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExternalAuthState {
  const ExternalAuthState({
    this.idToken,
    this.accessToken,
    this.refreshToken,
  });

  final String? idToken;
  final String? accessToken;
  final String? refreshToken;

  bool get isAuthenticated => idToken != null;

  ExternalAuthState copyWith({
    String? idToken,
    String? accessToken,
    String? refreshToken,
  }) {
    return ExternalAuthState(
      idToken: idToken ?? this.idToken,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
    );
  }
}

class ExternalAuthNotifier extends StateNotifier<ExternalAuthState> {
  ExternalAuthNotifier() : super(const ExternalAuthState());

  void setCredentials({
    required String idToken,
    String? accessToken,
    String? refreshToken,
  }) {
    state = ExternalAuthState(
      idToken: idToken,
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }

  void clear() {
    state = const ExternalAuthState();
  }
}

final externalAuthProvider =
    StateNotifierProvider<ExternalAuthNotifier, ExternalAuthState>(
  (ref) => ExternalAuthNotifier(),
);
