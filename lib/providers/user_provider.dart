import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../data/mock_users/hanayama_mizuki.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

// ログアウト状態を確認する関数
Future<bool> _isLoggedOut() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_logged_out') ?? false;
  } catch (e) {
    debugPrint('ログアウト状態の確認に失敗: $e');
    return false;
  }
}

// 現在のユーザー情報を管理するプロバイダー
final currentUserProvider = StateNotifierProvider<UserInfoNotifier, UserInfo>((ref) {
  return UserInfoNotifier();
});

class UserInfoNotifier extends StateNotifier<UserInfo> {
  UserInfoNotifier() : super(_getDefaultUserInfo()) {
    _initializeUserState();
  }

  static UserInfo _getDefaultUserInfo() {
    final profile = HanayamaMizukiData.profile;
    return UserInfo(
      id: profile['id'],
      name: '花山瑞樹',
      email: 'mizuki@starlist.com',
      role: UserRole.star,
      currentMode: UserMode.star,
      starCategory: profile['category'],
      followers: profile['followers'],
      isVerified: profile['verified'],
    );
  }

  Future<void> _initializeUserState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedOut = prefs.getBool('is_logged_out') ?? false;
      
      if (isLoggedOut) {
        state = UserInfo(
          id: '',
          name: '',
          email: '',
          role: UserRole.fan,
        );
      }
    } catch (e) {
      debugPrint('ユーザー状態の初期化に失敗: $e');
    }
  }

  void setUser(UserInfo user) {
    state = user;
  }

  void logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_logged_out', true);
      await prefs.setString('logout_timestamp', DateTime.now().toIso8601String());
      
      state = UserInfo(
        id: '',
        name: '',
        email: '',
        role: UserRole.fan,
      );
    } catch (e) {
      debugPrint('ログアウト処理に失敗: $e');
    }
  }

  void login() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_logged_out', false);
      await prefs.remove('logout_timestamp');
      
      state = _getDefaultUserInfo();
    } catch (e) {
      debugPrint('ログイン処理に失敗: $e');
    }
  }

  void setTestUser(UserInfo user) {
    state = user;
  }
}

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

// テスト用モックユーザーデータ
final mockFreeFanUser = UserInfo(
  id: 'test_free_fan_id',
  name: '無料ファン',
  email: 'free_fan@example.com',
  role: UserRole.fan,
  fanPlanType: FanPlanType.free,
);

final mockLightPlanUser = UserInfo(
  id: 'test_light_plan_id',
  name: 'ライトプランユーザー',
  email: 'light_plan@example.com',
  role: UserRole.fan,
  fanPlanType: FanPlanType.light,
);

final mockStandardPlanUser = UserInfo(
  id: 'test_standard_plan_id',
  name: 'スタンダードプランユーザー',
  email: 'standard_plan@example.com',
  role: UserRole.fan,
  fanPlanType: FanPlanType.standard,
);

final mockPremiumPlanUser = UserInfo(
  id: 'test_premium_plan_id',
  name: 'プレミアムプランユーザー',
  email: 'premium_plan@example.com',
  role: UserRole.fan,
  fanPlanType: FanPlanType.premium,
); 