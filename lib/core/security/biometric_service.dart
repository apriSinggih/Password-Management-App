import 'package:local_auth/local_auth.dart';

class BiometricService {
  BiometricService({LocalAuthentication? authentication})
    : _authentication = authentication ?? LocalAuthentication();

  final LocalAuthentication _authentication;

  Future<bool> isAvailable() async {
    try {
      final supported = await _authentication.isDeviceSupported();
      if (!supported) return false;
      final biometrics = await _authentication.getAvailableBiometrics();
      return biometrics.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<bool> authenticate() async {
    try {
      return await _authentication.authenticate(
        localizedReason: 'Buka SecureVault',
        biometricOnly: false,
        persistAcrossBackgrounding: true,
      );
    } catch (_) {
      return false;
    }
  }
}
