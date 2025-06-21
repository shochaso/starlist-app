import "package:flutter/foundation.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:starlist/src/features/auth/models/user_model.dart";
import "package:starlist/src/features/auth/services/auth_service.dart";

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  AuthProvider(this._authService) {
    _authService.authStateChanges.listen(_onAuthStateChanged);
  }

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  void _onAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser != null) {
      try {
        _isLoading = true;
        _error = null;
        notifyListeners();

        // TODO: Fetch user data from API
        _user = UserModel(
          id: firebaseUser.uid,
          email: firebaseUser.email!,
          username: firebaseUser.displayName ?? "",
          createdAt: DateTime.now(),
        );

        _isLoading = false;
        notifyListeners();
      } catch (e) {
        _error = e.toString();
        _isLoading = false;
        notifyListeners();
      }
    } else {
      _user = null;
      notifyListeners();
    }
  }

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _user = await _authService.signInWithEmailAndPassword(email, password);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _user = await _authService.signInWithGoogle();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> registerWithEmailAndPassword(
    String email,
    String password,
    String username,
  ) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _user = await _authService.registerWithEmailAndPassword(email, password, username);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _authService.signOut();
      _user = null;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _authService.resetPassword(email);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> changePassword(String currentPassword, String newPassword) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _authService.changePassword(currentPassword, newPassword);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
}
