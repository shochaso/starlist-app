import "package:flutter_test/flutter_test.dart";
import "package:mockito/mockito.dart";
import "package:starlist/src/features/auth/models/user_auth_model.dart";
import "package:starlist/src/features/auth/providers/auth_provider.dart";
import "package:starlist/src/features/auth/services/auth_service.dart";

class MockAuthService extends Mock implements AuthService {}

void main() {
  late AuthProvider authProvider;
  late MockAuthService mockAuthService;

  setUp(() {
    mockAuthService = MockAuthService();
    authProvider = AuthProvider(mockAuthService);
  });

  group("AuthProvider", () {
    test("initial state", () {
      expect(authProvider.currentUser, isNull);
      expect(authProvider.isLoading, isFalse);
      expect(authProvider.error, isNull);
      expect(authProvider.isAuthenticated, isFalse);
    });

    test("sign in success", () async {
      final user = UserAuthModel(
        id: "1",
        email: "test@example.com",
        createdAt: DateTime.now(),
      );

      when(mockAuthService.signInWithEmailAndPassword(
        "test@example.com",
        "password",
      )).thenAnswer((_) async => user);

      await authProvider.signInWithEmailAndPassword(
        "test@example.com",
        "password",
      );

      expect(authProvider.currentUser, equals(user));
      expect(authProvider.error, isNull);
      expect(authProvider.isAuthenticated, isTrue);
    });

    test("sign in failure", () async {
      when(mockAuthService.signInWithEmailAndPassword(
        "test@example.com",
        "password",
      )).thenThrow(Exception("Invalid credentials"));

      await authProvider.signInWithEmailAndPassword(
        "test@example.com",
        "password",
      );

      expect(authProvider.currentUser, isNull);
      expect(authProvider.error, isNotNull);
      expect(authProvider.isAuthenticated, isFalse);
    });
  });
}
