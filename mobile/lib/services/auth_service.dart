import 'package:local_auth/local_auth.dart';
import 'package:hive/hive.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final LocalAuthentication _localAuth = LocalAuthentication();

  Future<bool> isBiometricAvailable() async {
    try {
      return await _localAuth.canCheckBiometrics;
    } catch (e) {
      return false;
    }
  }

  Future<bool> authenticateWithBiometric() async {
    try {
      return await _localAuth.authenticate(
        localizedReason: 'Gunakan sidik jari untuk membuka aplikasi',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } catch (e) {
      return false;
    }
  }

  Future<bool> authenticateWithPin(String pin) async {
    final box = Hive.box('settings');
    final savedPin = box.get('pin', defaultValue: '');
    return pin == savedPin;
  }

  Future<void> setPin(String pin) async {
    final box = Hive.box('settings');
    await box.put('pin', pin);
    await box.put('lockEnabled', true);
  }

  Future<void> removePin() async {
    final box = Hive.box('settings');
    await box.delete('pin');
    await box.put('lockEnabled', false);
  }

  bool get isLockEnabled {
    final box = Hive.box('settings');
    return box.get('lockEnabled', defaultValue: false);
  }

  bool get useBiometric {
    final box = Hive.box('settings');
    return box.get('useBiometric', defaultValue: false);
  }

  Future<void> setUseBiometric(bool value) async {
    final box = Hive.box('settings');
    await box.put('useBiometric', value);
  }
}
