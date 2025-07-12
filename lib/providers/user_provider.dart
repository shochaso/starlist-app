import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../data/mock_users/hanayama_mizuki.dart';
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

// ユーザーのモード（スターのみ切り替え可能）
enum UserMode {
  star,    // スターとしての活動
  fan,     // ファンとしての活動
}

// ユーザー情報のモデル
class UserInfo {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final UserMode currentMode;  // 現在のモード
  final FanPlanType? fanPlanType; // ファンの場合のプランタイプ
  final String? starCategory;
  final int? followers;
  final bool isVerified;

  UserInfo({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    UserMode? currentMode,  // デフォルトは役割に応じて設定
    this.fanPlanType,
    this.starCategory,
    this.followers,
    this.isVerified = false,
  }) : currentMode = currentMode ?? (role == UserRole.star ? UserMode.star : UserMode.fan);

  bool get isStar => role == UserRole.star;
  bool get isFan => role == UserRole.fan;
  bool get isFreeFan => role == UserRole.fan && fanPlanType == FanPlanType.free;
  bool get isLightPlan => role == UserRole.fan && fanPlanType == FanPlanType.light;
  bool get isStandardPlan => role == UserRole.fan && fanPlanType == FanPlanType.standard;
  bool get isPremiumPlan => role == UserRole.fan && fanPlanType == FanPlanType.premium;
  
  // モード切り替え可能かどうか
  bool get canSwitchMode => role == UserRole.star;
  
  // 現在のモードでの表示用
  bool get isInStarMode => currentMode == UserMode.star;
  bool get isInFanMode => currentMode == UserMode.fan;
  
  // プラン表示名取得
  String get planDisplayName {
    if (isStar) return 'スター';
    switch (fanPlanType) {
      case FanPlanType.free:
        return '無料ファン';
      case FanPlanType.light:
        return 'ライトプラン';
      case FanPlanType.standard:
        return 'スタンダードプラン';
      case FanPlanType.premium:
        return 'プレミアムプラン';
      default:
        return 'ファン';
    }
  }
}

// 現在のユーザー情報を管理するプロバイダー
final currentUserProvider = StateProvider<UserInfo>((ref) {
  // デフォルトは花山瑞樹（スター）
  final profile = HanayamaMizukiData.profile;
  return UserInfo(
    id: profile['id'],
    name: '花山瑞樹', // 公式スター名を設定
    email: 'mizuki@starlist.com',
    role: UserRole.star,
    currentMode: UserMode.star,  // デフォルトはスターモード
    starCategory: profile['category'],
    followers: profile['followers'],
    isVerified: profile['verified'],
  );
});

// ユーザーモード切り替え用プロバイダー
final userModeProvider = StateNotifierProvider<UserModeNotifier, UserMode>((ref) {
  final currentUser = ref.watch(currentUserProvider);
  return UserModeNotifier(currentUser.currentMode);
});

class UserModeNotifier extends StateNotifier<UserMode> {
  UserModeNotifier(UserMode initialMode) : super(initialMode);
  
  void switchMode() {
    state = state == UserMode.star ? UserMode.fan : UserMode.star;
  }
  
  void setMode(UserMode mode) {
    state = mode;
  }
}

// テスト用プラン切り替えプロバイダー
final testPlanProvider = StateProvider<FanPlanType?>((ref) => null);

// ユーザー役割切り替え用プロバイダー（テスト用）
final userRoleToggleProvider = StateProvider<UserRole>((ref) => UserRole.star); 