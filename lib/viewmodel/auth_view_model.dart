import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool isLoading = false;
  String? error;

  Future<bool> login(String email, String password) async {
    return _handleAuth(() => _authService.login(email, password));
  }


Future<void> logout() async {
  try {
    _setLoading(true);
    error = null;
    await _authService.logout();
  } catch (e) {
    error = e.toString();
  } finally {
    _setLoading(false);
  }
}

  Future<bool> register(String email, String password) async {
    return _handleAuth(() => _authService.register(email, password));
  }

  Future<void> forgotPassword(String email) async {
    try {
      _setLoading(true);
      error = null;
      await _authService.sendResetPassword(email);
    } catch (e) {
      error = e.toString();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> _handleAuth(Future Function() action) async {
    try {
      _setLoading(true);
      error = null;
      await action();
      return true;
    } catch (e) {
      error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }
}