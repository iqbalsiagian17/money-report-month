import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isAuthenticated = false;
  bool _isInitialized = false;
  bool _isBiometricAvailable = false;

  bool get isAuthenticated => _isAuthenticated;
  bool get isInitialized => _isInitialized;
  bool get isLockEnabled => _authService.isLockEnabled;
  bool get useBiometric => _authService.useBiometric;
  bool get isBiometricAvailable => _isBiometricAvailable;

  Future<void> initialize() async {
    // Check biometric availability
    _isBiometricAvailable = await _authService.isBiometricAvailable();
    debugPrint('Biometric available:  $_isBiometricAvailable');

    _isInitialized = true;

    if (!isLockEnabled) {
      _isAuthenticated = true;
    }

    notifyListeners();
  }

  Future<bool> authenticateWithBiometric() async {
    if (!_isBiometricAvailable) {
      debugPrint('Biometric not available on this device');
      return false;
    }

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
    _isAuthenticated = true; // Auto unlock when PIN removed
    notifyListeners();
  }

  Future<bool> toggleBiometric() async {
    if (!_isBiometricAvailable) {
      debugPrint('Cannot enable biometric - not available');
      return false;
    }

    final newValue = !useBiometric;

    // If enabling, test biometric first
    if (newValue) {
      final success = await _authService.authenticateWithBiometric();
      if (!success) {
        debugPrint('Biometric test failed, not enabling');
        return false;
      }
    }

    await _authService.setUseBiometric(newValue);
    notifyListeners();
    return true;
  }

  Future<void> setUseBiometric(bool value) async {
    if (value && !_isBiometricAvailable) {
      debugPrint('Cannot enable biometric - not available');
      return;
    }
    await _authService.setUseBiometric(value);
    notifyListeners();
  }

  void lock() {
    if (isLockEnabled) {
      _isAuthenticated = false;
      notifyListeners();
    }
  }

  /// Refresh biometric availability (call after app resume)
  Future<void> refreshBiometricStatus() async {
    _isBiometricAvailable = await _authService.isBiometricAvailable();
    notifyListeners();
  }
}
