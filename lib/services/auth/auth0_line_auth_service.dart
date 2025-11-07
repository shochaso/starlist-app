import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/auth0_config.dart';
import '../../providers/external_auth_provider.dart';

/// Provides LINE login through Auth0 (or any Auth0 social connection).
class Auth0LineAuthService {
  Auth0LineAuthService(this._ref)
      : _auth0 = Auth0(kAuth0Domain, kAuth0ClientId);

  final Ref _ref;
  final Auth0 _auth0;

  Future<void> loginWithLine() async {
    if (!kAuth0Enabled) {
      throw StateError('Auth0 is not configured. Provide AUTH0_* dart-defines.');
    }
    final redirectUri = kAuth0RedirectUri.isNotEmpty
        ? Uri.parse(kAuth0RedirectUri)
        : Uri.parse(_defaultRedirectUri());

    try {
      final credentials = await _auth0
          .webAuthentication()
          .login(parameters: const {'connection': 'line'});

      _ref.read(externalAuthProvider.notifier).setCredentials(
            idToken: credentials.idToken,
            accessToken: credentials.accessToken,
            refreshToken: credentials.refreshToken,
          );
    } on Exception catch (error, stackTrace) {
      debugPrint('[Auth0LineAuthService] login failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await _auth0.webAuthentication().logout();
    } finally {
      _ref.read(externalAuthProvider.notifier).clear();
    }
  }

  String _defaultRedirectUri() {
    if (kIsWeb) {
      return Uri.base.origin;
    }
    // For mobile, match your custom scheme (configured in Auth0 dashboard).
    return 'starlist://auth-callback';
  }
}

final auth0LineAuthServiceProvider = Provider<Auth0LineAuthService>((ref) {
  return Auth0LineAuthService(ref);
});
