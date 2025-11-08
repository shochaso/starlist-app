class _DummyStorage {
  Future<void> write({required String key, String? value}) async {}
  Future<String?> read({required String key}) async => null;
  Future<void> delete({required String key}) async {}
  Future<void> deleteAll() async {}
}

final secureStorage = _DummyStorage();

