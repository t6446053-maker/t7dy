import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthUser {
  final String id;
  final String name;
  final String email;

  const AuthUser({
    required this.id,
    required this.name,
    required this.email,
  });

  Map<String, dynamic> toMap() => {'id': id, 'name': name, 'email': email};

  factory AuthUser.fromMap(Map<String, dynamic> map) => AuthUser(
        id: map['id'] as String,
        name: map['name'] as String,
        email: map['email'] as String,
      );
}


class LocalAuthService {
  LocalAuthService._();
  static final LocalAuthService instance = LocalAuthService._();

  static const _usersKey = 'tahaddani_users_v1';
  static const _sessionKey = 'tahaddani_session_email_v1';

  Future<List<Map<String, dynamic>>> _loadUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_usersKey);
    if (raw == null || raw.isEmpty) return [];
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded.cast<Map<String, dynamic>>();
  }

  Future<void> _saveUsers(List<Map<String, dynamic>> users) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_usersKey, jsonEncode(users));
  }

  String _hash(String password, String salt) {
    final bytes = utf8.encode('$salt::$password');
    return sha256.convert(bytes).toString();
  }

  String _generateSalt(String seed) {
    return sha256.convert(utf8.encode('${DateTime.now().microsecondsSinceEpoch}_$seed')).toString().substring(0, 16);
  }

  Future<AuthUser> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    final users = await _loadUsers();

    final exists = users.any((u) => u['email'] == normalizedEmail);
    if (exists) {
      throw Exception('البريد الإلكتروني مستخدم بالفعل');
    }

    final salt = _generateSalt(normalizedEmail);
    final user = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'name': name.trim(),
      'email': normalizedEmail,
      'salt': salt,
      'passwordHash': _hash(password, salt),
    };

    users.add(user);
    await _saveUsers(users);
    await _setSession(normalizedEmail);

    return AuthUser(id: user['id'] as String, name: user['name'] as String, email: normalizedEmail);
  }

  Future<AuthUser> login({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    final users = await _loadUsers();

    final match = users.cast<Map<String, dynamic>?>().firstWhere(
          (u) => u?['email'] == normalizedEmail,
          orElse: () => null,
        );

    if (match == null) {
      throw Exception('لا يوجد حساب بهذا البريد الإلكتروني');
    }

    final expectedHash = _hash(password, match['salt'] as String);
    if (expectedHash != match['passwordHash']) {
      throw Exception('كلمة المرور غير صحيحة');
    }

    await _setSession(normalizedEmail);

    return AuthUser(
      id: match['id'] as String,
      name: match['name'] as String,
      email: normalizedEmail,
    );
  }

  Future<void> _setSession(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionKey, email);
  }


  Future<AuthUser?> currentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString(_sessionKey);
    if (email == null) return null;

    final users = await _loadUsers();
    final match = users.cast<Map<String, dynamic>?>().firstWhere(
          (u) => u?['email'] == email,
          orElse: () => null,
        );
    if (match == null) return null;

    return AuthUser(
      id: match['id'] as String,
      name: match['name'] as String,
      email: match['email'] as String,
    );
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
  }
}
