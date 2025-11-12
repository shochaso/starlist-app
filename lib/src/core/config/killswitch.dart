// lib/src/core/config/killswitch.dart
// KillSwitch環境変数を読む軽実装

class KillSwitch {
  static bool isEnabled(String feature) {
    final envValue = const String.fromEnvironment(
      'KILLSWITCH_${feature.toUpperCase()}',
      defaultValue: 'false',
    );
    return envValue.toLowerCase() == 'true';
  }
  
  static bool isDisabled(String feature) {
    return !isEnabled(feature);
  }
  
  static void guard(String feature, {required Function() onDisabled}) {
    if (isDisabled(feature)) {
      onDisabled();
      return;
    }
  }
}

// 使用例:
// if (KillSwitch.isDisabled('PRICING_PAGE')) {
//   return const MaintenancePage();
// }

