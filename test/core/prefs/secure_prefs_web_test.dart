@TestOn('browser')
import 'package:test/test.dart';
import 'package:starlist_app/core/prefs/secure_prefs.dart' as sp;

void main() {
  test('Web forbids token persistence (setString throws)', () async {
    expect(() async => await sp.SecurePrefs.setString('token', 'x'),
        throwsA(isA<StateError>()));
  });
}

