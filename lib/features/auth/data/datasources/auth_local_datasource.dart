class AuthLocalDataSource {
  final FlutterSecureStorage _storage;
  AuthLocalDataSource(this._storage);

  Future<void> saveTokens(String access, String refresh) async {
    await _storage.write(key: 'access', value: access);
    await _storage.write(key: 'refresh', value: refresh);
  }

  // Future<String?> get accessToken => _storage.read(key: 'access');
  // Future<String?> get refreshToken => _storage.read(key: 'refresh');
  // Future<void> clear() => _storage.deleteAll();
}
