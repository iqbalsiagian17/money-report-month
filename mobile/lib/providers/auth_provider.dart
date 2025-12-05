import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isAuthenticated = false;
  bool _isInitialized = false;

  bool get isAuthenticated => _isAuthenticated;
  bool get isInitialized => _isInitialized;
  bool get isLockEnabled => _authService.isLockEnabled;
  bool get useBiometric => _authService.useBiometric;

  Future<void> initialize() async {
    _isInitialized = true;
    if (!isLockEnabled) {
      _isAuthenticated = true;
    }
    notifyListeners();
  }

  Future<bool> authenticateWithBiometric() async {
    _isAuthenticated = await _authService.authenticateWithBiometric();
    notifyListeners();
    return _isAuthenticated;
  }

  Future<bool> authenticateWithPin(String pin) async {
    _isAuthenticated = await _authService.authenticateWithPin(pin);
    notifyListeners();
    return _isAuthenticated;
  }

  Future<void> setPin(String pin) async {
    await _authService.setPin(pin);
    notifyListeners();
  }

  Future<void> removePin() async {
    await _authService.removePin();
    notifyListeners();
  }

  Future<void> setUseBiometric(bool value) async {
    await _authService.setUseBiometric(value);
    notifyListeners();
  }

  void lock() {
    _isAuthenticated = false;
    notifyListeners();
  }
}
