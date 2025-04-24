import 'package:get/get.dart';

class AuthController extends GetxController {
  String? _token;
  int? _userId;

  int? get userId => _userId;

  void setToken(String token) {
    _token = token;
  }
  void setUserId(int userId) {
    _userId = userId;
  }

  String requireToken() {
    if (_token == null) {
      throw Exception("Missing auth token.");
    }
    return _token!;
  }

  bool isAuthenticated() {
    return _token != null;
  }

  void logout() {
    _token = null;
    _userId = null;
  }
}
