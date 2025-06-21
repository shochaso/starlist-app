import "dart:convert";
import "package:crypto/crypto.dart";
import "package:encrypt/encrypt.dart";

class SecurityService {
  static const String _key = "your-secret-key-here"; // 本番環境では環境変数から取得
  late final Encrypter _encrypter;
  late final IV _iv;

  SecurityService() {
    final key = Key.fromUtf8(_key);
    _encrypter = Encrypter(AES(key));
    _iv = IV.fromLength(16);
  }

  String hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  String encrypt(String data) {
    final encrypted = _encrypter.encrypt(data, iv: _iv);
    return encrypted.base64;
  }

  String decrypt(String encryptedData) {
    final encrypted = Encrypted.fromBase64(encryptedData);
    return _encrypter.decrypt(encrypted, iv: _iv);
  }

  String generateToken() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (i) => random.nextInt(256));
    return base64Url.encode(bytes);
  }

  bool validateToken(String token) {
    try {
      base64Url.decode(token);
      return true;
    } catch (e) {
      return false;
    }
  }

  String sanitizeInput(String input) {
    return input.replaceAll(RegExp(r"[<>]"), "");
  }

  bool validateEmail(String email) {
    final emailRegex = RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
    return emailRegex.hasMatch(email);
  }

  bool validatePassword(String password) {
    return password.length >= 8 &&
        password.contains(RegExp(r"[A-Z]")) &&
        password.contains(RegExp(r"[a-z]")) &&
        password.contains(RegExp(r"[0-9]"));
  }
}
