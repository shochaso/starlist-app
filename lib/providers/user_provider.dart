import 'package:flutter/foundation.dart';
import '../models/user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

// ユーザーの役割を定義
enum UserRole {
  star,  // スター
  fan,   // ファン
}

// ユーザー情報のモデル
class UserInfo {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String? starCategory;
  final int? followers;
  final bool isVerified;

  UserInfo({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.starCategory,
    this.followers,
    this.isVerified = false,
  });

  bool get isStar => role == UserRole.star;
  bool get isFan => role == UserRole.fan;
}

// 現在のユーザー情報を管理するプロバイダー
final currentUserProvider = StateProvider<UserInfo>((ref) {
  // デフォルトはスターユーザー（テスト用）
  return UserInfo(
    id: 'star_001',
    name: 'テックレビューアー田中',
    email: 'tanaka@starlist.com',
    role: UserRole.star,
    starCategory: 'テクノロジー',
    followers: 24500,
    isVerified: true,
  );
});

// ユーザー役割切り替え用プロバイダー（テスト用）
final userRoleToggleProvider = StateProvider<UserRole>((ref) => UserRole.star); 