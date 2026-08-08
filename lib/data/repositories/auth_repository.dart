import '../services/local_auth_service.dart';

export '../services/local_auth_service.dart' show AuthUser;


class AuthRepository {
  final LocalAuthService _service = LocalAuthService.instance;

  Future<AuthUser?> get currentUser => _service.currentUser();

  Future<AuthUser> register({
    required String name,
    required String email,
    required String password,
  }) {
    return _service.register(name: name, email: email, password: password);
  }

  Future<AuthUser> login({
    required String email,
    required String password,
  }) {
    return _service.login(email: email, password: password);
  }

  Future<void> logout() => _service.logout();
}
