import 'package:flutter/foundation.dart';
import '../models/user.dart';

class UserProvider with ChangeNotifier {
  User? _currentUser;

  User? get currentUser => _currentUser;
  bool get isStar => _currentUser?.type == UserType.star;
  bool get isFan => _currentUser?.type == UserType.fan;

  void setUser(User user) {
    _currentUser = user;
    notifyListeners();
  }

  void clearUser() {
    _currentUser = null;
    notifyListeners();
  }
} 