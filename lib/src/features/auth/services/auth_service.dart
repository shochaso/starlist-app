import "package:firebase_auth/firebase_auth.dart";
import "package:google_sign_in/google_sign_in.dart";
import "package:starlist/src/core/api/api_client.dart";
import "package:starlist/src/core/api/api_endpoints.dart";
import "package:starlist/src/features/auth/models/user_model.dart";

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final ApiClient _apiClient;

  AuthService(this._apiClient);

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserModel?> signInWithEmailAndPassword(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        final response = await _apiClient.post(
          ApiEndpoints.login,
          {"email": email, "password": password},
        );
        _apiClient.setAuthToken(response["token"]);
        return UserModel.fromJson(response["user"]);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<UserModel?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      if (userCredential.user != null) {
        final response = await _apiClient.post(
          ApiEndpoints.login,
          {"provider": "google", "token": googleAuth.idToken},
        );
        _apiClient.setAuthToken(response["token"]);
        return UserModel.fromJson(response["user"]);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<UserModel?> registerWithEmailAndPassword(
    String email,
    String password,
    String username,
  ) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        final response = await _apiClient.post(
          ApiEndpoints.register,
          {
            "email": email,
            "password": password,
            "username": username,
          },
        );
        _apiClient.setAuthToken(response["token"]);
        return UserModel.fromJson(response["user"]);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
        _apiClient.post(ApiEndpoints.logout, {}),
      ]);
      _apiClient.setAuthToken(null);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      await _apiClient.post(ApiEndpoints.resetPassword, {"email": email});
    } catch (e) {
      rethrow;
    }
  }

  Future<void> changePassword(String currentPassword, String newPassword) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final credential = EmailAuthProvider.credential(
          email: user.email!,
          password: currentPassword,
        );
        await user.reauthenticateWithCredential(credential);
        await user.updatePassword(newPassword);
        await _apiClient.post(
          ApiEndpoints.changePassword,
          {"newPassword": newPassword},
        );
      }
    } catch (e) {
      rethrow;
    }
  }
}
