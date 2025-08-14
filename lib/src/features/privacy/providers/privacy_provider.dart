import "package:flutter/foundation.dart";
import "package:starlist_app/src/features/privacy/models/privacy_settings.dart";
import "package:starlist_app/src/features/privacy/services/privacy_service.dart";

class PrivacyProvider extends ChangeNotifier {
  final PrivacyService _privacyService;
  PrivacySettings? _settings;
  bool _isLoading = false;
  String? _error;

  PrivacyProvider(this._privacyService);

  PrivacySettings? get settings => _settings;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadUserPrivacySettings(String userId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _settings = await _privacyService.getUserPrivacySettings(userId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updatePrivacySettings(String userId, PrivacySettings settings) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _privacyService.updatePrivacySettings(userId, settings);
      _settings = settings;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> blockUser(String userId, String blockedUserId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _privacyService.blockUser(userId, blockedUserId);
      if (_settings != null) {
        _settings = _settings!.copyWith(
          blockedUsers: [..._settings!.blockedUsers, blockedUserId],
        );
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> unblockUser(String userId, String blockedUserId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _privacyService.unblockUser(userId, blockedUserId);
      if (_settings != null) {
        _settings = _settings!.copyWith(
          blockedUsers: _settings!.blockedUsers.where((id) => id != blockedUserId).toList(),
        );
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> isUserBlocked(String userId, String targetUserId) async {
    try {
      return await _privacyService.isUserBlocked(userId, targetUserId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
