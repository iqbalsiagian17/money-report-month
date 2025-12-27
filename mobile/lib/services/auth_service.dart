import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';
import 'package:hive/hive.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final LocalAuthentication _localAuth = LocalAuthentication();

  /// Check if device supports biometric
  Future<bool> isBiometricAvailable() async {
    try {
      // Check if device can check biometrics
      final canCheckBiometrics = await _localAuth.canCheckBiometrics;

      // Check if device is capable
      final isDeviceSupported = await _localAuth.isDeviceSupported();

      if (!canCheckBiometrics || !isDeviceSupported) {
        return false;
      }

      // Get available biometrics
      final availableBiometrics = await _localAuth.getAvailableBiometrics();

      debugPrint('Available biometrics:  $availableBiometrics');

      return availableBiometrics.isNotEmpty;
    } catch (e) {
      debugPrint('Error checking biometric availability: $e');
      return false;
    }
  }

  /// Get list of available biometric types
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      debugPrint('Error getting available biometrics: $e');
      return [];
    }
  }

  /// Authenticate with biometric (fingerprint / face)
  Future<bool> authenticateWithBiometric() async {
    try {
      // First check if biometric is available
      final isAvailable = await isBiometricAvailable();
      if (!isAvailable) {
        debugPrint('Biometric not available');
        return false;
      }

      final authenticated = await _localAuth.authenticate(
        localizedReason:
            'Gunakan sidik jari atau face ID untuk membuka aplikasi',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
          useErrorDialogs: true,
          sensitiveTransaction: false,
        ),
      );

      debugPrint('Biometric authentication result: $authenticated');
      return authenticated;
    } catch (e) {
      debugPrint('Biometric authentication error: $e');
      return false;
    }
  }

  /// Authenticate with PIN
  Future<bool> authenticateWithPin(String pin) async {
    try {
      final box = Hive.box('settings');
      final savedPin = box.get('pin', defaultValue: '');
      return pin == savedPin;
    } catch (e) {
      debugPrint('PIN authentication error: $e');
      return false;
    }
  }

  /// Set new PIN
  Future<void> setPin(String pin) async {
    final box = Hive.box('settings');
    await box.put('pin', pin);
    await box.put('lockEnabled', true);
  }

  /// Remove PIN and disable lock
  Future<void> removePin() async {
    final box = Hive.box('settings');
    await box.delete('pin');
    await box.put('lockEnabled', false);
    await box.put('useBiometric', false); // Also disable biometric
  }

  /// Check if lock is enabled
  bool get isLockEnabled {
    try {
      final box = Hive.box('settings');
      return box.get('lockEnabled', defaultValue: false);
    } catch (e) {
      return false;
    }
  }

  /// Check if biometric is enabled by user
  bool get useBiometric {
    try {
      final box = Hive.box('settings');
      return box.get('useBiometric', defaultValue: false);
    } catch (e) {
      return false;
    }
  }

  /// Enable/disable biometric
  Future<void> setUseBiometric(bool value) async {
    final box = Hive.box('settings');
    await box.put('useBiometric', value);
  }
}
