import 'package:flutter_test/flutter_test.dart';

import 'package:starlist_app/services/service_icon_registry.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('service icon map should not be empty', () {
    final debugMap = ServiceIconRegistry.debugAutoMap();
    expect(
      debugMap.isNotEmpty,
      true,
      reason: 'ServiceIconRegistry の _map が空です',
    );
    
    // すべてのサービスアイコンにパスが設定されていることを確認
    for (final entry in debugMap.entries) {
      expect(
        entry.value.isNotEmpty,
        true,
        reason: 'サービス "${entry.key}" のパスが空です',
      );
    }
  });
  
  test('pathFor should return correct paths', () {
    final amazonPath = ServiceIconRegistry.pathFor('amazon');
    expect(amazonPath, equals('assets/service_icons/amazon.png'));
    
    final netflixPath = ServiceIconRegistry.pathFor('netflix');
    expect(netflixPath, equals('assets/service_icons/netflix.png'));
    
    final abemaPath = ServiceIconRegistry.pathFor('abema');
    expect(abemaPath, equals('assets/service_icons/abema.jpg'));
  });
  
  test('pathFor should handle case insensitivity', () {
    expect(
      ServiceIconRegistry.pathFor('AMAZON'),
      equals(ServiceIconRegistry.pathFor('amazon')),
    );
    
    expect(
      ServiceIconRegistry.pathFor('Netflix'),
      equals(ServiceIconRegistry.pathFor('netflix')),
    );
  });
  
  test('pathFor should return null for unknown services', () {
    expect(ServiceIconRegistry.pathFor('unknown_service'), isNull);
    expect(ServiceIconRegistry.pathFor(''), isNull);
  });
}
