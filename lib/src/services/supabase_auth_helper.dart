import 'package:supabase/supabase.dart';

/// Helper utilities for Supabase authentication flows that can be consumed
/// by both production code and tests.
class SupabaseAuthHelper {
  SupabaseAuthHelper._();

  /// Attempts to sign in with email and password credentials.
  /// Returns the acquired [Session] (or `null` on failure).
  static Future<Session?> signInWithPassword({
    required SupabaseClient client,
    required String email,
    required String password,
  }) async {
    try {
      final response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response.session;
    } catch (error) {
      // Bubble the error to callers if they need the message.
      // For now we simply log and return null.
      return null;
    }
  }
}

