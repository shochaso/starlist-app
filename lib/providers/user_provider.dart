import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user.dart' show FanPlanType; 

class UserProvider with ChangeNotifier {
  dynamic _currentUser;

  dynamic get currentUser => _currentUser;
  bool get isStar => false;
  bool get isFan => false;

  void setUser(dynamic user) {
    _currentUser = user;
    notifyListeners();
  }

  void clearUser() {
    _currentUser = null;
    notifyListeners();
  }
}

enum UserRole {
  star,
  fan,
}

enum UserMode {
  star,
  fan,
}

class UserInfo {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final UserMode currentMode;
  final String? starCategory;
  final int? followers;
  final bool isVerified;
  final FanPlanType? fanPlanType; // 追加: ファンプラン

  const UserInfo({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    UserMode? currentMode,
    this.starCategory,
    this.followers,
    this.isVerified = false,
    this.fanPlanType,
  }) : currentMode = currentMode ?? (role == UserRole.star ? UserMode.star : UserMode.fan);

  bool get isStar => role == UserRole.star;
  bool get isFan => role == UserRole.fan;

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

  UserInfo copyWith({
    String? id,
    String? name,
    String? email,
    UserRole? role,
    UserMode? currentMode,
    String? starCategory,
    int? followers,
    bool? isVerified,
    FanPlanType? fanPlanType,
  }) {
    return UserInfo(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      currentMode: currentMode ?? this.currentMode,
      starCategory: starCategory ?? this.starCategory,
      followers: followers ?? this.followers,
      isVerified: isVerified ?? this.isVerified,
      fanPlanType: fanPlanType ?? this.fanPlanType,
    );
  }
}

Future<bool> _isLoggedOut() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_logged_out') ?? false;
  } catch (e) {
    debugPrint('ログアウト状態の確認に失敗: $e');
    return false;
  }
}

final currentUserProvider = StateNotifierProvider<UserInfoNotifier, UserInfo>((ref) {
  return UserInfoNotifier();
});

class UserInfoNotifier extends StateNotifier<UserInfo> {
  UserInfoNotifier()
      : super(const UserInfo(
          id: '',
          name: '',
          email: '',
          role: UserRole.star,
          currentMode: UserMode.star,
        )) {
    _initializeUserState();
    Supabase.instance.client.auth.onAuthStateChange.listen((event) async {
      final session = event.session;
      if (session?.user != null) {
        await loadFromSupabase();
      } else {
        await _setLoggedOut();
      }
    });
  }

  Future<void> _initializeUserState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedOut = prefs.getBool('is_logged_out') ?? false;
      if (isLoggedOut) {
        await _setLoggedOut();
        return;
      }
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        await loadFromSupabase();
      }
    } catch (e) {
      debugPrint('ユーザー状態の初期化に失敗: $e');
    }
  }

  Future<void> _setLoggedOut() async {
    state = const UserInfo(id: '', name: '', email: '', role: UserRole.fan, currentMode: UserMode.fan);
  }

  Future<void> loadFromSupabase() async {
    try {
      final supabase = Supabase.instance.client;
      final authUser = supabase.auth.currentUser;
      if (authUser == null) {
        await _setLoggedOut();
        return;
      }

      final profile = await supabase
          .from('profiles')
          .select('id, display_name, email, username')
          .eq('id', authUser.id)
          .maybeSingle();

      final String? metadataDisplayName = authUser.userMetadata != null
          ? (authUser.userMetadata!['display_name'] as String?)
          : null;

      String displayName = ((profile?['display_name'] as String?) ?? '').trim();

      // display_nameが未設定で、authのメタデータに存在する場合は自動補完
      if (displayName.isEmpty && metadataDisplayName != null && metadataDisplayName.trim().isNotEmpty) {
        displayName = metadataDisplayName.trim();
        await supabase
            .from('profiles')
            .update({'display_name': displayName, 'updated_at': DateTime.now().toIso8601String()})
            .eq('id', authUser.id);
      }

      if (displayName.isEmpty) {
        displayName = authUser.email ?? '';
      }

      final String email = (profile?['email'] as String?) ?? (authUser.email ?? '');

      final newUser = UserInfo(
        id: authUser.id,
        name: displayName,
        email: email,
        role: UserRole.star,
        currentMode: UserMode.star,
      );

      state = newUser;
    } catch (e) {
      debugPrint('Supabaseプロフィールの取得に失敗: $e');
    }
  }

  void setUser(UserInfo user) {
    state = user;
  }

  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_logged_out', true);
      await prefs.setString('logout_timestamp', DateTime.now().toIso8601String());
      await Supabase.instance.client.auth.signOut();
      await _setLoggedOut();
    } catch (e) {
      debugPrint('ログアウト処理に失敗: $e');
    }
  }

  Future<void> loginRefreshFromSupabase() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_out', false);
    await prefs.remove('logout_timestamp');
    await loadFromSupabase();
  }

  // 互換API: 旧コードのlogin()呼び出しをサポート
  Future<void> login() async {
    await loginRefreshFromSupabase();
  }
}

final userModeProvider = StateNotifierProvider<UserModeNotifier, UserMode>((ref) {
  final currentUser = ref.watch(currentUserProvider);
  return UserModeNotifier(currentUser.currentMode);
});

class UserModeNotifier extends StateNotifier<UserMode> {
  UserModeNotifier(super.initialMode);
  void switchMode() { state = state == UserMode.star ? UserMode.fan : UserMode.star; }
  void setMode(UserMode mode) { state = mode; }
}

final testPlanProvider = StateProvider<String?>((ref) => null);

// 互換: 旧コードで参照しているユーザー役割トグル
final userRoleToggleProvider = StateProvider<UserRole>((ref) => UserRole.star); 