import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SecurityService {
  final LocalAuthentication _auth = LocalAuthentication();
  static const String _biometricLockKey = 'biometric_lock_enabled';

  Future<bool> get isBiometricLockEnabled async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_biometricLockKey) ?? false;
  }

  Future<void> setBiometricLockEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_biometricLockKey, enabled);
  }

  Future<bool> canAuthenticate() async {
    final bool canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
    final bool canAuthenticate =
        canAuthenticateWithBiometrics || await _auth.isDeviceSupported();
    return canAuthenticate;
  }

  Future<bool> authenticate() async {
    try {
      final bool didAuthenticate = await _auth.authenticate(
        localizedReason: 'Please authenticate to unlock your diary',
        persistAcrossBackgrounding: true,
        biometricOnly: false,
      );
      return didAuthenticate;
    } catch (e) {
      return false;
    }
  }
}
